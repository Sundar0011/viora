// supabase/functions/change-password/index.ts
// Feature: Authentication & Registration (docs/features/01-auth-registration.md §4)
// Frontend caller: ChangePasswordCall — called by profile/change_password with the SIGNED-IN
//   user's JWT as the Bearer token. On HTTP 2xx the app pops the screen; on non-2xx it reads
//   $.error via ChangePasswordCall.error(json)! (NON-NULL required — change_password_widget).
//
// STATUS: REAL.
//
// REQUEST: header  Authorization: Bearer <userJWT>
//          body    { "old_password": "<current>", "new_password": "<new>" }
//
// RESPONSE:
//   200 { "success": true }                        -> app pops the screen
//   400 { "error": "<msg>", "success": false }     -> bad input
//   401 { "error": "<msg>", "success": false }     -> no/invalid JWT, or wrong old password
//   500 { "error": "<msg>", "success": false }     -> server error
//   Every non-2xx MUST carry a non-null "error" string (the app dereferences it with `!`).
//
// verify_jwt: TRUE — this is an authenticated, owner-only operation. The user id comes ONLY
//   from the verified JWT (auth.uid()); a client-supplied id is NEVER trusted, so one user can
//   never change another user's password (CLAUDE.md §6). Deploy WITHOUT `--no-verify-jwt`
//   (platform validates the JWT); the function also re-validates via auth.getUser(token).
//
// ENV (auto-provided): SUPABASE_URL, SUPABASE_ANON_KEY (for the old-password re-check grant),
//   SUPABASE_SERVICE_ROLE_KEY (for admin.updateUserById).

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
  if (req.method !== "POST") return json({ error: "Method not allowed", success: false }, 405);

  // Extract the caller's JWT (the app sends Authorization: Bearer <userJWT>).
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : "";
  if (!token) return json({ error: "Missing authorization token", success: false }, 401);

  let oldPassword = "";
  let newPassword = "";
  try {
    const body = await req.json();
    oldPassword = (body?.old_password ?? "").toString();
    newPassword = (body?.new_password ?? "").toString();
  } catch (_) {
    return json({ error: "Invalid JSON body", success: false }, 400);
  }

  if (!oldPassword || !newPassword) {
    return json({ error: "old_password and new_password are required", success: false }, 400);
  }
  if (newPassword.length < 6) {
    return json({ error: "New password must be at least 6 characters", success: false }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  try {
    // 1) Resolve the caller from the JWT — this is the ONLY source of the target user id.
    const admin = createClient(supabaseUrl, serviceRoleKey);
    const { data: userData, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !userData?.user) {
      return json({ error: "Invalid or expired session", success: false }, 401);
    }
    const user = userData.user;

    // 2) Re-verify the OLD password with a password grant (owner proves they know it) using the
    //    email or phone on the account. Prevents a hijacked session from silently rotating the pw.
    const grantBody = user.email
      ? { email: user.email, password: oldPassword }
      : user.phone
        ? { phone: user.phone, password: oldPassword }
        : null;
    if (!grantBody) {
      return json({ error: "Account has no email or phone to verify against", success: false }, 400);
    }

    const grantResp = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: "POST",
      headers: { "Content-Type": "application/json", apikey: anonKey, Authorization: `Bearer ${anonKey}` },
      body: JSON.stringify(grantBody),
    });
    if (!grantResp.ok) {
      return json({ error: "Current password is incorrect", success: false }, 401);
    }

    // 3) Set the new password for THIS user only (id from the verified JWT).
    const { error: updErr } = await admin.auth.admin.updateUserById(user.id, {
      password: newPassword,
    });
    if (updErr) {
      return json({ error: updErr.message, success: false }, 400);
    }

    return json({ success: true }, 200);
  } catch (err) {
    return json({ error: String(err), success: false }, 500);
  }
});
