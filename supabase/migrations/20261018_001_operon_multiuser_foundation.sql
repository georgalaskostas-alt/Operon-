-- OPERON enterprise prototype: Supabase PostgreSQL baseline.
-- REVIEW BEFORE APPLYING. Not deployed and not approved for production data.
-- Roles are provisioned by trusted administrators using service credentials,
-- never by the mobile client.
begin;

create table if not exists public.operon_units (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) between 1 and 120)
);

create table if not exists public.operon_memberships (
  user_id uuid not null references auth.users(id) on delete cascade,
  unit_id uuid not null references public.operon_units(id) on delete cascade,
  role text not null check (role in ('operator','foreman','coordinator','supervisor','unitEngineer')),
  active boolean not null default true,
  primary key (user_id, unit_id, role)
);

create table if not exists public.operon_workflows (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.operon_units(id),
  title text not null check (length(btrim(title)) between 1 and 250),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  state text not null default 'submitted' check (state in (
    'submitted','foremanReview','coordinatorReview','managementReview','completed','returned')),
  revision integer not null default 0 check (revision >= 0)
);

create table if not exists public.operon_workflow_events (
  id bigint generated always as identity primary key,
  workflow_id uuid not null references public.operon_workflows(id),
  actor_id uuid not null references auth.users(id),
  actor_role text not null,
  from_state text not null,
  to_state text not null,
  note text not null check (length(btrim(note)) between 1 and 2000),
  created_at timestamptz not null default now(),
  revision integer not null,
  unique (workflow_id, revision)
);

create index if not exists operon_memberships_unit_idx
  on public.operon_memberships(unit_id, user_id) where active;
create index if not exists operon_workflows_unit_idx
  on public.operon_workflows(unit_id, created_at desc);
create index if not exists operon_events_workflow_idx
  on public.operon_workflow_events(workflow_id, revision);

alter table public.operon_units enable row level security;
alter table public.operon_memberships enable row level security;
alter table public.operon_workflows enable row level security;
alter table public.operon_workflow_events enable row level security;

-- All policies are read-only. Writes must go through server-validated RPC.
create policy operon_units_read on public.operon_units for select to authenticated
using (exists (select 1 from public.operon_memberships m
  where m.unit_id = id and m.user_id = (select auth.uid()) and m.active));

-- Membership table must not recursively query itself in its own policy.
create policy operon_memberships_self_read on public.operon_memberships for select to authenticated
using (user_id = (select auth.uid()));

create policy operon_workflows_read on public.operon_workflows for select to authenticated
using (exists (select 1 from public.operon_memberships m
  where m.unit_id = operon_workflows.unit_id and m.user_id = (select auth.uid()) and m.active));

create policy operon_events_read on public.operon_workflow_events for select to authenticated
using (exists (select 1 from public.operon_workflows w
  join public.operon_memberships m on m.unit_id = w.unit_id
  where w.id = operon_workflow_events.workflow_id
    and m.user_id = (select auth.uid()) and m.active));

revoke all on public.operon_units, public.operon_memberships,
  public.operon_workflows, public.operon_workflow_events from anon, authenticated;
grant select on public.operon_units, public.operon_memberships,
  public.operon_workflows, public.operon_workflow_events to authenticated;

-- SECURITY DEFINER: caller identity is always auth.uid(), never a client-supplied actor.
create or replace function public.operon_submit_workflow(
  p_unit_id uuid, p_title text
) returns uuid language plpgsql security definer set search_path = ''
as $$
declare v_actor uuid := auth.uid(); v_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_title is null or length(btrim(p_title)) not between 1 and 250 then
    raise exception 'Invalid title';
  end if;
  if not exists (select 1 from public.operon_memberships m
    where m.user_id = v_actor and m.unit_id = p_unit_id
      and m.role = 'operator' and m.active) then
    raise exception 'Not authorized to submit in this unit';
  end if;
  insert into public.operon_workflows(unit_id,title,created_by)
    values (p_unit_id,btrim(p_title),v_actor) returning id into v_id;
  return v_id;
end $$;

create or replace function public.operon_transition_workflow(
  p_workflow_id uuid, p_expected_revision integer, p_next_state text, p_note text
) returns integer language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_workflow public.operon_workflows%rowtype;
  v_role text;
  v_allowed boolean;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_note is null or length(btrim(p_note)) not between 1 and 2000 then
    raise exception 'An audit note is required';
  end if;
  select * into v_workflow from public.operon_workflows
    where id = p_workflow_id for update;
  if not found then raise exception 'Workflow not found'; end if;
  if p_expected_revision is distinct from v_workflow.revision then
    raise exception 'Revision conflict';
  end if;

  -- A single allowed membership is sufficient; audit records the role used.
  select m.role into v_role from public.operon_memberships m
  where m.user_id = v_actor and m.unit_id = v_workflow.unit_id and m.active
    and (
      (v_workflow.state = 'submitted' and m.role = 'foreman'
        and p_next_state in ('foremanReview','returned'))
      or (v_workflow.state = 'foremanReview' and m.role = 'foreman'
        and p_next_state in ('coordinatorReview','returned'))
      or (v_workflow.state = 'coordinatorReview' and m.role = 'coordinator'
        and p_next_state in ('managementReview','returned'))
      or (v_workflow.state = 'managementReview'
        and m.role in ('supervisor','unitEngineer')
        and p_next_state in ('completed','returned'))
      or (v_workflow.state = 'returned' and m.role = 'operator'
        and v_workflow.created_by = v_actor and p_next_state = 'submitted')
    )
  order by m.role limit 1;
  if v_role is null then raise exception 'Transition not authorized'; end if;

  update public.operon_workflows
    set state = p_next_state, revision = revision + 1
    where id = p_workflow_id;
  insert into public.operon_workflow_events(
    workflow_id, actor_id, actor_role, from_state, to_state, note, revision
  ) values (
    p_workflow_id, v_actor, v_role, v_workflow.state, p_next_state,
    btrim(p_note), v_workflow.revision + 1
  );
  return v_workflow.revision + 1;
end $$;

revoke all on function public.operon_submit_workflow(uuid,text) from public, anon;
revoke all on function public.operon_transition_workflow(uuid,integer,text,text) from public, anon;
grant execute on function public.operon_submit_workflow(uuid,text) to authenticated;
grant execute on function public.operon_transition_workflow(uuid,integer,text,text) to authenticated;

commit;
