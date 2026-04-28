// POST /functions/v1/parse-screenshot
// Stage 1 — Vision parse (Gemini 2.5 Flash)
// Phase 2.3 — full implementation. This is the skeleton.

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import type { Mode } from "../_shared/types.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client } = await requireAuth(req);

    const formData = await req.formData();
    const screenshot = formData.get("screenshot");
    const mode = formData.get("mode") as Mode | null;

    if (!(screenshot instanceof File)) {
      return errorResponse("invalid_input", "screenshot file required");
    }
    if (!mode) {
      return errorResponse("invalid_input", "mode required");
    }

    // TODO Phase 2.3:
    // 1. Upload to storage: screenshots/<userId>/<uuid>.<ext>
    // 2. Call Gemini 2.5 Flash with vision input + structured JSON schema
    // 3. Validate ParseResult schema
    // 4. Check injection_attempt; if true → log to security_events, return 422
    // 5. Insert conversations row, return { conversation_id, parse_result }
    // 6. Rate limit: 10/min/user

    return errorResponse("internal", "parse-screenshot not implemented yet (Phase 2.3)", 501);
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    console.error("parse-screenshot error", err);
    return errorResponse("internal", String(err), 500);
  }
});
