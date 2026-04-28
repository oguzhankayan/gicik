// POST /functions/v1/generate-replies
// Stage 2 — Reply generation via Anthropic Claude Sonnet 4.5 (streaming SSE).
//
// Flow:
//   1. JWT validate
//   2. Load conversation + profile
//   3. Free-tier check (3/day)
//   4. Build prompt: L0+L2+L4 (cached) + L1(mode) + tone + L4 fill
//   5. Stream Anthropic
//   6. Output filter — toxic positivity check on assembled replies
//   7. Persist generation_result, return final structured payload
//
// SSE events emitted:
//   data: {"type":"observation","text":"..."}
//   data: {"type":"reply","index":0,"tone_angle":"...","text":"..."}
//   data: {"type":"reply","index":1,...}
//   data: {"type":"reply","index":2,...}
//   data: {"type":"done","duration_ms":3421,"conversation_id":"..."}
//   data: {"type":"error","message":"..."}

import { preflightOk, errorResponse, corsHeaders } from "../_shared/cors.ts";
import { requireAuth, AuthError } from "../_shared/auth.ts";
import { loadFullPromptStack } from "../_shared/prompt-loader.ts";
import {
  buildSystemBlocks,
  streamAnthropic,
  anthropicCostUSD,
  hasToxicPositivity,
  type AnthropicUsage,
} from "../_shared/llm-client.ts";
import type { Mode, Tone, ParseResult, GenerationResult } from "../_shared/types.ts";

const FREE_DAILY_LIMIT = 3;

interface RequestBody {
  conversation_id: string;
  tone: Tone;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client, serviceClient } = await requireAuth(req);

    const body = (await req.json().catch(() => null)) as RequestBody | null;
    if (!body?.conversation_id || !body?.tone) {
      return errorResponse("invalid_input", "conversation_id + tone required");
    }
    const tone = body.tone;
    if (!["flortoz", "esprili", "direkt", "sicak", "gizemli"].includes(tone)) {
      return errorResponse("invalid_input", "invalid tone");
    }

    // ─── load conversation + profile ───
    const { data: conv, error: convErr } = await client
      .from("conversations")
      .select("id, mode, parse_result, screenshot_storage_path")
      .eq("id", body.conversation_id)
      .eq("user_id", userId)
      .maybeSingle();

    if (convErr || !conv) {
      return errorResponse("invalid_input", "conversation not found");
    }
    const mode = conv.mode as Mode;
    const parseResult = conv.parse_result as ParseResult;

    const { data: profile } = await client
      .from("profiles")
      .select("archetype_primary, archetype_secondary, calibration_data")
      .eq("id", userId)
      .maybeSingle();

    // ─── free tier check ───
    const { data: subState } = await client
      .from("subscription_state")
      .select("is_active")
      .eq("user_id", userId)
      .maybeSingle();

    if (!subState?.is_active) {
      const { data: usage } = await client
        .from("usage_daily")
        .select("generation_count")
        .eq("user_id", userId)
        .eq("date", new Date().toISOString().slice(0, 10))
        .maybeSingle();
      if ((usage?.generation_count ?? 0) >= FREE_DAILY_LIMIT) {
        return errorResponse("free_tier_exceeded", "günlük 3 cevap doldu", 402);
      }
    }

    // ─── prompt stack ───
    const promptStack = await loadFullPromptStack(client, mode, tone);
    const L4Filled = fillL4Template(promptStack.L4.content, {
      profile: profile ?? {},
      parseResult,
      mode,
      tone,
    });
    const systemBlocks = buildSystemBlocks({
      L0: promptStack.L0.content,
      L1: promptStack.L1.content,
      L2: promptStack.L2.content,
      L4: L4Filled,
      tone: promptStack.tone.content,
    });

    // ─── streaming response ───
    const startTime = Date.now();
    const stream = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();
        const send = (event: Record<string, unknown>) => {
          controller.enqueue(encoder.encode(`data: ${JSON.stringify(event)}\n\n`));
        };

        let assembled = "";
        let finalUsage: AnthropicUsage = { input_tokens: 0, output_tokens: 0 };

        const userMessage = buildUserPrompt(parseResult);

        try {
          for await (const evt of streamAnthropic({
            system: systemBlocks,
            messages: [{ role: "user", content: userMessage }],
            maxTokens: 1500,
            temperature: 0.85,
          })) {
            if (evt.type === "error") {
              send({ type: "error", message: evt.error });
              controller.close();
              return;
            }
            if (evt.type === "text_delta" && evt.text) {
              assembled += evt.text;
            }
            if (evt.type === "message_stop" && evt.usage) {
              finalUsage = evt.usage;
            }
          }
        } catch (e) {
          send({ type: "error", message: e instanceof Error ? e.message : String(e) });
          controller.close();
          return;
        }

        // Parse structured output (model returns JSON in assembled string)
        let structured: GenerationResult | null = null;
        try {
          structured = parseModelJSON(assembled, mode, tone);
        } catch (e) {
          send({ type: "error", message: `parse output failed: ${e instanceof Error ? e.message : e}` });
          controller.close();
          return;
        }

        if (!structured) {
          send({ type: "error", message: "empty output" });
          controller.close();
          return;
        }

        // Output filter — toxic positivity guard
        if (hasToxicPositivity(structured.observation)
          || structured.replies.some(r => hasToxicPositivity(r.text))) {
          // Log; do not retry inside same edge instance to avoid runaway cost.
          await serviceClient.from("security_events").insert({
            user_id: userId,
            event_type: "toxic_request",
            detected_pattern: "toxic positivity in output",
            action_taken: "flagged",
          });
        }

        // Emit observation
        send({ type: "observation", text: structured.observation });

        // Emit replies
        for (const r of structured.replies) {
          send({ type: "reply", index: r.index, tone_angle: r.tone_angle, text: r.text });
        }

        // Persist
        const cost = anthropicCostUSD(finalUsage);
        const durationMs = Date.now() - startTime;

        await serviceClient
          .from("conversations")
          .update({
            tone,
            generation_result: structured,
            generation_model: Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-5",
            generation_cost_usd: cost,
            generation_duration_ms: durationMs,
            prompt_version_id: promptStack.L1.id, // representative; multi-layer refs in calibration_data later
          })
          .eq("id", conv.id);

        await serviceClient.rpc("fn_increment_usage", { p_user_id: userId });

        await serviceClient
          .from("profiles")
          .update({
            total_generations: ((profile as { total_generations?: number } | null)?.total_generations ?? 0) + 1,
            last_active_at: new Date().toISOString(),
          })
          .eq("id", userId);

        send({ type: "done", duration_ms: durationMs, conversation_id: conv.id });
        controller.close();
      },
    });

    return new Response(stream, {
      headers: {
        ...corsHeaders,
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
      },
    });
  } catch (err) {
    if (err instanceof AuthError) return errorResponse("unauthenticated", err.message, err.status);
    console.error("generate-replies unexpected error", err);
    return errorResponse("internal", String(err), 500);
  }
});

// ──────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────

function buildUserPrompt(parse: ParseResult): string {
  const lines = [
    "konuşma çözümü:",
    JSON.stringify({
      platform: parse.platform_detected,
      messages: parse.messages,
      last_message_from: parse.last_message_from,
      tone_observed: parse.tone_observed,
      red_flags: parse.red_flags,
      context_summary: parse.context_summary_tr,
    }, null, 2),
    "",
    "JSON üret. observation alanı asistan sesi (lowercase, italik için işaretleme yok). replies 3 tane, farklı angle.",
    "schema:",
    `{
  "observation": "string (max 280 char, asistan sesi)",
  "replies": [
    {"index": 0, "tone_angle": "string", "text": "string (max 280 char, kullanıcının atacağı mesaj)"},
    {"index": 1, "tone_angle": "string", "text": "string"},
    {"index": 2, "tone_angle": "string", "text": "string"}
  ]
}`,
    "Sadece JSON dön, başka metin yok.",
  ];
  return lines.join("\n");
}

function parseModelJSON(raw: string, mode: Mode, tone: Tone): GenerationResult {
  // Strip code fences if model wrapped output
  let s = raw.trim();
  if (s.startsWith("```")) {
    s = s.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "");
  }
  const j = JSON.parse(s);
  if (typeof j.observation !== "string" || !Array.isArray(j.replies) || j.replies.length !== 3) {
    throw new Error("unexpected schema");
  }
  return {
    observation: j.observation,
    replies: j.replies.map((r: { index: number; tone_angle: string; text: string }, i: number) => ({
      index: typeof r.index === "number" ? r.index : i,
      tone_angle: String(r.tone_angle ?? ""),
      text: String(r.text ?? ""),
    })),
    duration_ms: 0,
  };
}

function fillL4Template(
  template: string,
  ctx: {
    profile: Record<string, unknown>;
    parseResult: ParseResult;
    mode: Mode;
    tone: Tone;
  },
): string {
  const cal = (ctx.profile.calibration_data ?? {}) as Record<string, unknown>;
  const traits = (cal.traits ?? {}) as Record<string, number | string>;
  const replacements: Record<string, string> = {
    archetype_primary: String(ctx.profile.archetype_primary ?? "unknown"),
    archetype_secondary: String(ctx.profile.archetype_secondary ?? "—"),
    directness: String(traits.directness ?? "0.5"),
    "humor.primary_type": "default",
    "humor.intensity": String(traits.humor_intensity ?? "0.5"),
    slang_level: String(traits.slang_level ?? "0.5"),
    "language.primary": "tr",
    english_mix_ratio: "0.1",
    top_context: "tinder",
    "boundaries.avoid": "klişe, toxic positivity",
    stage1_parse_json: JSON.stringify(ctx.parseResult, null, 2),
    mode: ctx.mode,
    tone: ctx.tone,
  };
  let out = template;
  for (const [k, v] of Object.entries(replacements)) {
    out = out.replaceAll(`{{ ${k} }}`, v);
  }
  return out;
}
