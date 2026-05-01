// Seed prompts/ directory into prompt_versions table as v1, is_active=true.
// Idempotent — running twice yields the same final state.
//
// Usage:
//   cd efso-backend
//   deno run --allow-read --allow-net --allow-env scripts/seed-prompts.ts
//
// Requires env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
  Deno.exit(1);
}

const client = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { persistSession: false },
});

interface Seed {
  layer: "L0" | "L1" | "L2" | "L3" | "L4" | "tone" | "archetype" | "stage1";
  mode?: string;
  tone?: string;
  archetype?: string;
  name: string;
  path: string;
}

const PROMPTS_DIR = new URL("../prompts/", import.meta.url).pathname;

const seeds: Seed[] = [
  { layer: "L0", name: "L0 identity (asistan sesi)", path: "L0_identity.tr.md" },
  { layer: "L2", name: "L2 constraints (security + ethics)", path: "L2_constraints.tr.md" },
  { layer: "L3", name: "L3 output schemas", path: "L3_output_schemas.json" },
  { layer: "L4", name: "L4 runtime template", path: "L4_runtime_template.tr.md" },
  { layer: "stage1", name: "stage1 vision parser", path: "stage1_parser.md" },
  // L1 modes (cevap + acilis + tonla + davet)
  // hayalet çıkarıldı (DB'de inactive bırakıldı, mode listesi backward-compat).
  // bio Phase 7+'a ertelendi.
  { layer: "L1", mode: "cevap", name: "L1 mode cevap", path: "L1_modes/cevap.tr.md" },
  { layer: "L1", mode: "acilis", name: "L1 mode acilis", path: "L1_modes/acilis.tr.md" },
  { layer: "L1", mode: "tonla", name: "L1 mode tonla", path: "L1_modes/tonla.tr.md" },
  { layer: "L1", mode: "davet", name: "L1 mode davet", path: "L1_modes/davet.tr.md" },
  // tones
  { layer: "tone", tone: "flortoz", name: "tone flortoz", path: "tones/flortoz.tr.md" },
  { layer: "tone", tone: "esprili", name: "tone esprili", path: "tones/esprili.tr.md" },
  { layer: "tone", tone: "direkt", name: "tone direkt", path: "tones/direkt.tr.md" },
  { layer: "tone", tone: "sicak", name: "tone sicak", path: "tones/sicak.tr.md" },
  { layer: "tone", tone: "gizemli", name: "tone gizemli", path: "tones/gizemli.tr.md" },
  // archetypes — tarz inject'i (2026-04-30 — tarz LLM çıkışında zayıf
  // görünüyordu, tone'un altında eziliyordu; her archetype için ayrı prompt).
  { layer: "archetype", archetype: "dryroaster",         name: "archetype dryroaster",         path: "archetypes/dryroaster.tr.md" },
  { layer: "archetype", archetype: "observer",           name: "archetype observer",           path: "archetypes/observer.tr.md" },
  { layer: "archetype", archetype: "softie_with_edges",  name: "archetype softie_with_edges",  path: "archetypes/softie_with_edges.tr.md" },
  { layer: "archetype", archetype: "chaos_agent",        name: "archetype chaos_agent",        path: "archetypes/chaos_agent.tr.md" },
  { layer: "archetype", archetype: "strategist",         name: "archetype strategist",         path: "archetypes/strategist.tr.md" },
  { layer: "archetype", archetype: "romantic_pessimist", name: "archetype romantic_pessimist", path: "archetypes/romantic_pessimist.tr.md" },
];

async function seed(item: Seed): Promise<void> {
  const filePath = `${PROMPTS_DIR}${item.path}`;
  let content: string;
  try {
    content = await Deno.readTextFile(filePath);
  } catch (e) {
    console.error(`✗ ${item.name}: read failed (${e instanceof Error ? e.message : e})`);
    return;
  }

  // Check if v1 already exists for this (layer, mode, tone)
  let q = client
    .from("prompt_versions")
    .select("id, content")
    .eq("layer", item.layer)
    .eq("version", 1);

  if (item.mode !== undefined) q = q.eq("mode", item.mode);
  else q = q.is("mode", null);
  if (item.tone !== undefined) q = q.eq("tone", item.tone);
  else q = q.is("tone", null);
  if (item.archetype !== undefined) q = q.eq("archetype", item.archetype);
  else q = q.is("archetype", null);

  const { data: existing, error: selErr } = await q.maybeSingle();
  if (selErr) {
    console.error(`✗ ${item.name}: select failed: ${selErr.message}`);
    return;
  }

  if (existing) {
    if (existing.content === content) {
      console.log(`= ${item.name} (unchanged)`);
      return;
    }
    // Update content, keep is_active state
    const { error } = await client
      .from("prompt_versions")
      .update({ content, name: item.name })
      .eq("id", existing.id);
    if (error) {
      console.error(`✗ ${item.name}: update failed: ${error.message}`);
      return;
    }
    console.log(`↻ ${item.name} (content updated)`);
    return;
  }

  // Insert new v1, active
  const { error } = await client.from("prompt_versions").insert({
    name: item.name,
    version: 1,
    layer: item.layer,
    mode: item.mode ?? null,
    tone: item.tone ?? null,
    archetype: item.archetype ?? null,
    content,
    is_active: true,
    rollout_percentage: 100,
    notes: "seeded by scripts/seed-prompts.ts v1",
  });
  if (error) {
    console.error(`✗ ${item.name}: insert failed: ${error.message}`);
    return;
  }
  console.log(`✓ ${item.name} (v1 inserted, active)`);
}

console.log(`Seeding ${seeds.length} prompts → ${SUPABASE_URL}\n`);
for (const s of seeds) {
  await seed(s);
}
console.log("\nDone.");
