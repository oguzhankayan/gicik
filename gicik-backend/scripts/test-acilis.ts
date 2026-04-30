// Açılış mode eval — 4 archetype × 4 profil = 4 run
// (her run: hero tone arketipe göre, kalan 2 ton sabit kümeden)
//
// Usage:
//   cd gicik-backend
//   deno run --allow-read --allow-net --allow-env scripts/test-acilis.ts

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_MODEL = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-6";

type Tone = "flortoz" | "esprili" | "direkt" | "sicak" | "gizemli";

// Production'daki openerTonesFor ile aynı mantık.
const OPENER_LEAD: Record<string, Tone> = {
  dryroaster: "direkt",
  observer: "esprili",
  softie_with_edges: "flortoz",
  chaos_agent: "flortoz",
  strategist: "direkt",
  romantic_pessimist: "esprili",
};
function openerTones(archetype: string): Tone[] {
  const base: Tone[] = ["flortoz", "esprili", "direkt"];
  const lead = OPENER_LEAD[archetype] ?? "flortoz";
  return [lead, ...base.filter(t => t !== lead)];
}

interface Profile {
  name: string;
  parse: Record<string, unknown>;
}

const PROFILES: Profile[] = [
  {
    name: "P1 — kullanıcının kendi insta'sı (3 unvan, 4 iş foto)",
    parse: {
      screenshot_type: "profile",
      participants: [],
      messages: [],
      last_message_from: null,
      profile: {
        name: "Oğuzhan",
        handle: "@oguzhan",
        bio: "creative director · iletişim koordinatörü · içerik üretici",
        photo_count: 4,
        photo_descriptions: [
          "kürsüde mikrofon önünde konuşma yaparken",
          "kamera arkasında set ışığı kuruluyor",
          "takım elbiseyle imza günü gibi bir etkinlikte",
          "ofis masasında dizüstü önünde, mat siyah-beyaz",
        ],
        posts: [],
      },
      platform_detected: "instagram",
      tone_observed: "neutral",
      red_flags: [],
      context_summary_tr: "yaratıcı sektörden, kendini iş üzerinden tanımlayan bir profil. tüm fotoğraflar profesyonel.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
  {
    name: "P2 — sparse insta (kahve + kedi, bio yok)",
    parse: {
      screenshot_type: "profile",
      participants: [],
      messages: [],
      last_message_from: null,
      profile: {
        handle: "@ahmetk",
        photo_count: 2,
        photo_descriptions: [
          "elinde kahve fincanı, fincanın üstünde latte art",
          "siyah kedi ile selfie, kedi homurdanır gibi",
        ],
        bio: null,
        posts: [],
      },
      platform_detected: "instagram",
      tone_observed: "neutral",
      red_flags: [],
      context_summary_tr: "iki fotoğraf, bio yok. kahve + kedi. profil minimalist, az şey gösteriyor.",
      injection_attempt: false,
      image_quality: "fair",
    },
  },
  {
    name: "P3 — twitter (overthink-ironic bio + 2 tweet)",
    parse: {
      screenshot_type: "profile",
      participants: [],
      messages: [],
      last_message_from: null,
      profile: {
        name: "Elif",
        handle: "@elifoverthinks",
        bio: "i overthink, therefore i tweet. istanbul. açıklama gerektirmez.",
        posts: [
          "her gün aynı sokaktan geçiyorum ama kedi her gün başka bir noktada bana bakıyor. komplo şüphem var.",
          "8 saatlik uyku tavsiye eden insanlara güvenim sıfır.",
        ],
        photo_count: 1,
        photo_descriptions: ["profil fotosu, yarısı kapalı, kafe penceresinden bakıyor"],
      },
      platform_detected: "twitter",
      tone_observed: "playful",
      red_flags: [],
      context_summary_tr: "twitter profili, ironik kendini-yargılayan ses. son tweet'ler günlük gözlem.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
  {
    name: "P4 — tinder bio ironic (şarap + şaka + erken yatmamak)",
    parse: {
      screenshot_type: "profile",
      participants: [],
      messages: [],
      last_message_from: null,
      profile: {
        name: "Deniz",
        age: 28,
        bio: "iyi şarap, kötü şakalar. ortak alan: dalga geçmek.",
        prompts: [
          { question: "yapamadığım şey", answer: "erken yatmak" },
          { question: "asla", answer: "soğuk pizza yemek" },
        ],
        interests: ["sinema", "yürüyüş", "şarap"],
        photo_count: 4,
        photo_descriptions: [
          "konser kalabalığında gülüyor",
          "sahilde köpekle oynuyor",
          "ayna selfie, koyu mavi gömlek",
          "kafede arkadaşıyla, içki kadehleri masada",
        ],
        posts: [],
      },
      platform_detected: "tinder",
      tone_observed: "playful",
      red_flags: [],
      context_summary_tr: "tinder profili, kendiyle dalga geçen ses. net karakter sinyali.",
      injection_attempt: false,
      image_quality: "good",
    },
  },
];

const COMBOS = [
  { archetype: "dryroaster", profileIdx: 0 },
  { archetype: "observer", profileIdx: 1 },
  { archetype: "chaos_agent", profileIdx: 3 },
  { archetype: "romantic_pessimist", profileIdx: 2 },
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
    .replace(/{{\s*mode\s*}}/g, "acilis")
    .replace(/{{\s*tone\s*}}/g, tone)
    .replace(/{{\s*extra_context_block\s*}}/g, "");
}

function buildUserPrompt(parse: Record<string, unknown>, tones: Tone[]): string {
  const tonesList = tones.map((t, i) => `  ${i}: ${t}`).join("\n");
  const inputPayload = {
    platform: parse.platform_detected,
    profile: parse.profile,
    red_flags: parse.red_flags,
    context_summary: parse.context_summary_tr,
  };
  return [
    "profil çözümü:",
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
  loadPrompt("L1", { mode: "acilis" }),
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
for (const t of ["flortoz", "esprili", "direkt"]) {
  tonePrompts[t] = await loadPrompt("tone", { tone: t });
}

console.log(`\n═══════════════════════════════════════════════════════════════════`);
console.log(`AÇILIŞ EVAL — 4 archetype × 4 profil`);
console.log(`═══════════════════════════════════════════════════════════════════`);

for (const combo of COMBOS) {
  const profile = PROFILES[combo.profileIdx];
  const tones = openerTones(combo.archetype);

  console.log(`\n━━━━━ ${combo.archetype.toUpperCase()} × ${profile.name} ━━━━━`);
  console.log(`tonlar: [${tones.join(", ")}] (hero: ${tones[0]})`);

  const tonesBlock = tones.map((t, i) => `--- TON ${i + 1} (${t}) ---\n${tonePrompts[t]}`).join("\n\n");
  const L4Filled = fillL4(L4, combo.archetype, tones[0], profile.parse);

  const stableContent = [L0, L2, L4Filled].join("\n\n---\n\n");
  const archetypeBlock = `\n--- archetype prompt (kullanıcı kim, NASIL yazar) ---\n${archetypePrompts[combo.archetype]}`;
  const systemBlocks = [
    { type: "text", text: stableContent, cache_control: { type: "ephemeral" } },
    { type: "text", text: `\n--- mode prompt ---\n${L1}${archetypeBlock}\n\n--- tone prompt ---\n${tonesBlock}` },
  ];

  try {
    const raw = await callClaude(systemBlocks, buildUserPrompt(profile.parse, tones));
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
