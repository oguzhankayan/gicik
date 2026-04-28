// Calibration → Archetype derivation
// Master prompt §9 — rule-based, deterministic.

import type { CalibrationAnswer, ArchetypeResult, ArchetypePrimary } from "../_shared/types.ts";

const HUMOR_INTENSITY: Record<string, number> = {
  "kara mizah": 0.95,
  "laf sokan, ironik": 0.85,
  "absürt, saçma": 0.7,
  "düz, ifadesiz": 0.5,
  "tatlış, masum": 0.25,
};

interface Traits {
  directness: number;
  boldness: number;
  slang_level: number;
  humor_intensity: number;
  petty: number;
  impulse: number;
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
  const traits: Traits = {
    directness: answerString(answers, "directness") === "direct" ? 0.8 : 0.3,
    boldness: answerNumber(answers, "boldness") / 5,
    slang_level: answerNumber(answers, "slang_level"),
    humor_intensity: HUMOR_INTENSITY[answerString(answers, "humor_style")] ?? 0.5,
    petty: answerString(answers, "vibe_scenario_2") === "screenshot" ? 0.8 : 0.2,
    impulse: answerString(answers, "vibe_scenario_1") === "photo" ? 0.7 : 0.3,
  };

  const { primary, secondary } = pickArchetype(traits);

  return {
    archetype_primary: primary,
    archetype_secondary: secondary,
    display_label: ARCHETYPE_DISPLAY[primary].label,
    display_description: ARCHETYPE_DISPLAY[primary].description,
    traits: traits as unknown as Record<string, number>,
    full_profile: { traits, raw_answers: answers, version: 1 },
  };
}

function pickArchetype(t: Traits): { primary: ArchetypePrimary; secondary: ArchetypePrimary } {
  if (t.directness > 0.7 && t.humor_intensity > 0.6) {
    return { primary: "dryroaster", secondary: "strategist" };
  }
  if (t.directness < 0.4 && t.humor_intensity < 0.4) {
    return { primary: "softie_with_edges", secondary: "observer" };
  }
  if (t.impulse > 0.6 && t.boldness > 0.7) {
    return { primary: "chaos_agent", secondary: "dryroaster" };
  }
  if (t.directness > 0.6 && t.boldness > 0.6) {
    return { primary: "strategist", secondary: "dryroaster" };
  }
  if (t.humor_intensity < 0.3 && t.directness > 0.5) {
    return { primary: "romantic_pessimist", secondary: "observer" };
  }
  return { primary: "observer", secondary: "softie_with_edges" };
}

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
