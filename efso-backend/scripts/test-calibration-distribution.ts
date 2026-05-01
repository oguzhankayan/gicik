// Calibration distribution sanity check.
// 6 farklı kullanıcı profili → her birinin doğru arketipe düşmesini bekleriz.
// deno run --allow-net scripts/test-calibration-distribution.ts

import { deriveArchetype } from "../supabase/functions/calibrate/deriveArchetype.ts";
import type { CalibrationAnswer } from "../supabase/functions/_shared/types.ts";

interface TestCase {
  name: string;
  expected: string;
  answers: Record<string, string>;
}

const cases: TestCase[] = [
  {
    name: "ironik direkt",
    expected: "dryroaster",
    answers: {
      directness: "direct",
      boldness: "4",
      slang_level: "0.5",
      humor_style: "laf sokan, ironik",
      vibe_scenario_1: "balanced",
      vibe_scenario_2: "no",
    },
  },
  {
    name: "introvert düşünen",
    expected: "observer",
    answers: {
      directness: "indirect",
      boldness: "2",
      slang_level: "0.2",
      humor_style: "düz, ifadesiz",
      vibe_scenario_1: "leave",
      vibe_scenario_2: "no",
    },
  },
  {
    name: "yumuşak şirin",
    expected: "softie_with_edges",
    answers: {
      directness: "indirect",
      boldness: "3",
      slang_level: "0.3",
      humor_style: "tatlış, masum",
      vibe_scenario_1: "balanced",
      vibe_scenario_2: "no",
    },
  },
  {
    name: "kaos cesur",
    expected: "chaos_agent",
    answers: {
      directness: "direct",
      boldness: "5",
      slang_level: "0.95",
      humor_style: "absürt, saçma",
      vibe_scenario_1: "photo",
      vibe_scenario_2: "screenshot",
    },
  },
  {
    name: "stratejist soğukkanlı",
    expected: "strategist",
    answers: {
      directness: "direct",
      boldness: "4",
      slang_level: "0.4",
      humor_style: "düz, ifadesiz",
      vibe_scenario_1: "leave",
      vibe_scenario_2: "no",
    },
  },
  {
    name: "duygulu nazlı",
    expected: "romantic_pessimist",
    answers: {
      directness: "indirect",
      boldness: "3",
      slang_level: "0.3",
      humor_style: "düz, ifadesiz",
      vibe_scenario_1: "balanced",
      vibe_scenario_2: "screenshot",
    },
  },
];

function toAnswers(map: Record<string, string>): CalibrationAnswer[] {
  return Object.entries(map).map(([k, v]) => ({ question_id: k, selected: v }));
}

let pass = 0;
const counts: Record<string, number> = {};
for (const c of cases) {
  const r = deriveArchetype(toAnswers(c.answers));
  const ok = r.archetype_primary === c.expected;
  counts[r.archetype_primary] = (counts[r.archetype_primary] ?? 0) + 1;
  console.log(
    `${ok ? "✓" : "✗"} ${c.name.padEnd(28)} → ${r.archetype_primary}` +
    (ok ? "" : `  (expected ${c.expected})`)
  );
  // top 3 scores için debug
  const ranked = (r.full_profile as { ranked_scores: { key: string; score: number }[] }).ranked_scores;
  console.log(`    ${ranked.slice(0, 3).map((s) => `${s.key}=${s.score}`).join("  ")}`);
  if (ok) pass++;
}

console.log(`\n${pass}/${cases.length} pass`);
console.log("distribution:", counts);
