// Tonla mode eval — 4 archetype × 4 taslak senaryo = 4 run
// (her run: tek tone, 3 reply farklı açıyla)
//
// Usage:
//   cd gicik-backend
//   deno run --allow-read --allow-net --allow-env scripts/test-tonla.ts

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_MODEL = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6";

type Tone = "flortoz" | "esprili" | "direkt" | "sicak" | "gizemli";

interface Scenario {
  name: string;
  draft: string;
  context_message: string | null;
  target_tone: Tone;
}

const SCENARIOS: Scenario[] = [
  {
    name: "S1 — kibar ama belirsiz, direkt'e çevir",
    draft: "selam belki bu hafta sonu uygunsan müsaitsen bir şeyler içsek nasıl olur",
    context_message: "selam, ne haber? hafta sonu için planın var mı",
    target_tone: "direkt",
  },
  {
    name: "S2 — kızgın ama pasif, sıcak'a çevir",
    draft: "üç gündür yazmıyorsun, ben de zaten meşgulüm. anladım sen bilirsin.",
    context_message: null,
    target_tone: "sicak",
  },
  {
    name: "S3 — flörtöz ama aşırı, gizemli'ye çevir",
    draft: "seni bütün gün düşünüyorum aslında çok tatlısın gerçekten gözlerin de güzel öpmek istiyorum seni",
    context_message: "günün nasıl geçti :)",
    target_tone: "gizemli",
  },
  {
    name: "S4 — direkt ama sert (red flag), esprili'ye yumuşat",
    draft: "böyle olmaz, ya gel ya da bitiriyorum bu işi",
    context_message: "yarın görüşemeyeceğim, başka zaman",
    target_tone: "esprili",
  },
];

const COMBOS = [
  { archetype: "dryroaster", scenarioIdx: 0 },
  { archetype: "observer", scenarioIdx: 1 },
  { archetype: "chaos_agent", scenarioIdx: 2 },
  { archetype: "romantic_pessimist", scenarioIdx: 3 },
];

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

function fillL4(template: string, archetype: string, tone: string, scenario: Scenario): string {
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
    .replace(/{{\s*stage1_parse_json\s*}}/g, JSON.stringify({
      screenshot_type: "draft",
      user_draft: scenario.draft,
      context_message: scenario.context_message,
    }, null, 2))
    .replace(/{{\s*mode\s*}}/g, "tonla")
    .replace(/{{\s*selected_tone\s*}}/g, tone)
    .replace(/{{\s*tone\s*}}/g, tone)
    .replace(/{{\s*extra_context_block\s*}}/g, "");
}

function buildUserPrompt(scenario: Scenario): string {
  return [
    "kullanıcı taslağı:",
    JSON.stringify({
      user_draft: scenario.draft,
      context_message: scenario.context_message,
      target_tone: scenario.target_tone,
    }, null, 2),
    "",
    "kullanılacak tonlar (her reply için sırayla):",
    `  0: ${scenario.target_tone}`,
    `  1: ${scenario.target_tone}`,
    `  2: ${scenario.target_tone}`,
    "",
    "3 versiyon üret: HAFİF DOKUNUŞ → TAM ÇEVİRİ → SÜRPRİZ AÇI.",
    "hepsi aynı tonda, açı farklı.",
    "observation alanı asistan sesi (lowercase, kısa, gözlem).",
    "schema:",
    `{
  "observation": "string (max 280 char, asistan sesi)",
  "replies": [
    {"index": 0, "tone": "${scenario.target_tone}", "text": "string (max 280 char)"},
    {"index": 1, "tone": "${scenario.target_tone}", "text": "string"},
    {"index": 2, "tone": "${scenario.target_tone}", "text": "string"}
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
  if (!resp.ok) throw new Error(`anthropic ${resp.status}: ${await resp.text()}`);
  const json = await resp.json();
  return (json.content?.[0]?.text ?? "").trim();
}

function parseJSON(raw: string): { observation: string; replies: Array<{ index: number; tone: string; text: string }> } {
  let s = raw.trim();
  if (s.startsWith("```")) s = s.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "");
  return JSON.parse(s);
}

// ─── main ───
console.log("Loading prompts...");
const [L0, L1, L2, L4] = await Promise.all([
  loadPrompt("L0"),
  loadPrompt("L1", { mode: "tonla" }),
  loadPrompt("L2"),
  loadPrompt("L4"),
]);

const archetypePrompts: Record<string, string> = {};
for (const c of COMBOS) {
  if (!archetypePrompts[c.archetype]) {
    archetypePrompts[c.archetype] = await loadPrompt("archetype", { archetype: c.archetype });
  }
}
const tonePrompts: Record<string, string> = {};
for (const t of ["direkt", "sicak", "gizemli", "esprili", "flortoz"]) {
  tonePrompts[t] = await loadPrompt("tone", { tone: t });
}

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`TONLA EVAL — 4 archetype × 4 taslak senaryo`);
console.log(`═══════════════════════════════════════════════════════════════════`);

for (const combo of COMBOS) {
  const scenario = SCENARIOS[combo.scenarioIdx];
  const tone = scenario.target_tone;

  console.log(`\n━━━━━ ${combo.archetype.toUpperCase()} × ${scenario.name} ━━━━━`);
  console.log(`taslak: "${scenario.draft}"`);
  if (scenario.context_message) console.log(`context: "${scenario.context_message}"`);
  console.log(`hedef ton: ${tone}`);

  const tonesBlock = `--- TON (${tone}) ---\n${tonePrompts[tone]}`;
  const L4Filled = fillL4(L4, combo.archetype, tone, scenario);

  const stableContent = [L0, L2, L4Filled].join("\n\n---\n\n");
  const archetypeBlock = `\n--- archetype prompt (kullanıcı kim, NASIL yazar) ---\n${archetypePrompts[combo.archetype]}`;
  const systemBlocks = [
    { type: "text", text: stableContent, cache_control: { type: "ephemeral" } },
    { type: "text", text: `\n--- mode prompt ---\n${L1}${archetypeBlock}\n\n--- tone prompt ---\n${tonesBlock}` },
  ];

  try {
    const raw = await callClaude(systemBlocks, buildUserPrompt(scenario));
    const parsed = parseJSON(raw);
    console.log(`\n  observation:`);
    console.log(`    "${parsed.observation}"`);
    const labels = ["HAFİF", "TAM ÇEVİRİ", "SÜRPRİZ AÇI"];
    for (const r of parsed.replies) {
      const label = labels[r.index] ?? r.index;
      console.log(`\n  ${String(r.index + 1).padStart(2, "0")} · ${label}`);
      console.log(`    "${r.text}"`);
    }
  } catch (e) {
    console.log(`  ✗ error: ${e instanceof Error ? e.message.slice(0, 200) : "err"}`);
  }
}

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`done.`);
console.log(`═══════════════════════════════════════════════════════════════════`);
