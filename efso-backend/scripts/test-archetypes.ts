// Archetype A/B test — aynı senaryo, 6 archetype, tek tone (flortoz).
// requireAuth'u bypass etmek için Anthropic'a direkt çağrı; edge function'ın
// system block assembly'sini birebir replikliyor.
//
// Usage:
//   cd efso-backend
//   deno run --allow-read --allow-net --allow-env scripts/test-archetypes.ts

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_MODEL = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6";

const ARCHETYPES = [
  "dryroaster", "observer", "softie_with_edges",
  "chaos_agent", "strategist", "romantic_pessimist",
] as const;

const ARCHETYPE_LABELS: Record<string, string> = {
  dryroaster: "🥀 EFSO",
  observer: "🪨 AĞIR",
  softie_with_edges: "🍬 TATLI",
  chaos_agent: "🔥 ALEV",
  strategist: "✨ HAVALI",
  romantic_pessimist: "🎀 NAZLI",
};

// ─── Senaryo: Tinder, 3 gün sessizlik sonrası sitem ───
const PARSE_RESULT = {
  participants: [
    { role: "user", name: null },
    { role: "other", name: "Deniz" },
  ],
  messages: [
    { sender: "other", text: "selam, profilini beğendim", order: 0, approximate_time: "Pzt 21:14" },
    { sender: "user", text: "selam. teşekkürler, seninkini de okudum", order: 1, approximate_time: "Pzt 21:18" },
    { sender: "other", text: "kahve sever misin gerçekten yoksa profil için mi yazmışsın", order: 2, approximate_time: "Pzt 21:22" },
    { sender: "user", text: "haklı bir soru. günde 3 fincan, sabah olmadan kişiliğim yok diyebilirim", order: 3, approximate_time: "Pzt 21:30" },
    { sender: "other", text: "haha tehlikeli. peki bu hafta sonu müsait misin", order: 4, approximate_time: "Pzt 21:33" },
    // 3 gün boşluk
    { sender: "other", text: "neden yazmıyorsun ya, 3 gün oldu (!)", order: 5, approximate_time: "Per 18:42" },
  ],
  last_message_from: "other",
  platform_detected: "tinder",
  tone_observed: "playful → invested",
  red_flags: [],
  context_summary_tr: "tinder eşleşmesi 4 mesaj iyi gitmiş, kullanıcı hafta sonu davetine cevap vermemiş. 3 gün sonra karşı taraf parantez içi ünlemle sitem ediyor — oyunbaz ama gerçek rahatsızlık var.",
};

const TONES_TO_USE = ["flortoz", "flortoz", "flortoz"]; // 3 reply de flörtöz, archetype etkisini izole et

const sb = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });

async function loadPrompt(layer: string, opts: { mode?: string; tone?: string; archetype?: string } = {}): Promise<string> {
  let q = sb.from("prompt_versions").select("content").eq("layer", layer).eq("is_active", true).order("version", { ascending: false }).limit(1);
  if (opts.mode !== undefined) q = q.eq("mode", opts.mode);
  if (opts.tone !== undefined) q = q.eq("tone", opts.tone);
  if (opts.archetype !== undefined) q = q.eq("archetype", opts.archetype);
  const { data, error } = await q.maybeSingle();
  if (error || !data) throw new Error(`prompt missing: ${layer} ${JSON.stringify(opts)}`);
  return data.content as string;
}

function fillL4(template: string, archetype: string): string {
  return template
    .replace(/{{\s*archetype_primary\s*}}/g, archetype)
    .replace(/{{\s*archetype_secondary\s*}}/g, "—")
    .replace(/{{\s*directness\s*}}/g, "0.7")
    .replace(/{{\s*humor\.primary_type\s*}}/g, "düz, ifadesiz")
    .replace(/{{\s*humor\.intensity\s*}}/g, "0.5")
    .replace(/{{\s*slang_level\s*}}/g, "0.5")
    .replace(/{{\s*language\.primary\s*}}/g, "tr")
    .replace(/{{\s*english_mix_ratio\s*}}/g, "0.2")
    .replace(/{{\s*top_context\s*}}/g, "flört")
    .replace(/{{\s*boundaries\.avoid\s*\|\s*join\([^)]*\)\s*}}/g, "toxic positivity, klinik tavsiye")
    .replace(/{{\s*stage1_parse_json\s*}}/g, JSON.stringify(PARSE_RESULT, null, 2))
    .replace(/{{\s*mode\s*}}/g, "cevap")
    .replace(/{{\s*tone\s*}}/g, "flortoz");
}

function buildUserPrompt(): string {
  return [
    "konuşma çözümü:",
    JSON.stringify({
      platform: PARSE_RESULT.platform_detected,
      messages: PARSE_RESULT.messages,
      last_message_from: PARSE_RESULT.last_message_from,
      tone_observed: PARSE_RESULT.tone_observed,
      red_flags: PARSE_RESULT.red_flags,
      context_summary: PARSE_RESULT.context_summary_tr,
    }, null, 2),
    "",
    "kullanılacak tonlar (her reply için sırayla):",
    "  0: flortoz",
    "  1: flortoz",
    "  2: flortoz",
    "",
    "3 cevap üret, hepsi aynı arketipten ama yukarıdaki sıraya göre 3 farklı tonda.",
    "observation alanı asistan sesi (lowercase, kısa, gözlem).",
    "schema:",
    `{
  "observation": "string (max 280 char, asistan sesi)",
  "replies": [
    {"index": 0, "tone": "flortoz", "text": "string (max 280 char)"},
    {"index": 1, "tone": "flortoz", "text": "string"},
    {"index": 2, "tone": "flortoz", "text": "string"}
  ]
}`,
    "Sadece JSON dön, başka metin yok.",
  ].join("\n");
}

async function callClaude(systemBlocks: Array<{ type: string; text: string; cache_control?: unknown }>, userMessage: string): Promise<string> {
  const resp = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_KEY,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: ANTHROPIC_MODEL,
      max_tokens: 1500,
      temperature: 0.85,
      system: systemBlocks,
      messages: [{ role: "user", content: userMessage }],
    }),
  });
  if (!resp.ok) {
    const txt = await resp.text();
    throw new Error(`anthropic ${resp.status}: ${txt}`);
  }
  const json = await resp.json();
  const text = json.content?.[0]?.text ?? "";
  return text.trim();
}

function parseJSON(raw: string): { observation: string; replies: Array<{ index: number; tone: string; text: string }> } {
  let s = raw.trim();
  if (s.startsWith("```")) s = s.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "");
  return JSON.parse(s);
}

// ─── main ───
const [L0, L1, L2, L4, toneFlortoz] = await Promise.all([
  loadPrompt("L0"),
  loadPrompt("L1", { mode: "cevap" }),
  loadPrompt("L2"),
  loadPrompt("L4"),
  loadPrompt("tone", { tone: "flortoz" }),
]);

const tonesBlock = TONES_TO_USE.map((t, i) => `--- TON ${i + 1} (${t}) ---\n${toneFlortoz}`).join("\n\n");

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`SENARYO: tinder, 3 gün sessizlik, karşı taraf "neden yazmıyorsun ya"`);
console.log(`TONE: flortoz × 3 (sabit)  |  ARCHETYPE: değişken`);
console.log(`═══════════════════════════════════════════════════════════════════\n`);

for (const arche of ARCHETYPES) {
  const archetypePrompt = await loadPrompt("archetype", { archetype: arche });
  const L4Filled = fillL4(L4, arche);

  const stableContent = [L0, L2, L4Filled].join("\n\n---\n\n");
  const archetypeBlock = `\n--- archetype prompt (kullanıcı kim, NASIL yazar) ---\n${archetypePrompt}`;
  const systemBlocks = [
    { type: "text", text: stableContent, cache_control: { type: "ephemeral" } },
    {
      type: "text",
      text: `\n--- mode prompt ---\n${L1}${archetypeBlock}\n\n--- tone prompt (her reply için ayrı) ---\n${tonesBlock}`,
    },
  ];

  console.log(`──────────────────────────────────────`);
  console.log(`${ARCHETYPE_LABELS[arche]}  (${arche})`);
  console.log(`──────────────────────────────────────`);
  try {
    const raw = await callClaude(systemBlocks, buildUserPrompt());
    const parsed = parseJSON(raw);
    console.log(`gözlem: ${parsed.observation}`);
    for (const r of parsed.replies) {
      console.log(`  [0${r.index + 1}] ${r.text}`);
    }
  } catch (e) {
    console.log(`✗ HATA: ${e instanceof Error ? e.message : e}`);
  }
  console.log();
}
