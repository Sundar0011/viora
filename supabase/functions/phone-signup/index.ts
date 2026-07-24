// supabase/functions/phone-signup/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.B, §8.3)
// Frontend caller: PhoneSignupCall — called by verify_page during PHONE signup to create the
//   phone auth user. Immediately afterwards the app calls signInWithPhone(phone, password)
//   (actions/sign_in_with_phone.dart) to get a session, then inserts the public rows. The app
//   does NOT read this function's response body or gate on it (verify_page_widget.dart line
//   633: result stored in _model.phoneSignUp but never checked) — it only needs the auth user
//   to actually exist so the subsequent signInWithPassword succeeds.
//
// STATUS: REAL — but see the NO-OTP-GATE note below.
//
// !! NO OTP GATE (stakeholder direction 2026-07-19: password-only auth, OTP deferred): the
//    legacy flow gated this behind a successful verify_otp. Because OTP delivery/verification
//    is deferred, this function creates the user WITHOUT any prior OTP check. The phone is
//    created already-confirmed (phone_confirm: true) so the immediate password sign-in works.
//    When an SMS provider is added, restore the OTP gate (verify the code in public.user_login
//    before creating the user, or move creation into verify_otp).
//
// !! LEAKED-SECRET REMOVED (CLAUDE.md §5, docs §8.3): the current frontend sends a client-side
//    `x-secret-key: <FFDevEnvironmentValues().secretKey>` header (a leaked secret). This
//    function DELIBERATELY DOES NOT require or read that header. The secret must be rotated
//    and the client stop sending it. No server-side secret arg is needed here because account
//    creation is idempotent-guarded and inputs are validated; if abuse becomes a concern, add
//    a CAPTCHA/turnstile check or an `app.phone_signup_secret` GUC per CLAUDE.md §6.5.
//
// REQUEST (POST, application/json):
//   { "phone": "<E.164 with CC, e.g. +441234567890>", "password": "<pw>", "confirmPassword": "<pw>" }
//
// RESPONSE:
//   200 { "success": true, "user_id": "<uuid>" }             -> user created (or already existed)
//   400 { "error": "<msg>", "success": false }               -> bad input / weak password
//   500 { "error": "<msg>", "success": false }               -> server/config error
//   (The app ignores the body; shapes are defined for robustness and future callers.)
//
// verify_jwt: FALSE (signup is pre-authentication). Deploy with `--no-verify-jwt`.
//
// ENV (auto-provided): SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY. admin.createUser requires the
//   service-role key (kept server-side only — never in the client).

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  // x-secret-key is accepted in the preflight allow-list only so the current client's request
  // does not fail CORS — the value is ignored server-side (see note above).
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-secret-key",
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
  if (req.method !== "POST") return json({ error: "Method not allowed", success: false }, 405);

  let phone = "";
  let password = "";
  let confirmPassword = "";
  try {
    const body = await req.json();
    phone = (body?.phone ?? "").toString().trim();
    password = (body?.password ?? "").toString();
    confirmPassword = (body?.confirmPassword ?? "").toString();
  } catch (_) {
    return json({ error: "Invalid JSON body", success: false }, 400);
  }

  // Validate inputs (never trust the client). E.164-ish: leading + and 8-15 digits.
  if (!phone || !/^\+?[1-9]\d{7,14}$/.test(phone)) {
    return json({ error: "A valid phone number (with country code) is required", success: false }, 400);
  }
  if (!password || password.length < 6) {
    return json({ error: "Password must be at least 6 characters", success: false }, 400);
  }
  if (password !== confirmPassword) {
    return json({ error: "Passwords do not match", success: false }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    // Create the auth user with the phone already confirmed (no OTP step — see header note).
    const { data, error } = await supabase.auth.admin.createUser({
      phone,
      password,
      phone_confirm: true,
    });

    if (error) {
      // Duplicate phone -> GoTrue returns an "already registered" error. Surface it cleanly;
      // CheckUserExist should have blocked this earlier in the happy path.
      return json({ error: error.message, success: false }, 400);
    }

    return json({ success: true, user_id: data.user?.id ?? null }, 200);
  } catch (err) {
    return json({ error: String(err), success: false }, 500);
  }
});
