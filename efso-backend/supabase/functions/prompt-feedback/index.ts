// POST /functions/v1/prompt-feedback
// User 👍 / 👎 + selected reply index logging.

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";

interface FeedbackBody {
  conversation_id: string;
  selected_reply_index?: number;
  feedback: "positive" | "negative";
  feedback_text?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client } = await requireAuth(req);

    const body = (await req.json().catch(() => null)) as FeedbackBody | null;
    if (!body?.conversation_id || !body?.feedback) {
      return errorResponse("invalid_input", "conversation_id and feedback required");
    }
    if (body.selected_reply_index !== undefined &&
      (body.selected_reply_index < 0 || body.selected_reply_index > 2)) {
      return errorResponse("invalid_input", "selected_reply_index must be 0-2");
    }

    const { error } = await client
      .from("conversations")
      .update({
        user_feedback: body.feedback,
        feedback_text: body.feedback_text ?? null,
        selected_reply_index: body.selected_reply_index ?? null,
      })
      .eq("id", body.conversation_id)
      .eq("user_id", userId);

    if (error) {
      return errorResponse("internal", `db update failed: ${error.message}`, 500);
    }

    return jsonResponse({ ok: true });
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    return errorResponse("internal", String(err), 500);
  }
});
