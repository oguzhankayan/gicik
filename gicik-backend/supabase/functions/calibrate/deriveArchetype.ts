// Calibration → Archetype derivation
// Affinity scoring (2026-04-30): cascading if → her arketip için skor,
// en yüksek kazanır. Eski cascading "ilk match wins" hep dryroaster'a düşürüyordu
// çünkü direct+ironic en yaygın self-report. Continuous similarity adil sonuç verir.

import type { CalibrationAnswer, ArchetypeResult, ArchetypePrimary } from "../_shared/types.ts";

const HUMOR_INTENSITY: Record<string, number> = {
  "kara mizah": 0.95,
  "laf sokan, ironik": 0.80,
  "absürt, saçma": 0.65,
  "düz, ifadesiz": 0.45,
  "tatlış, masum": 0.20,
};

interface Traits {
  directness: number;       // 0..1 — açık konuşma vs ima
  boldness: number;          // 0..1 — risk alma vs çekinme
  slang_level: number;       // 0..1 — formal vs argo
  humor_intensity: number;   // 0..1 — kara mizah vs şirin
  petty: number;             // 0..1 — drama / hesap tutma
  impulse: number;           // 0..1 — anlık tepki vs bekle
}

function answerByIdRaw(answers: CalibrationAnswer[], id: string): CalibrationAnswer | undefined {
  return answers.find((a) => a.question_id === id);
}

function answerString(answers: CalibrationAnswer[], id: string): string {
  const a = answerByIdRaw(answers, id);
  if (!a) return "";
  return Array.isArray(a.selected) ? (a.selected[0] ?? "") : a.selected;
}

function answerNumber(answers: CalibrationAnswer[], id: string): number {
  const s = answerString(answers, id);
  const n = parseFloat(s);
  return Number.isFinite(n) ? n : 0;
}

export function deriveArchetype(answers: CalibrationAnswer[]): ArchetypeResult {
  const directRaw = answerString(answers, "directness");
  const directness = directRaw === "direct" ? 0.85 : directRaw === "indirect" ? 0.20 : 0.5;

  const boldness = clamp01((answerNumber(answers, "boldness") - 1) / 4); // likert 1-5 → 0..1
  const slangRaw = answerNumber(answers, "slang_level");
  const slang_level = slangRaw > 1 ? clamp01(slangRaw / 100) : clamp01(slangRaw);
  const humor_intensity = HUMOR_INTENSITY[answerString(answers, "humor_style")] ?? 0.5;
  const petty = answerString(answers, "vibe_scenario_2") === "screenshot" ? 0.85 : 0.15;
  const impulse = impulseFromAnswer(answerString(answers, "vibe_scenario_1"));

  const traits: Traits = { directness, boldness, slang_level, humor_intensity, petty, impulse };

  const ranked = rankArchetypes(traits);
  const primary = ranked[0].key;
  const secondary = ranked[1].key;

  return {
    archetype_primary: primary,
    archetype_secondary: secondary,
    display_label: ARCHETYPE_DISPLAY[primary].label,
    display_description: ARCHETYPE_DISPLAY[primary].description,
    traits: traits as unknown as Record<string, number>,
    full_profile: {
      traits,
      raw_answers: answers,
      ranked_scores: ranked.map((r) => ({ key: r.key, score: round3(r.score) })),
      version: 2,
    },
  };
}

function impulseFromAnswer(s: string): number {
  switch (s) {
    case "photo": return 0.80;
    case "balanced": return 0.50;
    case "leave": return 0.20;
    default: return 0.5;
  }
}

function clamp01(n: number): number {
  if (!Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(1, n));
}

function round3(n: number): number {
  return Math.round(n * 1000) / 1000;
}

// ──────────────────────────────────────────────────────────────────
// Affinity scoring
//
// Her arketip için ideal trait vector + her trait için ağırlık.
// Skor = ağırlıklı Gaussian benzerliği (target'a yakınsa yüksek).
// Toplamda en yüksek skor primary, ikincisi secondary.
// ──────────────────────────────────────────────────────────────────

interface AffinitySpec {
  // [target, weight] — target = ideal trait değeri, weight = bu trait'in arketip için önemi
  directness: [number, number];
  boldness: [number, number];
  humor_intensity: [number, number];
  impulse: [number, number];
  petty: [number, number];
  slang_level: [number, number];
}

const SIGMA = 0.28; // tüm trait'ler için ortak fall-off; küçük = sert ayrışma

const AFFINITY: Record<ArchetypePrimary, AffinitySpec> = {
  // GICIK — ironik mesafeli, direkt, ironik mizah, orta-yüksek petty
  dryroaster: {
    directness:      [0.80, 1.4],
    humor_intensity: [0.85, 1.6],
    boldness:        [0.65, 0.9],
    impulse:         [0.45, 0.5],
    petty:           [0.55, 0.7],
    slang_level:     [0.55, 0.4],
  },
  // AĞIR — düşük impulse, düşük slang, orta direktlik, az mizah
  observer: {
    directness:      [0.40, 1.2],
    humor_intensity: [0.40, 1.1],
    boldness:        [0.30, 1.0],
    impulse:         [0.20, 1.5],
    petty:           [0.20, 0.9],
    slang_level:     [0.30, 0.7],
  },
  // TATLI — düşük petty, yumuşak mizah, orta-düşük directness
  softie_with_edges: {
    directness:      [0.45, 1.0],
    humor_intensity: [0.25, 1.6],
    boldness:        [0.50, 0.6],
    impulse:         [0.55, 0.5],
    petty:           [0.15, 1.3],
    slang_level:     [0.40, 0.4],
  },
  // ALEV — yüksek impulse, yüksek boldness, yüksek slang
  chaos_agent: {
    directness:      [0.70, 0.7],
    humor_intensity: [0.70, 0.6],
    boldness:        [0.90, 1.5],
    impulse:         [0.85, 1.6],
    petty:           [0.65, 0.6],
    slang_level:     [0.85, 1.0],
  },
  // HAVALI — yüksek directness, düşük impulse (planlar), orta humor
  strategist: {
    directness:      [0.85, 1.4],
    humor_intensity: [0.55, 0.7],
    boldness:        [0.75, 1.0],
    impulse:         [0.25, 1.5],
    petty:           [0.30, 0.7],
    slang_level:     [0.45, 0.4],
  },
  // NAZLI — düşük humor (samimiyet), orta directness, orta-yüksek petty (duygu sahibi)
  romantic_pessimist: {
    directness:      [0.55, 0.9],
    humor_intensity: [0.30, 1.4],
    boldness:        [0.45, 0.6],
    impulse:         [0.55, 0.6],
    petty:           [0.65, 1.0],
    slang_level:     [0.35, 0.4],
  },
};

interface RankedArchetype {
  key: ArchetypePrimary;
  score: number;
}

function rankArchetypes(t: Traits): RankedArchetype[] {
  const keys = Object.keys(AFFINITY) as ArchetypePrimary[];
  const ranked = keys.map((key) => ({
    key,
    score: affinityScore(t, AFFINITY[key]),
  }));
  ranked.sort((a, b) => b.score - a.score);
  return ranked;
}

function affinityScore(t: Traits, spec: AffinitySpec): number {
  let total = 0;
  let weightSum = 0;
  const traitKeys: (keyof AffinitySpec)[] = [
    "directness", "humor_intensity", "boldness", "impulse", "petty", "slang_level",
  ];
  for (const k of traitKeys) {
    const [target, weight] = spec[k];
    const value = t[k];
    const sim = gaussian(value, target, SIGMA);
    total += sim * weight;
    weightSum += weight;
  }
  return total / weightSum;
}

function gaussian(value: number, target: number, sigma: number): number {
  const d = (value - target) / sigma;
  return Math.exp(-0.5 * d * d);
}

// ──────────────────────────────────────────────────────────────────

const ARCHETYPE_DISPLAY: Record<ArchetypePrimary, { label: string; description: string[] }> = {
  dryroaster: {
    label: "🥀 GICIK",
    description: [
      "spesifik gözlem yaparsın, klişe sevmezsin",
      "kısa cümle, nokta dostusun",
      "soğuk değilsin ama mesafe seversin",
    ],
  },
  observer: {
    label: "🪨 AĞIR",
    description: [
      "önce izlersin, sonra konuşursun",
      "duyguyu sözle dağıtmazsın",
      "sustuğunda en çok şey söylüyorsun",
    ],
  },
  softie_with_edges: {
    label: "🍬 TATLI",
    description: [
      "sıcak yaklaşırsın ama sınır bilirsin",
      "cringe sevmezsin ama melodramı affedersin",
      "duygu seninle saklanmaz, paylaşılır",
    ],
  },
  chaos_agent: {
    label: "🔥 ALEV",
    description: [
      "ortam senin enerjini bekliyor",
      "risk almak senin için varsayılan",
      "sıkıcılığı affetmiyorsun",
    ],
  },
  strategist: {
    label: "✨ HAVALI",
    description: [
      "cevap vermeden önce 3 hamle düşünüyorsun",
      "duyguyu yönetiyorsun, duygu seni değil",
      "bekleyebilen kazanır felsefesi var sende",
    ],
  },
  romantic_pessimist: {
    label: "🎀 NAZLI",
    description: [
      "umutlu olmayı utanç sanmıyorsun",
      "ironi armor değil, dilin senin",
      "sevdiğin şey için savaşmayı erkenden öğrendin",
    ],
  },
};
