// supabase/functions/send-otp/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.A/B/E, §8.9)
// Frontend caller: SendOtpCall — called by final_steps_mail/phone, forget_password, and
//   verify_page (resend). The app treats HTTP 2xx as "sent" and proceeds to verify_page; on
//   non-2xx it blocks and reads $.error via SendOtpCall.error(json).
//
// STATUS: STUB — DEFERRED (stakeholder direction 2026-07-19: "no need to send SMS / no need to
//   send email"). OTP delivery is intentionally NOT configured yet. This function does NOT
//   deliver a code and does NOT write public.user_login. It returns a defined, honest
//   "not configured" shape and NEVER leaks a code in the response.
//
// CONSEQUENCE (flag for the main thread): because this returns non-2xx, the OTP-gated flows
//   (email signup, phone signup, forgot-password) are BLOCKED at this step in the current
//   frontend. Password LOGIN (authenticate-user) and Google signup are unaffected. Resolving
//   this requires either (a) enabling a real SMS/email provider, or (b) a frontend change to
//   skip the OTP step while OTP is deferred. That reconciliation is a stakeholder decision.
//
// REQUEST (POST): { "mobile_no_cc": "<E.164 or ''>", "email": "<email or ''>" }
// RESPONSE:
//   503 { "success": false, "deferred": true, "error": "OTP delivery is not configured yet" }
//
// verify_jwt: FALSE (pre-authentication). Deploy with `--no-verify-jwt`.
//
// TODO (real implementation, when a provider is chosen):
//   1. Validate identifier; enforce rate limit by reading public.user_login (no_of_times,
//      last_requested_date) for this email/mobile_no_cc within the window.
//   2. Generate a 6-digit code; upsert public.user_login { otp, expiry_date = now()+INTERVAL,
//      no_of_times += 1, last_requested_date = now() } keyed by identifier (service-role only).
//   3. Deliver via the SMS (e.g. Twilio) / email (e.g. Resend) provider using a SERVER-SIDE
//      secret (Deno.env.get) — never return the code in the response.
//   Required secrets then: e.g. TWILIO_* / RESEND_API_KEY (set via `supabase secrets set`).

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

  // Deferred: no delivery, no user_login write, no code in the response.
  return json(
    {
      success: false,
      deferred: true,
      error: "OTP delivery is not configured yet",
    },
    503,
  );
});
