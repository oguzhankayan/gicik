// Archetype × Tone matrix testi — 6 × 5 = 30 hücre, hepsi aynı senaryo.
// Her hücre 1 LLM çağrısı (3 reply döner), gösterimde 01-reply'ı kullanılır.
// Tone'lar paralel (rate-limit'i zorlamadan), archetype'lar sıralı.
//
// Usage:
//   cd efso-backend
//   deno run --allow-read --allow-net --allow-env scripts/test-matrix.ts

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_MODEL = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6";

const ARCHETYPES = [
  "dryroaster", "observer", "softie_with_edges",
  "chaos_agent", "strategist", "romantic_pessimist",
] as const;
const TONES = ["flortoz", "esprili", "direkt", "sicak", "gizemli"] as const;

const ARCHETYPE_LABELS: Record<string, string> = {
  dryroaster: "🥀 DRYROASTER",
  observer: "🪨 OBSERVER",
  softie_with_edges: "🍬 SOFTIE",
  chaos_agent: "🔥 CHAOS",
  strategist: "✨ STRATEGIST",
  romantic_pessimist: "🎀 ROMANTIC",
};
const TONE_LABELS: Record<string, string> = {
  flortoz: "💋 flörtöz",
  esprili: "😏 esprili",
  direkt: "🎯 direkt",
  sicak: "🤍 sıcak",
  gizemli: "🌑 gizemli",
};

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
    { sender: "other", text: "neden yazmıyorsun ya, 3 gün oldu (!)", order: 5, approximate_time: "Per 18:42" },
  ],
  last_message_from: "other",
  platform_detected: "tinder",
  tone_observed: "playful → invested",
  red_flags: [],
  context_summary_tr: "tinder eşleşmesi 4 mesaj iyi gitmiş, kullanıcı hafta sonu davetine cevap vermemiş. 3 gün sonra karşı taraf parantez içi ünlemle sitem ediyor.",
};

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

function fillL4(template: string, archetype: string, tone: string): string {
  return template
    .replace(/{{\s*archetype_primary\s*}}/g, archetype)
    .replace(/{{\s*archetype_secondary\s*}}/g, "—")
    .replace(/{{\s*directness\s*}}/g, "0.6")
    .replace(/{{\s*humor\.primary_type\s*}}/g, "düz, ifadesiz")
    .replace(/{{\s*humor\.intensity\s*}}/g, "0.5")
    .replace(/{{\s*slang_level\s*}}/g, "0.5")
    .replace(/{{\s*language\.primary\s*}}/g, "tr")
    .replace(/{{\s*english_mix_ratio\s*}}/g, "0.2")
    .replace(/{{\s*top_context\s*}}/g, "flört")
    .replace(/{{\s*boundaries\.avoid\s*\|\s*join\([^)]*\)\s*}}/g, "toxic positivity, klinik tavsiye")
    .replace(/{{\s*stage1_parse_json\s*}}/g, JSON.stringify(PARSE_RESULT, null, 2))
    .replace(/{{\s*mode\s*}}/g, "cevap")
    .replace(/{{\s*tone\s*}}/g, tone);
}

function buildUserPrompt(tone: string): string {
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
    `  0: ${tone}`,
    `  1: ${tone}`,
    `  2: ${tone}`,
    "",
    "3 cevap üret, hepsi aynı arketipten ve aynı tonda — farklı 3 açı.",
    "schema:",
    `{
  "observation": "string",
  "replies": [
    {"index": 0, "tone": "${tone}", "text": "string"},
    {"index": 1, "tone": "${tone}", "text": "string"},
    {"index": 2, "tone": "${tone}", "text": "string"}
  ]
}`,
    "Sadece JSON dön.",
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
  if (!resp.ok) throw new Error(`anthropic ${resp.status}: ${await resp.text()}`);
  const json = await resp.json();
  return (json.content?.[0]?.text ?? "").trim();
}

function parseJSON(raw: string): { observation: string; replies: Array<{ index: number; tone: string; text: string }> } {
  let s = raw.trim();
  if (s.startsWith("```")) s = s.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "");
  return JSON.parse(s);
}

async function runCell(
  archetype: string,
  tone: string,
  shared: { L0: string; L1: string; L2: string; L4: string },
  archetypePrompts: Record<string, string>,
  tonePrompts: Record<string, string>,
): Promise<{ observation: string; firstReply: string; allReplies: string[] }> {
  const tonesBlock = [0, 1, 2].map(i => `--- TON ${i + 1} (${tone}) ---\n${tonePrompts[tone]}`).join("\n\n");
  const L4Filled = fillL4(shared.L4, archetype, tone);

  const stableContent = [shared.L0, shared.L2, L4Filled].join("\n\n---\n\n");
  const archetypeBlock = `\n--- archetype prompt (kullanıcı kim, NASIL yazar) ---\n${archetypePrompts[archetype]}`;
  const systemBlocks = [
    { type: "text", text: stableContent, cache_control: { type: "ephemeral" } },
    { type: "text", text: `\n--- mode prompt ---\n${shared.L1}${archetypeBlock}\n\n--- tone prompt ---\n${tonesBlock}` },
  ];

  const raw = await callClaude(systemBlocks, buildUserPrompt(tone));
  const parsed = parseJSON(raw);
  return {
    observation: parsed.observation,
    firstReply: parsed.replies[0]?.text ?? "",
    allReplies: parsed.replies.map(r => r.text),
  };
}

// ─── main ───
console.log("Loading prompts...");
const [L0, L1, L2, L4] = await Promise.all([
  loadPrompt("L0"), loadPrompt("L1", { mode: "cevap" }),
  loadPrompt("L2"), loadPrompt("L4"),
]);
const archetypePrompts: Record<string, string> = {};
for (const a of ARCHETYPES) archetypePrompts[a] = await loadPrompt("archetype", { archetype: a });
const tonePrompts: Record<string, string> = {};
for (const t of TONES) tonePrompts[t] = await loadPrompt("tone", { tone: t });

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`MATRIX: 6 archetype × 5 tone = 30 hücre, aynı senaryo`);
console.log(`SENARYO: tinder, 3 gün sessizlik, "neden yazmıyorsun ya"`);
console.log(`═══════════════════════════════════════════════════════════════════`);

const startTime = Date.now();

for (const archetype of ARCHETYPES) {
  console.log(`\n━━━━━ ${ARCHETYPE_LABELS[archetype]} ━━━━━`);

  // 5 tone'u paralel
  const cells = await Promise.all(
    TONES.map(async (tone) => {
      try {
        const r = await runCell(archetype, tone, { L0, L1, L2, L4 }, archetypePrompts, tonePrompts);
        return { tone, ...r };
      } catch (e) {
        return { tone, observation: "", firstReply: `✗ ${e instanceof Error ? e.message.slice(0, 60) : "err"}`, allReplies: [] };
      }
    })
  );

  for (const c of cells) {
    console.log(`  ${TONE_LABELS[c.tone]}`);
    console.log(`    01: ${c.firstReply}`);
  }
}

const totalSec = ((Date.now() - startTime) / 1000).toFixed(1);
console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`tamamlandı: 30 hücre, ${totalSec}s`);
console.log(`═══════════════════════════════════════════════════════════════════`);
