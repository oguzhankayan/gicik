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
import { loadPrompt } from "../_shared/prompt-loader.ts";
import { todayIstanbulISODate } from "../_shared/dates.ts";
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
  // Ton kullanıcıdan alınmıyor — backend 3 ton birden seçer ve injektion yapar.
  // Geriye uyumluluk için opsiyonel: verilirse 3 reply de bu tek tonda üretilir
  // ('advanced mode' için bekleniyor).
  tone?: Tone;
}

/// Mode başına default 3-ton kombosu.
/// - cevap: flörtöz/esprili/direkt
/// - acilis: archetype-aware (aşağıda openerTones), default flörtöz/esprili/direkt
/// - tonla: kullanıcı tonu zorunlu seçer; default 3 farklı ton anlamsız.
///   yine de body.tone yoksa fallback için esprili×3 kullanılır.
/// - davet: direkt/flörtöz/esprili (teklif somut + oyun)
const TONES_BY_MODE: Record<Mode, Tone[]> = {
  cevap: ["flortoz", "esprili", "direkt"],
  acilis: ["flortoz", "esprili", "direkt"],
  tonla: ["esprili", "esprili", "esprili"], // fallback; tonla'da body.tone gelir
  davet: ["direkt", "flortoz", "esprili"],
};

/// Açılış modu için arketipe göre HERO tone (replies[0]) seçimi.
/// Hero, ResultView'da primary kart olarak öne çıkar — arketipin doğal sesine
/// en yakın opener orada parlasın. Diğer 2 ton kalan ikiyi alır (sıra korunur).
const OPENER_LEAD_BY_ARCHETYPE: Record<string, Tone> = {
  dryroaster: "direkt",
  observer: "esprili",
  softie_with_edges: "flortoz",
  chaos_agent: "flortoz",
  strategist: "direkt",
  romantic_pessimist: "esprili",
};

/// Açılış için 3 ton kümesini lead'e göre yeniden sırala.
/// Set sabit (flortoz/esprili/direkt) — sadece sıra arketipe uyar.
function openerTonesFor(archetype: string | null | undefined): Tone[] {
  const base: Tone[] = ["flortoz", "esprili", "direkt"];
  const lead: Tone = (archetype ? OPENER_LEAD_BY_ARCHETYPE[archetype] : undefined) ?? "flortoz";
  const rest = base.filter(t => t !== lead);
  return [lead, ...rest];
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();
  if (req.method !== "POST") return errorResponse("invalid_input", "POST only", 405);

  try {
    const { userId, client, serviceClient } = await requireAuth(req);

    const body = (await req.json().catch(() => null)) as RequestBody | null;
    if (!body?.conversation_id) {
      return errorResponse("invalid_input", "conversation_id required");
    }

    // ─── load conversation + profile ───
    const { data: conv, error: convErr } = await client
      .from("conversations")
      .select("id, mode, parse_result, screenshot_storage_path, extra_context")
      .eq("id", body.conversation_id)
      .eq("user_id", userId)
      .maybeSingle();

    if (convErr || !conv) {
      return errorResponse("invalid_input", "conversation not found");
    }
    const mode = conv.mode as Mode;
    const parseResult = conv.parse_result as ParseResult;

    // tonla'nın imzası: tek tone, üç açı. body.tone yoksa üretim
    // anlamlı değil (3 reply de hardcoded "esprili" çıkar). Erken dur.
    if (mode === "tonla" && !body.tone) {
      return errorResponse("invalid_input", "tonla için tone zorunlu", 422);
    }

    const { data: profile } = await client
      .from("profiles")
      .select("archetype_primary, archetype_secondary, calibration_data, voice_sample, gender, age_bracket, intent")
      .eq("id", userId)
      .maybeSingle();

    // Advanced mode: kullanıcı tek bir ton zorlamak istediyse o tonu kullan.
    // Default: mode'a özgü 3 farklı ton ile çeşitlendir.
    // Açılış için sıra arketipe göre değişir — hero (replies[0]) arketibin
    // doğal sesi.
    const tonesToUse: Tone[] = body.tone
      ? [body.tone, body.tone, body.tone]
      : (mode === "acilis"
          ? openerTonesFor(profile?.archetype_primary as string | null | undefined)
          : (TONES_BY_MODE[mode] ?? ["flortoz", "esprili", "direkt"]));

    // ─── free tier check ───
    const { data: subState } = await client
      .from("subscription_state")
      .select("is_active")
      .eq("user_id", userId)
      .maybeSingle();

    // Bugünkü usage row'unu hem free tier check'i hem cost ceiling
    // kontrolü hem de response'taki remaining_today için tek seferde çek.
    // "bugün" boundary'si Europe/Istanbul (brand TR-first); UTC ile mismatch
    // yapardı (sınır saatlerde reset farklı). Bkz. _shared/dates.ts.
    const today = todayIstanbulISODate();
    const { data: usage } = await client
      .from("usage_daily")
      .select("generation_count, llm_cost_usd")
      .eq("user_id", userId)
      .eq("date", today)
      .maybeSingle();
    const todayCount = usage?.generation_count ?? 0;
    const todayCostUSD = (usage?.llm_cost_usd as number | null) ?? 0;

    if (!subState?.is_active) {
      if (todayCount >= FREE_DAILY_LIMIT) {
        return errorResponse("free_tier_exceeded", "günlük 3 cevap doldu", 402);
      }
    }

    // CLAUDE.md mandate: per-user $0.50/gün LLM cost ceiling. Premium dahil
    // sınırsız üretim ama cost drain'e karşı server-side hard cap. Kullanıcı
    // çok denerse ya prompt stack şişmiş ya kötü niyet — her iki halde de
    // kapat. Free zaten 3/gün ile sınırlı, bu cap pratikte premium için.
    const COST_CEILING_USD = 0.50;
    if (todayCostUSD >= COST_CEILING_USD) {
      console.warn(`cost ceiling hit: user=${userId} cost=${todayCostUSD}`);
      return errorResponse(
        "rate_limited",
        "günlük üretim limitin doldu, yarın tekrar dene",
        429
      );
    }

    // ─── prompt stack ───
    // 3 ton'u beraber inject et — model her reply için ayrı ton kullanacak.
    // Archetype prompt'u kullanıcının primary archetype'ından çekilir.
    // Profilde archetype yoksa fallback "observer" — en nötr tarz.
    const archetypeKey = (
      profile?.archetype_primary as
        | "dryroaster" | "observer" | "softie_with_edges"
        | "chaos_agent" | "strategist" | "romantic_pessimist"
        | undefined
    ) ?? "observer";

    const [L0, L1, L2, L4Raw, tonePrompts, archetypePrompt] = await Promise.all([
      loadPrompt(client, { layer: "L0" }),
      loadPrompt(client, { layer: "L1", mode }),
      loadPrompt(client, { layer: "L2" }),
      loadPrompt(client, { layer: "L4" }),
      Promise.all(tonesToUse.map(t => loadPrompt(client, { layer: "tone", tone: t }))),
      loadPrompt(client, { layer: "archetype", archetype: archetypeKey })
        .catch(() => null), // archetype prompt yoksa graceful fallback
    ]);

    const tonesBlock = tonesToUse.map((t, i) =>
      `--- TON ${i + 1} (${t}) ---\n${tonePrompts[i].content}`
    ).join("\n\n");

    const L4Filled = fillL4Template(L4Raw.content, {
      profile: profile ?? {},
      parseResult,
      mode,
      tone: tonesToUse[0],   // L4'te en çok ilk tonu referans alır; gerçek 3 ton aşağıda
      voiceSample: (profile as { voice_sample?: string | null } | null)?.voice_sample ?? null,
      extraContext: (conv as { extra_context?: string | null }).extra_context ?? null,
    });

    const systemBlocks = buildSystemBlocks({
      L0: L0.content,
      L1: L1.content,
      L2: L2.content,
      L4: L4Filled,
      tone: tonesBlock,
      archetype: archetypePrompt?.content,
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

        const userMessage = buildUserPrompt(parseResult, tonesToUse, mode);

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
          structured = parseModelJSON(assembled, mode, tonesToUse);
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
          send({ type: "reply", index: r.index, tone: r.tone, text: r.text });
        }

        // Persist
        const cost = anthropicCostUSD(finalUsage);
        const durationMs = Date.now() - startTime;

        await serviceClient
          .from("conversations")
          .update({
            // 'tone' col DB schema'sında tek değer; varyasyonlar reply içinde duruyor
            tone: tonesToUse[0],
            generation_result: structured,
            generation_model: Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6",
            generation_cost_usd: cost,
            generation_duration_ms: durationMs,
            prompt_version_id: L1.id,
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

        // remaining_today: client'ın quota chip'i için server-truth.
        // Bu üretim DB'ye yazılmadan önce hesaplandığından +1 yapıyoruz.
        // Premium ise null (sınırsız).
        const newCount = todayCount + 1;
        const remainingToday = subState?.is_active
          ? null
          : Math.max(0, FREE_DAILY_LIMIT - newCount);
        send({
          type: "done",
          duration_ms: durationMs,
          conversation_id: conv.id,
          remaining_today: remainingToday,
          is_premium: subState?.is_active === true,
        });
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

function buildUserPrompt(parse: ParseResult, tones: Tone[], mode: Mode): string {
  const tonesList = tones.map((t, i) => `  ${i}: ${t}`).join("\n");

  // 3 input shape:
  // 1. tonla: user_draft + optional context_message (ss yok)
  // 2. açılış: profil verisi
  // 3. cevap/davet: chat mesajları
  const p = parse as ParseResult & {
    screenshot_type?: string;
    user_draft?: string;
    context_message?: string | null;
  };

  const isDraft = mode === "tonla" || p.screenshot_type === "draft";
  const isProfile = !isDraft && (
    mode === "acilis"
    || p.screenshot_type === "profile"
    || (Array.isArray(parse.messages) && parse.messages.length === 0 && parse.profile)
  );

  let inputLabel: string;
  let inputPayload: Record<string, unknown>;

  if (isDraft) {
    inputLabel = "kullanıcı taslağı:";
    inputPayload = {
      user_draft: p.user_draft ?? "",
      context_message: p.context_message ?? null,
      target_tone: tones[0],
    };
  } else if (isProfile) {
    inputLabel = "profil çözümü:";
    inputPayload = {
      platform: parse.platform_detected,
      profile: parse.profile ?? {},
      red_flags: parse.red_flags,
      context_summary: parse.context_summary_tr,
    };
  } else {
    inputLabel = "konuşma çözümü:";
    inputPayload = {
      platform: parse.platform_detected,
      messages: parse.messages,
      last_message_from: parse.last_message_from,
      tone_observed: parse.tone_observed,
      red_flags: parse.red_flags,
      context_summary: parse.context_summary_tr,
    };
  }

  const lines = [
    inputLabel,
    JSON.stringify(inputPayload, null, 2),
    "",
    "kullanılacak tonlar (her reply için sırayla):",
    tonesList,
    "",
    "3 cevap üret, hepsi aynı arketipten ama yukarıdaki sıraya göre 3 farklı tonda.",
    "observation alanı asistan sesi (lowercase, kısa, gözlem).",
    "schema:",
    `{
  "observation": "string (max 280 char, asistan sesi)",
  "replies": [
    {"index": 0, "tone": "${tones[0]}", "text": "string (max 280 char)"},
    {"index": 1, "tone": "${tones[1]}", "text": "string"},
    {"index": 2, "tone": "${tones[2]}", "text": "string"}
  ]
}`,
    "Sadece JSON dön, başka metin yok.",
  ];
  return lines.join("\n");
}

function parseModelJSON(raw: string, _mode: Mode, fallbackTones: Tone[]): GenerationResult {
  let s = raw.trim();
  if (s.startsWith("```")) {
    s = s.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "");
  }
  const j = JSON.parse(s);
  if (typeof j.observation !== "string" || !Array.isArray(j.replies)) {
    throw new Error("unexpected schema");
  }
  return {
    observation: j.observation,
    replies: j.replies.map((r: { index: number; tone?: string; text: string }, i: number) => ({
      index: typeof r.index === "number" ? r.index : i,
      tone: (r.tone as Tone | "silence") ?? fallbackTones[i] ?? fallbackTones[0],
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
    voiceSample?: string | null;
    extraContext?: string | null;
  },
): string {
  const cal = (ctx.profile.calibration_data ?? {}) as Record<string, unknown>;
  const traits = (cal.traits ?? {}) as Record<string, number | string>;

  // Conditional blocks — boş ise sıfır karakter render edilir, böylece
  // L4 template'te "<user_voice></user_voice>" gibi boş yapılar kalmıyor.
  const trimmedVoice = (ctx.voiceSample ?? "").trim();
  const userVoiceBlock = trimmedVoice
    ? `\n<user_voice>\n${trimmedVoice}\n</user_voice>\n`
    : "";

  const trimmedExtra = (ctx.extraContext ?? "").trim();
  const extraContextBlock = trimmedExtra
    ? `\n<extra_context>\n${trimmedExtra}\n</extra_context>\n`
    : "";

  const genderRaw = String(ctx.profile.gender ?? "").trim();
  const genderTr = ({ male: "erkek", female: "kadın", unspecified: "belirtmemiş" } as Record<string, string>)[genderRaw]
    ?? (genderRaw || "belirtmemiş");
  const ageBracket = String(ctx.profile.age_bracket ?? "").trim() || "belirtmemiş";
  const intentRaw = String(ctx.profile.intent ?? "").trim();
  const intentTr = ({
    relationship: "ilişki arıyor",
    casual: "casual",
    fun: "eğlence",
    taken: "birlikte (sadece sosyal/iş)",
  } as Record<string, string>)[intentRaw] ?? (intentRaw || "belirtmemiş");

  const replacements: Record<string, string> = {
    archetype_primary: String(ctx.profile.archetype_primary ?? "unknown"),
    archetype_secondary: String(ctx.profile.archetype_secondary ?? "—"),
    directness: String(traits.directness ?? "0.5"),
    "humor.primary_type": "default",
    "humor.intensity": String(traits.humor_intensity ?? "0.5"),
    slang_level: String(traits.slang_level ?? "0.5"),
    "language.primary": "tr",
    english_mix_ratio: "0.1",
    gender: genderTr,
    age_bracket: ageBracket,
    intent: intentTr,
    top_context: "tinder",
    "boundaries.avoid": "klişe, toxic positivity",
    stage1_parse_json: JSON.stringify(ctx.parseResult, null, 2),
    mode: ctx.mode,
    tone: ctx.tone,
    user_voice_block: userVoiceBlock,
    extra_context_block: extraContextBlock,
  };
  let out = template;
  for (const [k, v] of Object.entries(replacements)) {
    out = out.replaceAll(`{{ ${k} }}`, v);
  }
  return out;
}
