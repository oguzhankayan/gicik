// Davet mode eval — 4 archetype × 4 chat senaryo = 4 run
// (her run: hero tone arketipe göre, kalan 2 ton sabit kümeden)
//
// Usage:
//   cd efso-backend
//   deno run --allow-read --allow-net --allow-env scripts/test-davet.ts

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_MODEL = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6";

type Tone = "flortoz" | "esprili" | "direkt" | "sicak" | "gizemli";

// Production'da generate-replies/index.ts:48 — davet için sabit sıra:
// direkt, flortoz, esprili (teklif somut + oyun + düşük tansiyon).
// Açılışın aksine davet'te archetype-aware lead yok; net teklif önde olmalı.
const DAVET_TONES: Tone[] = ["direkt", "flortoz", "esprili"];

interface Scenario {
  name: string;
  parse: Record<string, unknown>;
}

const SCENARIOS: Scenario[] = [
  {
    name: "S1 — kahve sohbeti, 3. mesajdan sonra net warm",
    parse: {
      screenshot_type: "chat",
      participants: [
        { role: "user", name: null },
        { role: "other", name: "Selin" },
      ],
      messages: [
        { sender: "other", text: "selam, profilini sevdim", order: 0, approximate_time: "Sal 19:14" },
        { sender: "user", text: "selam. teşekkürler, seninkini de okudum", order: 1, approximate_time: "Sal 19:18" },
        { sender: "other", text: "kahve sever misin gerçekten yoksa profil için mi yazmışsın", order: 2, approximate_time: "Sal 19:22" },
        { sender: "user", text: "haklı bir soru. günde 3 fincan, sabah olmadan kişiliğim yok diyebilirim", order: 3, approximate_time: "Sal 19:30" },
        { sender: "other", text: "haha tehlikeli. sabahları nerede içersin peki?", order: 4, approximate_time: "Sal 19:33" },
        { sender: "user", text: "kadıköy'de kuru kahveci yakınlarında bir yer var, oradan vazgeçemiyorum", order: 5, approximate_time: "Sal 19:40" },
        { sender: "other", text: "vay vay. ben de moda'da takılıyorum genelde, yakınız demek ki.", order: 6, approximate_time: "Sal 19:42" },
      ],
      last_message_from: "other",
      platform_detected: "tinder",
      tone_observed: "warm → invested",
      red_flags: [],
      context_summary_tr: "tinder eşleşmesi 7 mesaj, kahve + lokasyon ortak — kadıköy/moda. davet için zemin hazır.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
  {
    name: "S2 — espirili tempo, müzik ortak (konser ipucu)",
    parse: {
      screenshot_type: "chat",
      participants: [
        { role: "user", name: null },
        { role: "other", name: "Mert" },
      ],
      messages: [
        { sender: "user", text: "bu sabah Nilüfer Yanya yine kafamda dönüyor. çıkamadım altından", order: 0 },
        { sender: "other", text: "kıskandım. ben hâlâ Phoebe Bridgers fazında", order: 1 },
        { sender: "user", text: "ikisi aynı eve girer mi sence?", order: 2 },
        { sender: "other", text: "büyük ev gerek. ev sahibi gergin", order: 3 },
        { sender: "other", text: "neyse iki kelime laf olduk, başlayalım mı bir yerlere?", order: 4 },
      ],
      last_message_from: "other",
      platform_detected: "bumble",
      tone_observed: "playful",
      red_flags: [],
      context_summary_tr: "bumble eşleşmesi, müzik ortaklığı (Nilüfer Yanya/Phoebe Bridgers), karşı taraf zaten 'başlayalım' diyerek sinyal verdi. davet için top kullanıcıda.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
  {
    name: "S3 — temkinli, karşı taraf yavaş açılıyor",
    parse: {
      screenshot_type: "chat",
      participants: [
        { role: "user", name: null },
        { role: "other", name: "Ece" },
      ],
      messages: [
        { sender: "user", text: "hafta nasıl gidiyor?", order: 0 },
        { sender: "other", text: "yoğun ama iyi. sen?", order: 1 },
        { sender: "user", text: "fena değil. çarşamba bir konser var, bilmem nasıl. ", order: 2 },
        { sender: "other", text: "kim çalıyor?", order: 3 },
        { sender: "user", text: "Büyük Ev Ablukada. küçük bir mekan, bostanci", order: 4 },
        { sender: "other", text: "duydum onları, sevdiklerimden değil ama merak ettim", order: 5 },
      ],
      last_message_from: "other",
      platform_detected: "hinge",
      tone_observed: "neutral → playful",
      red_flags: [],
      context_summary_tr: "hinge eşleşmesi, kullanıcı zaten konser ipucu verdi, karşı taraf 'merak ettim' diyerek pozitif. davet'i somut güne bağlama zamanı.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
  {
    name: "S4 — uzun konuşma, davet riski yüksek (tutuk fazlar var)",
    parse: {
      screenshot_type: "chat",
      participants: [
        { role: "user", name: null },
        { role: "other", name: "Kaan" },
      ],
      messages: [
        { sender: "other", text: "merhabalar", order: 0 },
        { sender: "user", text: "selam, nasılsın", order: 1 },
        { sender: "other", text: "iyi sayılır, sen?", order: 2 },
        { sender: "user", text: "iyiyim. profilinde 'kötü espri yapma yarışmasında üçüncü' yazmışsın, gerçek mi?", order: 3 },
        { sender: "other", text: "gerçek. üçüncü olduğum yarışmada ilki bir AI'dı sanırım, ikincisi de çok eskimiş bir bandı vardı", order: 4 },
        { sender: "user", text: "haha bu hikâyenin canlı versiyonunu istiyorum", order: 5 },
        { sender: "other", text: "yani röportaj? ücretli mi", order: 6 },
        { sender: "user", text: "kahve. cumartesi iki, şişli'de", order: 7 },
        { sender: "other", text: "şişli'ye nadir gelirim ama olur. nerede tam?", order: 8 },
      ],
      last_message_from: "other",
      platform_detected: "tinder",
      tone_observed: "playful → invested",
      red_flags: [],
      context_summary_tr: "kullanıcı zaten 'cumartesi iki, şişli' demiş, karşı taraf 'olur' diyerek koşullu kabul. eksik: spesifik mekan. davet'in finalize edilmesi.",
      injection_attempt: false,
      image_quality: "good",
    },
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

function fillL4(template: string, archetype: string, tone: string, parse: Record<string, unknown>): string {
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
    .replace(/{{\s*stage1_parse_json\s*}}/g, JSON.stringify(parse, null, 2))
    .replace(/{{\s*mode\s*}}/g, "davet")
    .replace(/{{\s*tone\s*}}/g, tone)
    .replace(/{{\s*extra_context_block\s*}}/g, "");
}

function buildUserPrompt(parse: Record<string, unknown>, tones: Tone[]): string {
  const tonesList = tones.map((t, i) => `  ${i}: ${t}`).join("\n");
  const inputPayload = {
    platform: parse.platform_detected,
    messages: parse.messages,
    last_message_from: parse.last_message_from,
    tone_observed: parse.tone_observed,
    red_flags: parse.red_flags,
    context_summary: parse.context_summary_tr,
  };
  return [
    "konuşma çözümü:",
    JSON.stringify(inputPayload, null, 2),
    "",
    "kullanılacak tonlar (her reply için sırayla):",
    tonesList,
    "",
    "3 davet üret, hepsi aynı arketipten ama yukarıdaki sıraya göre 3 farklı tonda.",
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
  loadPrompt("L1", { mode: "davet" }),
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
for (const t of DAVET_TONES) {
  tonePrompts[t] = await loadPrompt("tone", { tone: t });
}

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`DAVET EVAL — 4 archetype × 4 senaryo`);
console.log(`═══════════════════════════════════════════════════════════════════`);

for (const combo of COMBOS) {
  const scenario = SCENARIOS[combo.scenarioIdx];
  const tones = DAVET_TONES;

  console.log(`\n━━━━━ ${combo.archetype.toUpperCase()} × ${scenario.name} ━━━━━`);
  console.log(`tonlar: [${tones.join(", ")}] (hero: ${tones[0]})`);

  const tonesBlock = tones.map((t, i) => `--- TON ${i + 1} (${t}) ---\n${tonePrompts[t]}`).join("\n\n");
  const L4Filled = fillL4(L4, combo.archetype, tones[0], scenario.parse);

  const stableContent = [L0, L2, L4Filled].join("\n\n---\n\n");
  const archetypeBlock = `\n--- archetype prompt (kullanıcı kim, NASIL yazar) ---\n${archetypePrompts[combo.archetype]}`;
  const systemBlocks = [
    { type: "text", text: stableContent, cache_control: { type: "ephemeral" } },
    { type: "text", text: `\n--- mode prompt ---\n${L1}${archetypeBlock}\n\n--- tone prompt ---\n${tonesBlock}` },
  ];

  try {
    const raw = await callClaude(systemBlocks, buildUserPrompt(scenario.parse, tones));
    const parsed = parseJSON(raw);
    console.log(`\n  observation:`);
    console.log(`    "${parsed.observation}"`);
    for (const r of parsed.replies) {
      console.log(`\n  ${String(r.index + 1).padStart(2, "0")} · ${r.tone.toUpperCase()}`);
      console.log(`    "${r.text}"`);
    }
  } catch (e) {
    console.log(`  ✗ error: ${e instanceof Error ? e.message.slice(0, 200) : "err"}`);
  }
}

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`done.`);
console.log(`═══════════════════════════════════════════════════════════════════`);
