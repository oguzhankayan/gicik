// POST /functions/v1/create-text-conversation
// Tonla modu için text-only conversation row açar (ss + parse yok).
//
// Body:
//   { mode: "tonla", draft: string, context_message?: string }
//
// Response:
//   { conversation_id: string }
//
// Sonra iOS standart /generate-replies'i conversation_id ile çağırır.

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import type { Mode } from "../_shared/types.ts";

const MAX_DRAFT_CHARS = 1500;
const MAX_CONTEXT_CHARS = 1500;

interface RequestBody {
  mode: Mode;
  draft: string;
  context_message?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, serviceClient } = await requireAuth(req);

    const body = (await req.json().catch(() => null)) as RequestBody | null;
    if (!body) return errorResponse("invalid_input", "json body required");

    if (body.mode !== "tonla") {
      return errorResponse("invalid_input", "this endpoint only supports tonla mode");
    }

    const draft = (body.draft ?? "").trim();
    if (!draft) {
      return errorResponse("invalid_input", "draft empty");
    }
    if (draft.length > MAX_DRAFT_CHARS) {
      return errorResponse("invalid_input", `draft too long (max ${MAX_DRAFT_CHARS})`);
    }

    const context = (body.context_message ?? "").trim();
    if (context.length > MAX_CONTEXT_CHARS) {
      return errorResponse("invalid_input", `context too long (max ${MAX_CONTEXT_CHARS})`);
    }

    // parse_result alanı schema-uyumlu olacak şekilde dolduruluyor:
    // generate-replies hem chat hem profile hem draft cases'i okuyor.
    const parseResult = {
      screenshot_type: "draft" as const,
      participants: [{ role: "user" as const, name: null }],
      messages: [],
      last_message_from: null,
      user_draft: draft,
      context_message: context || null,
      platform_detected: "unknown",
      tone_observed: "neutral",
      red_flags: [],
      context_summary_tr: context
        ? "kullanıcı taslağı + karşı tarafın son mesajı"
        : "kullanıcı taslağı",
      injection_attempt: false,
      image_quality: "good" as const,
    };

    const { data: conv, error: insertErr } = await serviceClient
      .from("conversations")
      .insert({
        user_id: userId,
        mode: body.mode,
        tone: "esprili", // generate-replies çağrılınca güncellenir
        screenshot_storage_path: null,
        parse_result: parseResult,
        parse_model: "draft",
        parse_cost_usd: 0,
        parse_duration_ms: 0,
      })
      .select("id")
      .single();

    if (insertErr || !conv) {
      console.error("conversations insert failed", insertErr?.message);
      return errorResponse("internal", "db insert failed", 500);
    }

    return jsonResponse({ conversation_id: conv.id });
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    console.error("create-text-conversation unexpected error", err);
    return errorResponse("internal", String(err), 500);
  }
});
