-- OPERON development: shift handover records, separate from approval workflows.
create table if not exists public.operon_shift_handovers (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.operon_units(id),
  created_by uuid not null references auth.users(id),
  shift_date date not null,
  shift_name text not null check (shift_name in ('morning','afternoon','night')),
  summary text not null check (length(btrim(summary)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists operon_shift_handovers_unit_date_idx
  on public.operon_shift_handovers(unit_id, shift_date desc, created_at desc);
alter table public.operon_shift_handovers enable row level security;
create policy operon_shift_handovers_read on public.operon_shift_handovers
  for select to authenticated using (
    exists (select 1 from public.operon_memberships m
      where m.unit_id = operon_shift_handovers.unit_id
        and m.user_id = (select auth.uid()) and m.active)
  );
revoke all on public.operon_shift_handovers from anon, authenticated;
grant select on public.operon_shift_handovers to authenticated;
create or replace function public.operon_create_shift_handover(
  p_unit_id uuid, p_shift_date date, p_shift_name text, p_summary text
) returns uuid language plpgsql security definer set search_path = ''
as $$
declare v_actor uuid := auth.uid(); v_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_shift_date is null or p_shift_name not in ('morning','afternoon','night')
     or p_shift_name is null or p_summary is null
     or length(btrim(p_summary)) not between 1 and 2000 then
    raise exception 'Invalid handover';
  end if;
  if not exists (select 1 from public.operon_memberships m
      where m.user_id = v_actor and m.unit_id = p_unit_id and m.active
        and m.role in ('operator','foreman','coordinator','supervisor','unitEngineer')) then
    raise exception 'Not authorized for this unit';
  end if;
  insert into public.operon_shift_handovers(unit_id,created_by,shift_date,shift_name,summary)
    values (p_unit_id,v_actor,p_shift_date,p_shift_name,btrim(p_summary))
    returning id into v_id;
  return v_id;
end $$;
revoke all on function public.operon_create_shift_handover(uuid,date,text,text) from public,anon;
grant execute on function public.operon_create_shift_handover(uuid,date,text,text) to authenticated;