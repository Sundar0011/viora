-- 0067_public_contact_count.sql
-- Stakeholder decision (2026-07-19): the "N people contacted" count on a business page is PUBLIC
-- to all signed-in visitors (social proof), NOT owner/admin-only. Supersedes 0056's gated version.
-- Only the AGGREGATE count is public; individual business_contacted rows (who contacted) stay
-- owner/admin-only via the business_contacted SELECT RLS (0065) — this RPC is SECURITY DEFINER so
-- it can count without exposing the rows. Includes its own anon revoke so ordering vs 0066 is moot.
begin;
create or replace function public.get_contact_count(p_businessid uuid)
returns int8 language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'get_contact_count: no authenticated user'; end if;
  if not exists (select 1 from public.business_page where id = p_businessid) then return 0; end if;
  return (select count(*) from public.business_contacted where business_page_id = p_businessid);
end; $$;
comment on function public.get_contact_count(uuid) is
  'Public (any authenticated) distinct contacting-user count for a business page. Individual rows stay owner/admin-only.';
revoke all on function public.get_contact_count(uuid) from public, anon;
grant execute on function public.get_contact_count(uuid) to authenticated;
commit;
