// supabase/functions/verify_otp/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.A/B/E, §8.9)
// NOTE: folder name uses an UNDERSCORE to match the endpoint the app calls: /functions/v1/verify_otp
//   (VerifiOtpCall in api_calls.dart line 64).
// Frontend caller: VerifiOtpCall — called by verify_page. HTTP 2xx = code accepted (the app
//   then runs the real signup / reset); non-2xx -> pinCodeError, reads $.error.
//
// STATUS: STUB — DEFERRED. OTP delivery/verification is not configured (stakeholder 2026-07-19).
//   This function MUST NOT fake-succeed a verification (that would pass a security step with no
//   real check — CLAUDE.md §6). It therefore returns a defined non-2xx "not configured" shape
//   and never confirms a code.
//
// REQUEST (POST): { "otp": "<code>", "email": "<email or ''>", "mobile_no_cc": "<E.164 or ''>" }
// RESPONSE:
//   503 { "success": false, "deferred": true, "error": "OTP verification is not configured yet" }
//
// verify_jwt: FALSE (pre-authentication). Deploy with `--no-verify-jwt`.
//
// TODO (real implementation): read public.user_login for the identifier (service-role only);
//   check otp matches AND expiry_date > now() AND attempt count within limit; on success clear
//   / consume the row and return 200 { success: true }; on failure return 4xx { error }.

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
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  // Deferred: never confirm a code without a real check.
  return json(
    {
      success: false,
      deferred: true,
      error: "OTP verification is not configured yet",
    },
    503,
  );
});
