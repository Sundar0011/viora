// supabase/functions/authenticate-user/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.D, §8.10)
// Frontend caller: VaildateUserCall (lib/backend/api_requests/api_calls.dart) — used by
//   email_login_page and login_page as a PRE-FLIGHT credential check. If this returns HTTP
//   2xx the app then calls GoTrue signInWithPassword(email|phone, password) client-side to
//   establish the real session (actions/sign_in_with_email.dart, sign_in_with_phone.dart).
//   This function therefore only VERIFIES the credential — it does NOT return a session.
//
// STATUS: REAL (password-only auth, no external provider needed).
//
// REQUEST  (POST, application/json):
//   { "identifier": "<email OR phone>", "password": "<plaintext>" }
//   - identifier is an EMAIL when it contains "@", otherwise a PHONE. Phone identifiers are
//     already E.164 with the country code prepended by the app, e.g. "+441234567890"
//     (FFAppState().AsCountryCode defaults to "+44" — see login_page_widget.dart line 862).
//
// RESPONSE:
//   200 { "valid": true }                                  -> app proceeds to client sign-in
//   400 { "error": "<message>", "valid": false }           -> bad input
//   401 { "error": "<message>", "valid": false }           -> wrong credential
//   The app reads $.error via VaildateUserCall.error(json)! (NON-NULL required on failure),
//   and treats any non-2xx as failure (ApiCallResponse.succeeded = 2xx). So every non-2xx
//   response MUST carry a non-null "error" string.
//
// verify_jwt: FALSE (pre-authentication — the caller is not signed in yet; the app sends the
//   anon key as the Bearer token, not a user JWT). Deploy with `--no-verify-jwt`.
//
// ENV (auto-provided by Supabase to every Edge Function — NOT secrets you set):
//   SUPABASE_URL, SUPABASE_ANON_KEY. The credential is verified by attempting a GoTrue
//   password grant with the ANON key (identical to what the client will do), so no
//   service-role key is required here.

// Shared CORS headers (Flutter Web hits this cross-origin; mobile ignores CORS but it is harmless).
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Builds a JSON Response with CORS headers.
function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") {
    return json({ error: "Method not allowed", valid: false }, 405);
  }

  let identifier = "";
  let password = "";
  try {
    const body = await req.json();
    identifier = (body?.identifier ?? "").toString().trim();
    password = (body?.password ?? "").toString();
  } catch (_) {
    return json({ error: "Invalid JSON body", valid: false }, 400);
  }

  if (!identifier || !password) {
    return json({ error: "Identifier and password are required", valid: false }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) {
    return json({ error: "Auth service is not configured", valid: false }, 500);
  }

  // Detect email vs phone from the identifier format (an email always contains "@").
  const isEmail = identifier.includes("@");
  const grantBody = isEmail
    ? { email: identifier, password }
    : { phone: identifier, password };

  try {
    // Verify the credential with a GoTrue password grant using the ANON key — this mirrors
    // exactly the client-side signInWithPassword the app runs next. A session may be minted
    // here but is discarded (the function is ephemeral); we only care about success/failure.
    const resp = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: anonKey,
        Authorization: `Bearer ${anonKey}`,
      },
      body: JSON.stringify(grantBody),
    });

    if (resp.ok) {
      return json({ valid: true }, 200);
    }

    // GoTrue returns 400 for invalid credentials / unconfirmed accounts. Surface a clean,
    // non-null message for the app's .error() extractor.
    let message = "Invalid credentials";
    try {
      const err = await resp.json();
      message = err?.error_description || err?.msg || err?.message || message;
    } catch (_) { /* keep default */ }
    return json({ error: message, valid: false }, 401);
  } catch (err) {
    return json({ error: `Auth check failed: ${String(err)}`, valid: false }, 500);
  }
});
