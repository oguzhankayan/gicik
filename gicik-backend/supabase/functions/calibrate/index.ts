// POST /functions/v1/calibrate
// Input: { answers: CalibrationAnswer[] }
// Output: ArchetypeResult (also written to profiles.calibration_data)
//
// Phase 1.4 — implementation lives in deriveArchetype.ts (master prompt §9).

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import type { CalibrationAnswer, ArchetypeResult } from "../_shared/types.ts";
import { deriveArchetype } from "./deriveArchetype.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client } = await requireAuth(req);

    const body = await req.json().catch(() => null);
    if (!body || !Array.isArray(body.answers)) {
      return errorResponse("invalid_input", "answers[] required");
    }
    const answers = body.answers as CalibrationAnswer[];

    // Deterministic derivation — same answers, same archetype.
    const result: ArchetypeResult = deriveArchetype(answers);

    // "bize biraz kendinden bahset" cevabı — eskiden writing_style_sample.
    // free_text answer'dan çekilip dedicated voice_sample kolonuna yazılır.
    // LLM prompt'una L4'te <user_voice> block olarak inject edilir.
    const voiceAnswer = answers.find(
      (a) => a.question_id === "writing_style_sample" || a.question_id === "voice_sample"
    );
    const voiceSample =
      typeof voiceAnswer?.free_text === "string"
        ? voiceAnswer.free_text.trim().slice(0, 500) || null
        : null;

    const { error } = await client
      .from("profiles")
      .update({
        archetype_primary: result.archetype_primary,
        archetype_secondary: result.archetype_secondary,
        calibration_data: result.full_profile,
        calibration_completed_at: new Date().toISOString(),
        voice_sample: voiceSample,
      })
      .eq("id", userId);

    if (error) {
      return errorResponse("internal", `db update failed: ${error.message}`, 500);
    }

    return jsonResponse(result);
  } catch (err) {
    if (err instanceof AuthError) {
      return errorResponse("unauthenticated", err.message, err.status);
    }
    console.error("calibrate error", err);
    return errorResponse("internal", String(err), 500);
  }
});
