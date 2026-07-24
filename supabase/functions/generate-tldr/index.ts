// supabase/functions/generate-tldr/index.ts
// Feature: (utility) AI TL;DR for long posts/comments.
// Frontend caller: GenerateTLDRCall — sends { comment_id, post_id, text } with the user JWT.
//
// STATUS: STUB — SKIPPED per stakeholder ("skip TLDR for now", 2026-07-19). Returns a benign
//   empty summary so any caller gets a well-formed, non-crashing response.
//
// REQUEST (POST): header Authorization: Bearer <userJWT>; body { comment_id, post_id, text }
// RESPONSE:
//   200 { "tldr": "" }   (empty summary — nothing generated)
//
// verify_jwt: FALSE for now (harmless no-op; the app sends a user token but nothing sensitive
//   happens here). When implemented for real, set verify_jwt = TRUE. Deploy with `--no-verify-jwt`.
//
// TODO (real implementation): call an AI provider (e.g. Anthropic/OpenAI) with a SERVER-SIDE
//   API key (Deno.env.get) to summarize `text`; optionally persist the summary keyed by
//   post_id/comment_id. Required secret then: e.g. ANTHROPIC_API_KEY / OPENAI_API_KEY.

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

  // Skipped: return a benign empty summary.
  return json({ tldr: "" }, 200);
});
