-- 0087_push_trigger_vault.sql
-- Supersedes the GUC-based push trigger from 0082. Hosted Supabase forbids
-- `alter database ... set app.settings.*` (superuser-only, permission denied even in the SQL
-- editor), so the two GUCs the old trigger read can never be set. This rewrite:
--   - reads the service-role key from Supabase Vault (encrypted at rest) instead of a plaintext GUC,
--   - hardcodes the (non-secret) Edge Function URL directly in the trigger.
-- FCM_SERVICE_ACCOUNT_JSON stays an Edge Function secret (read inside the Deno function, not here).
--
-- REQUIRED MANUAL SETUP (one line, run in the SQL editor with the real key — keeps it out of source):
--   select vault.create_secret(
--     '<SUPABASE_SERVICE_ROLE_KEY>', 'service_role_key',
--     'Service-role key used by the notification push trigger to call send-notification');
-- Until that secret exists, push is a no-op (the trigger's exception guard keeps the notification
-- INSERT itself always succeeding — in-app delivery never depends on push).

create or replace function public.trg_push_new_notification()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_url text := 'https://hlmymmlkgirafodcnkgg.supabase.co/functions/v1/send-notification';
  v_key text;
begin
  begin
    -- Service-role key from Vault (encrypted). Non-secret URL is hardcoded above.
    select decrypted_secret into v_key
    from vault.decrypted_secrets
    where name = 'service_role_key'
    limit 1;

    if v_key is not null then
      perform net.http_post(
        url     => v_url,
        headers => jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || v_key
        ),
        body    => jsonb_build_object(
          'notification_id', new.id,
          'receiver_id', new.receiver_id,
          'sender_id', new.sender_id,
          'type', new.type,
          'title', new.title,
          'content', new.content
        )
      );
    end if;
  exception when others then
    -- Best-effort: a missing Vault secret / pg_net / unreachable function must NEVER fail the
    -- notification write itself. Push is best-effort; the in-app row already succeeded.
    null;
  end;

  return new;
end;
$$;

revoke all on function public.trg_push_new_notification() from public, anon, authenticated;
