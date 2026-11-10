-- Role-separated handovers. Existing records remain legacy read-only.
begin;
alter table public.operon_shift_handovers
 add column if not exists handover_role text check (handover_role in ('operator','foreman'));
create index if not exists operon_shift_handovers_role_idx on public.operon_shift_handovers(unit_id,handover_role,created_at desc);

drop policy operon_shift_handovers_read on public.operon_shift_handovers;
create policy operon_shift_handovers_read on public.operon_shift_handovers
for select to authenticated using (
  exists (select 1 from public.operon_memberships m
    where m.unit_id=operon_shift_handovers.unit_id and m.user_id=(select auth.uid()) and m.active
      and (m.role in ('foreman','coordinator','supervisor','unitEngineer')
        or (m.role='operator' and operon_shift_handovers.handover_role='operator')))
);

drop policy operon_handover_workflows_read on public.operon_handover_workflows;
create policy operon_handover_workflows_read on public.operon_handover_workflows
for select to authenticated using (
  exists (select 1 from public.operon_shift_handovers h
    join public.operon_memberships m on m.unit_id=h.unit_id
    where h.id=handover_id and m.user_id=(select auth.uid()) and m.active
      and (m.role in ('foreman','coordinator','supervisor','unitEngineer')
        or (m.role='operator' and h.handover_role='operator')))
);

drop policy operon_handover_acknowledgements_read on public.operon_handover_acknowledgements;
create policy operon_handover_acknowledgements_read on public.operon_handover_acknowledgements
for select to authenticated using (
  exists (select 1 from public.operon_shift_handovers h
    join public.operon_memberships m on m.unit_id=h.unit_id
    where h.id=handover_id and m.user_id=(select auth.uid()) and m.active
      and (m.role in ('foreman','coordinator','supervisor','unitEngineer')
        or (m.role='operator' and h.handover_role='operator')))
);

-- Replace existing 5-argument signature with a mandatory role-aware 6-argument RPC.
drop function public.operon_create_shift_handover(uuid,date,text,text,uuid[]);
drop function public.operon_create_shift_handover(uuid,date,text,text);
create function public.operon_create_shift_handover(
  p_unit_id uuid,p_shift_date date,p_shift_name text,p_summary text,
  p_workflow_ids uuid[],p_handover_role text
) returns uuid language plpgsql security definer set search_path=''
as $$
declare v_actor uuid := auth.uid(); v_id uuid; v_requested int; v_valid int;
begin
 if v_actor is null then raise exception 'Authentication required'; end if;
 if p_handover_role not in ('operator','foreman') or p_handover_role is null
    or p_shift_date is null or p_shift_name not in ('morning','afternoon','night')
    or p_shift_name is null or p_summary is null
    or length(btrim(p_summary)) not between 1 and 2000
    or p_workflow_ids is null or cardinality(p_workflow_ids)>50
 then raise exception 'Invalid handover'; end if;
 if not exists(select 1 from public.operon_memberships m
   where m.user_id=v_actor and m.unit_id=p_unit_id and m.active and m.role=p_handover_role)
 then raise exception 'Only matching operator or foreman can create this handover'; end if;
 select count(*) into v_requested from (select distinct unnest(p_workflow_ids) id) x;
 select count(*) into v_valid from (select distinct unnest(p_workflow_ids) id) x
 join public.operon_workflows w on w.id=x.id
 where w.unit_id=p_unit_id and w.state<>'completed';
 if v_requested<>v_valid then raise exception 'Invalid linked workflows'; end if;
 insert into public.operon_shift_handovers(unit_id,created_by,shift_date,shift_name,summary,handover_role)
 values(p_unit_id,v_actor,p_shift_date,p_shift_name,btrim(p_summary),p_handover_role) returning id into v_id;
 insert into public.operon_handover_workflows(handover_id,workflow_id)
 select v_id,x.id from (select distinct unnest(p_workflow_ids) id) x;
 return v_id;
end $$;
revoke all on function public.operon_create_shift_handover(uuid,date,text,text,uuid[],text) from public,anon;
grant execute on function public.operon_create_shift_handover(uuid,date,text,text,uuid[],text) to authenticated;

create or replace function public.operon_acknowledge_shift_handover(p_handover_id uuid,p_note text default '')
returns timestamptz language plpgsql security definer set search_path=''
as $$
declare v_actor uuid:=auth.uid(); v_unit uuid; v_creator uuid; v_role text; v_timestamp timestamptz;
begin
 if v_actor is null then raise exception 'Authentication required'; end if;
 if p_note is null or length(p_note)>1000 then raise exception 'Invalid note'; end if;
 select unit_id,created_by,handover_role into v_unit,v_creator,v_role
 from public.operon_shift_handovers where id=p_handover_id;
 if v_unit is null then raise exception 'Handover not found'; end if;
 if v_role is null then raise exception 'Legacy handover cannot be acknowledged'; end if;
 if v_actor=v_creator then raise exception 'Cannot acknowledge own handover'; end if;
 if not exists(select 1 from public.operon_memberships m
   where m.unit_id=v_unit and m.user_id=v_actor and m.active and m.role=v_role)
 then raise exception 'Only same-role colleague can acknowledge'; end if;
 insert into public.operon_handover_acknowledgements(handover_id,acknowledged_by,note)
 values(p_handover_id,v_actor,p_note) on conflict(handover_id,acknowledged_by) do nothing;
 select acknowledged_at into v_timestamp from public.operon_handover_acknowledgements
 where handover_id=p_handover_id and acknowledged_by=v_actor;
 return v_timestamp;
end $$;
revoke all on function public.operon_acknowledge_shift_handover(uuid,text) from public,anon;
grant execute on function public.operon_acknowledge_shift_handover(uuid,text) to authenticated;
commit;