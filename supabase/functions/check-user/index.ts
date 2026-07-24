// supabase/functions/check-user/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.E)
// Frontend caller: CheckUserCall — called by forget_password to confirm the account EXISTS
//   before starting recovery (email branch and mobile branch call it separately).
//
// STATUS: REAL.
//
// REQUEST (POST, application/json):
//   { "email": "<email or ''>", "mobile_number": "<E.164 phone with CC or ''>" }
//   (forget_password sends exactly one of the two populated.)
//
// RESPONSE (always 200 so the app can read the flag):
//   200 { "exists": <bool> }
//   The app reads $.exists via castToType<bool>(...)!  (NON-NULL bool required — see
//   forget_password_widget.dart), so "exists" must always be a present boolean.
//   400 { "error": "<msg>", "exists": false } on bad JSON.
//
// verify_jwt: FALSE (recovery is pre-authentication). Deploy with `--no-verify-jwt`.
//
// ENV (auto-provided): SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY. Reads public."user" with the
//   service-role client (see check-user-exist for the same ASSUMPTION about auth.users vs
//   public."user").

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
  if (req.method !== "POST") return json({ error: "Method not allowed", exists: false }, 405);

  let email = "";
  let mobile = "";
  try {
    const body = await req.json();
    email = (body?.email ?? "").toString().trim();
    mobile = (body?.mobile_number ?? "").toString().trim();
  } catch (_) {
    return json({ error: "Invalid JSON body", exists: false }, 400);
  }

  if (!email && !mobile) {
    return json({ error: "email or mobile_number is required", exists: false }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    let exists = false;

    if (email) {
      const { data, error } = await supabase
        .from("user")
        .select("id")
        .eq("email", email)
        .limit(1);
      if (error) return json({ error: error.message, exists: false }, 500);
      exists = (data?.length ?? 0) > 0;
    }

    if (!exists && mobile) {
      const { data, error } = await supabase
        .from("user")
        .select("id")
        .eq("mobile_number_cc", mobile)
        .limit(1);
      if (error) return json({ error: error.message, exists: false }, 500);
      exists = (data?.length ?? 0) > 0;
    }

    return json({ exists }, 200);
  } catch (err) {
    return json({ error: String(err), exists: false }, 500);
  }
});
