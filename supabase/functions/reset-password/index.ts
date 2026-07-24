// supabase/functions/reset-password/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §5.E, §8.9)
// Frontend caller: ResetPasswordCall — called by reset_password after the (OTP) recovery step.
//   The app does NOT read this response or gate on it — it navigates to login regardless
//   (reset_password_widget.dart). So the shape below is for honesty/robustness, not app flow.
//
// STATUS: STUB — DEFERRED. Forgot/reset-password depends on OTP delivery, which is deferred
//   (stakeholder 2026-07-19). This function does NOT change any password (it would otherwise
//   be an unauthenticated password change with no verified proof-of-ownership — a security
//   hole). It returns a defined "not configured" shape.
//
// REQUEST (POST): { "phone": "<or ''>", "email": "<or ''>", "otp": "<code>", "new_password": "<pw>" }
// RESPONSE:
//   503 { "success": false, "deferred": true, "error": "Password reset is not configured yet" }
//
// verify_jwt: FALSE (recovery is pre-authentication). Deploy with `--no-verify-jwt`.
//
// TODO (real implementation, when OTP/email is enabled): verify the OTP in public.user_login
//   for the identifier (as verify_otp), then look up the auth user by email/phone and set the
//   new password via supabase.auth.admin.updateUserById (service-role). Alternatively use
//   admin.generateLink({ type: 'recovery' }) + provider email delivery. Enforce rate limits.

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

  // Deferred: never rotate a password without a verified proof-of-ownership.
  return json(
    {
      success: false,
      deferred: true,
      error: "Password reset is not configured yet",
    },
    503,
  );
});
