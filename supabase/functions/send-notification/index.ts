// supabase/functions/send-notification/index.ts
// Purpose: Batch 7 (Notifications) — FCM push delivery. Invoked by the
// `trg_push_new_notification` trigger (supabase/migrations/0082_notifications_push_realtime.sql)
// via pg_net immediately after a row is inserted into public.notifications. Looks up the
// receiver's public.user_devices.fcm_token row(s) and sends a push through Firebase Cloud
// Messaging's HTTP v1 API (per docs/features/11-notifications.md §6 and CLAUDE.md §6 — push
// delivery must run server-side, never from the client).
//
// REQUIRED SECRETS (set via `supabase secrets set`, NEVER committed, NEVER in
// assets/environment_values/ or lib/ — CLAUDE.md §5):
//   FCM_SERVICE_ACCOUNT_JSON — the full Firebase service-account JSON key (as a single-line
//     string), used to mint short-lived OAuth2 access tokens for the FCM v1 API. The service
//     account's `project_id` field also supplies the FCM v1 endpoint's project id — no separate
//     "FCM project id" secret is needed.
//
// REQUIRED ENV (set automatically by Supabase for every Edge Function — NOT a secret you set):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY — used to read public.user_devices with the
//   service-role key (bypasses RLS; this function is server-side/service-role only, never
//   callable by a client with the anon key — see the trigger's Authorization: Bearer <service_role_key> header).
//
// CALLER CONTRACT (matches the trigger's body exactly):
//   POST { notification_id, receiver_id, sender_id, type, title, content }
//   Auth: Authorization: Bearer <service_role_key> (set by the DB trigger via
//   current_setting('app.settings.service_role_key')) — this function does NOT re-validate the
//   caller's JWT beyond what the Edge Function platform itself enforces; it trusts only the
//   service-role-authenticated pg_net call from the trigger, never a client-supplied request.
//
// MANUAL SETUP STEPS (I will deploy the function; the user sets the secrets — see final summary):
//   1. `supabase functions deploy send-notification`
//   2. `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<paste the full JSON, single line>'`
//   3. Set the two Postgres custom GUCs the trigger reads (see 0082's header comment):
//      app.settings.edge_function_url, app.settings.service_role_key.

import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

interface NotificationPayload {
  notification_id: string;
  receiver_id: string;
  sender_id: string;
  type: string | null;
  title: string | null;
  content: string;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

// Mints a short-lived OAuth2 access token for the FCM v1 API using the service account's RSA key
// (JWT bearer flow, RFC 7523) — no third-party OAuth library needed beyond `jose` for RS256 signing.
async function getFcmAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const privateKey = await importPKCS8(sa.private_key, "RS256");

  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!resp.ok) {
    throw new Error(`getFcmAccessToken: token request failed (${resp.status}): ${await resp.text()}`);
  }

  const json = await resp.json();
  return json.access_token as string;
}

// Sends one FCM v1 message to a single device token. Carries a squadd:// deep-link `url` in
// `data` so the client's existing setup_notifications.dart tap-routing keeps working unchanged.
async function sendFcmMessage(
  sa: ServiceAccount,
  accessToken: string,
  fcmToken: string,
  payload: NotificationPayload,
): Promise<Response> {
  const url = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;

  const body = {
    message: {
      token: fcmToken,
      notification: {
        title: payload.title ?? "Viora",
        body: payload.content,
      },
      data: {
        type: payload.type ?? "",
        notification_id: payload.notification_id,
        // TODO(confirm): the exact squadd:// deep-link route per type — mirrors
        // notification_widget.dart's own type -> screen routing table
        // (docs/features/11-notifications.md §5), left generic here pending confirmation.
        url: `squadd://loadingPage?notificationId=${payload.notification_id}`,
      },
    },
  };

  return fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify(body),
  });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Service-role-only: this function is invoked ONLY by the notifications push trigger
  // (0082, via pg_net with Authorization: Bearer <service_role_key>). Reject any other caller
  // (e.g. a signed-in user with their own JWT) so it can't be used to spam arbitrary pushes.
  const authHeader = req.headers.get("Authorization") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!serviceRoleKey || authHeader !== `Bearer ${serviceRoleKey}`) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
  }

  try {
    const payload = (await req.json()) as NotificationPayload;

    if (!payload.receiver_id || !payload.content) {
      return new Response(JSON.stringify({ error: "receiver_id and content are required" }), {
        status: 400,
      });
    }

    const saJson = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
    if (!saJson) {
      // Fails loudly in the function's own logs, but the trigger that called this function
      // already wrapped its pg_net call in a best-effort exception guard (0082), so a missing
      // secret here never breaks the notification write itself.
      return new Response(JSON.stringify({ error: "FCM_SERVICE_ACCOUNT_JSON not configured" }), {
        status: 500,
      });
    }
    const sa: ServiceAccount = JSON.parse(saJson);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    // reuse serviceRoleKey from the auth guard above (guaranteed non-empty there)
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: devices, error } = await supabase
      .from("user_devices")
      .select("fcm_token")
      .eq("user_id", payload.receiver_id);

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }
    if (!devices || devices.length === 0) {
      return new Response(JSON.stringify({ sent: 0, reason: "no registered devices" }), {
        status: 200,
      });
    }

    const accessToken = await getFcmAccessToken(sa);

    const results = await Promise.all(
      devices.map((d) => sendFcmMessage(sa, accessToken, d.fcm_token, payload)),
    );

    const sent = results.filter((r) => r.ok).length;
    return new Response(JSON.stringify({ sent, attempted: results.length }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
