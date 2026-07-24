-- 0039_event_functions_counters.sql
-- Purpose: Batch 5 (Events) — legacy-compat counter RPC (UpdateEventAttendeeCountCall). The REAL
-- counter is trigger-owned (0041_event_triggers.sql, SECURITY DEFINER, fires on every
-- event_attending insert/update/delete) — this RPC is kept only because the locked frontend still
-- calls it explicitly after every RSVP change in event_details (docs/features/06-events.md §5).
-- Matches the update_total_group_members()/update_user_group_count() precedent
-- (0031_group_functions_counters.sql): an actual IDEMPOTENT recompute, harmless/redundant once the
-- trigger has already run, self-healing if it ever didn't.
--
-- Every SECURITY DEFINER function follows CLAUDE.md §6.5.

begin;

-- ---------------------------------------------------------------------------------------------
-- update_event_attendee_count (UpdateEventAttendeeCountCall) — EXACT frontend contract:
-- p_event_id only. Recomputes event_page.attendee_count = count of event_attending rows for the
-- event where is_attending = true (docs/database/09-rpc-inventory.md §6). No ownership check
-- beyond "event exists" — a deterministic, idempotent recompute has no unauthorized side effect.
-- ---------------------------------------------------------------------------------------------
create or replace function public.update_event_attendee_count(p_event_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'update_event_attendee_count: no authenticated user';
  end if;

  update public.event_page
  set attendee_count = (
    select count(*) from public.event_attending where event_id = p_event_id and is_attending = true
  )
  where id = p_event_id;
end;
$$;

comment on function public.update_event_attendee_count(uuid) is
  'Legacy-compat idempotent recompute of event_page.attendee_count. Real counter is trigger-maintained (0041).';

revoke all on function public.update_event_attendee_count(uuid) from public;
grant execute on function public.update_event_attendee_count(uuid) to authenticated;

commit;
