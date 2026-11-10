-- Development-only additive migration. Apply to approved DEV Supabase before using new UI.
begin;
create table public.operon_handover_workflows (
  handover_id uuid not null references public.operon_shift_handovers(id) on delete cascade,
  workflow_id uuid not null references public.operon_workflows(id),
  linked_at timestamptz not null default now(),
  primary key (handover_id, workflow_id)
);
create index operon_handover_workflows_workflow_idx on public.operon_handover_workflows(workflow_id);
alter table public.operon_handover_workflows enable row level security;
create policy operon_handover_workflows_read on public.operon_handover_workflows
for select to authenticated using (
  exists (
    select 1 from public.operon_shift_handovers h
    join public.operon_memberships m on m.unit_id=h.unit_id
    where h.id=handover_id and m.user_id=(select auth.uid()) and m.active
  )
);
revoke all on public.operon_handover_workflows from public, anon, authenticated;
grant select on public.operon_handover_workflows to authenticated;

-- New 5-argument overload preserves the old 4-argument RPC for older clients.
create function public.operon_create_shift_handover(
  p_unit_id uuid, p_shift_date date, p_shift_name text, p_summary text,
  p_workflow_ids uuid[]
) returns uuid language plpgsql security definer set search_path=''
as $$
declare
  v_actor uuid := auth.uid();
  v_id uuid;
  v_requested int;
  v_valid int;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_shift_date is null or p_shift_name is null or
     p_shift_name not in ('morning','afternoon','night') or
     p_summary is null or length(btrim(p_summary)) not between 1 and 2000 then
    raise exception 'Invalid handover';
  end if;
  if not exists (
    select 1 from public.operon_memberships m
    where m.user_id=v_actor and m.unit_id=p_unit_id and m.active
      and m.role in ('operator','foreman','coordinator','supervisor','unitEngineer')
  ) then raise exception 'Not authorized for this unit'; end if;
  if p_workflow_ids is null or cardinality(p_workflow_ids)>50 then
    raise exception 'Invalid linked workflow list';
  end if;
  select count(*) into v_requested from (select distinct unnest(p_workflow_ids) as id) x;
  select count(*) into v_valid
  from (select distinct unnest(p_workflow_ids) as id) x
  join public.operon_workflows w on w.id=x.id
  where w.unit_id=p_unit_id and w.state<>'completed';
  if v_valid<>v_requested then
    raise exception 'Linked workflows must be open and belong to the selected unit';
  end if;
  insert into public.operon_shift_handovers(unit_id,created_by,shift_date,shift_name,summary)
    values(p_unit_id,v_actor,p_shift_date,p_shift_name,btrim(p_summary))
    returning id into v_id;
  insert into public.operon_handover_workflows(handover_id,workflow_id)
    select v_id, x.id from (select distinct unnest(p_workflow_ids) as id) x;
  return v_id;
end $$;
revoke all on function public.operon_create_shift_handover(uuid,date,text,text,uuid[]) from public,anon;
grant execute on function public.operon_create_shift_handover(uuid,date,text,text,uuid[]) to authenticated;
commit;
