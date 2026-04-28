// POST /functions/v1/parse-screenshot
// Stage 1 — Vision parse via Gemini 2.5 Flash.
//
// Flow:
//   1. JWT validate, user_id extract
//   2. multipart parse (screenshot + mode)
//   3. Rate limit check (10/min/user)
//   4. Upload to storage: screenshots/<user_id>/<uuid>.<ext>
//   5. Call Gemini with stage1_parser prompt + image
//   6. Validate ParseResult schema
//   7. If injection_attempt → log security_event, return 422
//   8. Insert conversations row, return { conversation_id, parse_result }

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import { loadPrompt } from "../_shared/prompt-loader.ts";
import { callVisionParse, visionCostUSD } from "../_shared/llm-client.ts";
import type { Mode, ParseResult } from "../_shared/types.ts";

const ALLOWED_MIME = new Set(["image/jpeg", "image/png", "image/heic", "image/webp"]);
const MAX_BYTES = 10 * 1024 * 1024;
const RATE_LIMIT_PER_MIN = 10;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client, serviceClient } = await requireAuth(req);

    // ─── parse multipart ───
    const formData = await req.formData();
    const screenshot = formData.get("screenshot");
    const modeStr = formData.get("mode") as string | null;

    if (!(screenshot instanceof File)) {
      return errorResponse("invalid_input", "screenshot file required");
    }
    if (!modeStr || !["cevap", "acilis", "bio", "hayalet", "davet"].includes(modeStr)) {
      return errorResponse("invalid_input", "valid mode required");
    }
    const mode = modeStr as Mode;

    if (!ALLOWED_MIME.has(screenshot.type)) {
      return errorResponse("unsupported_image", `mime ${screenshot.type} not allowed`);
    }
    if (screenshot.size > MAX_BYTES) {
      return errorResponse("invalid_input", `file too large (max ${MAX_BYTES} bytes)`);
    }

    // ─── rate limit ───
    const sinceISO = new Date(Date.now() - 60_000).toISOString();
    const { count: recentCount, error: rlErr } = await serviceClient
      .from("conversations")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", sinceISO);

    if (rlErr) {
      console.error("rate limit query failed", rlErr);
    } else if ((recentCount ?? 0) >= RATE_LIMIT_PER_MIN) {
      return errorResponse("rate_limited", "10/min limit", 429);
    }

    // ─── upload to storage ───
    const ext = mimeToExt(screenshot.type);
    const objectId = crypto.randomUUID();
    const storagePath = `${userId}/${objectId}.${ext}`;

    const fileBytes = new Uint8Array(await screenshot.arrayBuffer());

    const { error: uploadErr } = await client.storage
      .from("screenshots")
      .upload(storagePath, fileBytes, {
        contentType: screenshot.type,
        upsert: false,
      });

    if (uploadErr) {
      console.error("storage upload failed", uploadErr.message);
      return errorResponse("internal", "upload failed", 500);
    }

    // ─── call vision LLM (GPT-4o-mini) ───
    const { content: stage1Prompt } = await loadPrompt(client, { layer: "stage1" });

    const imageBase64 = bytesToBase64(fileBytes);
    let parseResp;
    try {
      parseResp = await callVisionParse({
        systemPrompt: stage1Prompt,
        imageBase64,
        imageMimeType: screenshot.type,
      });
    } catch (e) {
      console.error("vision parse failed", e instanceof Error ? e.message : e);
      return errorResponse("llm_failure", "vision parse failed", 502);
    }

    const parsed: ParseResult = parseResp.parseResult;

    // ─── validate ───
    if (!parsed.messages || parsed.messages.length === 0) {
      return errorResponse("unsupported_image", "no conversation found in image");
    }

    if (parsed.injection_attempt) {
      // Log + return clean error (no leak of injection content)
      await serviceClient.from("security_events").insert({
        user_id: userId,
        event_type: "prompt_injection",
        detected_pattern: "injection_attempt flag set by stage1",
        raw_input_hash: await sha256Hex(fileBytes),
        action_taken: "blocked",
      });
      return errorResponse("injection_blocked", "image contained injection attempt", 422);
    }

    // ─── insert conversation row ───
    const cost = visionCostUSD(parseResp.usage);
    const { data: conv, error: insertErr } = await serviceClient
      .from("conversations")
      .insert({
        user_id: userId,
        mode,
        tone: "esprili", // placeholder; updated when /generate-replies is called
        screenshot_storage_path: storagePath,
        parse_result: parsed,
        parse_model: parseResp.model,
        parse_cost_usd: cost,
        parse_duration_ms: parseResp.durationMs,
      })
      .select("id")
      .single();

    if (insertErr || !conv) {
      console.error("conversations insert failed", insertErr?.message);
      return errorResponse("internal", "db insert failed", 500);
    }

    return jsonResponse({
      conversation_id: conv.id,
      parse_result: parsed,
      duration_ms: parseResp.durationMs,
    });
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    console.error("parse-screenshot unexpected error", err);
    return errorResponse("internal", String(err), 500);
  }
});

function mimeToExt(mime: string): string {
  switch (mime) {
    case "image/jpeg": return "jpg";
    case "image/png": return "png";
    case "image/heic": return "heic";
    case "image/webp": return "webp";
    default: return "bin";
  }
}

function bytesToBase64(bytes: Uint8Array): string {
  // Chunked to avoid call-stack limits
  const chunkSize = 0x8000;
  let binary = "";
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode.apply(
      null,
      Array.from(bytes.subarray(i, i + chunkSize)) as unknown as number[],
    );
  }
  return btoa(binary);
}

async function sha256Hex(bytes: Uint8Array): Promise<string> {
  const hash = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
