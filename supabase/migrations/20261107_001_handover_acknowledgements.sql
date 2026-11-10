-- DEV: acknowledgement is an auditable receipt, not task completion.
create table public.operon_handover_acknowledgements (
  handover_id uuid not null references public.operon_shift_handovers(id) on delete cascade,
  acknowledged_by uuid not null references auth.users(id),
  acknowledged_at timestamptz not null default now(),
  note text not null default '' check (length(note) <= 1000),
  primary key (handover_id, acknowledged_by)
);
create index operon_handover_acknowledgements_actor_idx on public.operon_handover_acknowledgements(acknowledged_by);
alter table public.operon_handover_acknowledgements enable row level security;
create policy operon_handover_acknowledgements_read on public.operon_handover_acknowledgements
for select to authenticated using (
  exists (
    select 1 from public.operon_shift_handovers h
    join public.operon_memberships m on m.unit_id = h.unit_id
    where h.id = handover_id and m.user_id = (select auth.uid()) and m.active
  )
);
revoke all on public.operon_handover_acknowledgements from public, anon, authenticated;
grant select on public.operon_handover_acknowledgements to authenticated;

create function public.operon_acknowledge_shift_handover(p_handover_id uuid, p_note text default '')
returns timestamptz language plpgsql security definer set search_path = ''
as $$
declare
  v_actor uuid := auth.uid();
  v_unit uuid;
  v_creator uuid;
  v_timestamp timestamptz;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_note is null or length(p_note) > 1000 then raise exception 'Invalid note'; end if;
  select unit_id, created_by into v_unit, v_creator
    from public.operon_shift_handovers where id = p_handover_id;
  if v_unit is null then raise exception 'Handover not found'; end if;
  if v_actor = v_creator then raise exception 'Cannot acknowledge own handover'; end if;
  if not exists (
    select 1 from public.operon_memberships m
    where m.unit_id = v_unit and m.user_id = v_actor and m.active
      and m.role in ('operator','foreman','coordinator','supervisor','unitEngineer')
  ) then raise exception 'Not authorized for this unit'; end if;
  insert into public.operon_handover_acknowledgements(handover_id,acknowledged_by,note)
  values(p_handover_id,v_actor,p_note)
  on conflict (handover_id,acknowledged_by) do nothing;
  select acknowledged_at into v_timestamp
    from public.operon_handover_acknowledgements
    where handover_id=p_handover_id and acknowledged_by=v_actor;
  return v_timestamp;
end $$;
revoke all on function public.operon_acknowledge_shift_handover(uuid,text) from public,anon;
grant execute on function public.operon_acknowledge_shift_handover(uuid,text) to authenticated;
