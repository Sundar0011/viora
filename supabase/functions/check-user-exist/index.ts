// supabase/functions/check-user-exist/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.A/B)
// Frontend caller: CheckUserExistCall — called by final_steps_mail_page / final_steps_phone_page
//   BEFORE signup to block duplicate accounts.
//
// STATUS: REAL.
//
// REQUEST (POST, application/json):
//   { "email": "<email or ''>", "mobile_number": "<E.164 phone with CC or ''>" }
//   - mobile_number is "{countryCode}{number}" e.g. "+441234567890" (matches the stored
//     public."user".mobile_number_cc column — see final_steps_phone_page_widget.dart).
//
// RESPONSE (always 200 so the app can read the flags):
//   200 { "email_exists": <bool>, "mobile_number_exists": <bool> }
//   The app reads $.email_exists / $.mobile_number_exists via castToType<bool> and compares
//   `!= true`, so both keys must be present booleans.
//   400 { "error": "<msg>", "email_exists": false, "mobile_number_exists": false } on bad JSON.
//
// verify_jwt: FALSE (pre-signup, unauthenticated). Deploy with `--no-verify-jwt`.
//
// ENV (auto-provided): SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY. The service-role client is
//   used to read public."user" (bypasses RLS; user_login/identity tables deny anon per
//   docs §7). Existence is checked against public."user" — the app's own identity table that
//   the signup flow writes and reads (queryRows) elsewhere.
//   ASSUMPTION: checking public."user" is sufficient. An auth.users row can exist without a
//   public."user" row only if a prior signup crashed between createUser and the row insert;
//   if strict auth.users de-duplication is needed later, add a GoTrue admin lookup.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") {
    return json({ error: "Method not allowed", email_exists: false, mobile_number_exists: false }, 405);
  }

  let email = "";
  let mobile = "";
  try {
    const body = await req.json();
    email = (body?.email ?? "").toString().trim();
    mobile = (body?.mobile_number ?? "").toString().trim();
  } catch (_) {
    return json({ error: "Invalid JSON body", email_exists: false, mobile_number_exists: false }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    let emailExists = false;
    let mobileExists = false;

    // Only query when a value was supplied — an empty string must never match a row.
    if (email) {
      const { data, error } = await supabase
        .from("user")
        .select("id")
        .eq("email", email)
        .limit(1);
      if (error) return json({ error: error.message, email_exists: false, mobile_number_exists: false }, 500);
      emailExists = (data?.length ?? 0) > 0;
    }

    if (mobile) {
      const { data, error } = await supabase
        .from("user")
        .select("id")
        .eq("mobile_number_cc", mobile)
        .limit(1);
      if (error) return json({ error: error.message, email_exists: false, mobile_number_exists: false }, 500);
      mobileExists = (data?.length ?? 0) > 0;
    }

    return json({ email_exists: emailExists, mobile_number_exists: mobileExists }, 200);
  } catch (err) {
    return json({ error: String(err), email_exists: false, mobile_number_exists: false }, 500);
  }
});
