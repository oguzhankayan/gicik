// POST /functions/v1/generate-replies
// Stage 2 — Reply generation (Anthropic Claude Sonnet 4.5, streaming SSE)
// Phase 2.4 — full implementation.

import { preflightOk, errorResponse, corsHeaders } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import type { Mode, Tone } from "../_shared/types.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client } = await requireAuth(req);

    const body = await req.json().catch(() => null);
    if (!body?.conversation_id || !body?.tone) {
      return errorResponse("invalid_input", "conversation_id and tone required");
    }
    const conversationId = body.conversation_id as string;
    const tone = body.tone as Tone;

    // TODO Phase 2.4:
    // 1. Load conversation row + profile
    // 2. Check usage_daily limit (free tier: 3/day)
    // 3. Build prompt: L0 (cached) + L1(mode) + L2 (cached) + tone(selected) + L4 template
    // 4. Anthropic streaming API with cache_control on L0+L2+L3
    // 5. Stream tokens via SSE: observation, then 3 replies
    // 6. Output filter: detect toxic positivity → regenerate
    // 7. Update conversations row with generation_result

    return new Response(
      "data: " + JSON.stringify({
        type: "error",
        message: "generate-replies not implemented yet (Phase 2.4)"
      }) + "\n\n",
      {
        status: 501,
        headers: {
          ...corsHeaders,
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
        },
      },
    );
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    console.error("generate-replies error", err);
    return errorResponse("internal", String(err), 500);
  }
});
