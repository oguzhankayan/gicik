// Active prompt version loader.
// Caches in-memory per edge function instance (cold start = fresh fetch).
// Tablo: prompt_versions WHERE is_active = TRUE.

import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import type { Mode, Tone, ArchetypePrimary } from "./types.ts";

export type Layer = "L0" | "L1" | "L2" | "L3" | "L4" | "tone" | "archetype" | "stage1";

interface CacheKey {
  layer: Layer;
  mode?: Mode;
  tone?: Tone;
  archetype?: ArchetypePrimary;
}

interface CachedPrompt {
  id: string;
  content: string;
  fetchedAt: number;
}

const CACHE_TTL_MS = 5 * 60 * 1000;  // 5dk
const cache = new Map<string, CachedPrompt>();

function keyFor(k: CacheKey): string {
  return `${k.layer}:${k.mode ?? ""}:${k.tone ?? ""}:${k.archetype ?? ""}`;
}

/// Active prompt version'ı çek, cache'le.
/// Throws if not found.
export async function loadPrompt(
  client: SupabaseClient,
  k: CacheKey,
): Promise<{ id: string; content: string }> {
  const cacheKey = keyFor(k);
  const cached = cache.get(cacheKey);
  if (cached && Date.now() - cached.fetchedAt < CACHE_TTL_MS) {
    return { id: cached.id, content: cached.content };
  }

  let query = client
    .from("prompt_versions")
    .select("id, content")
    .eq("layer", k.layer)
    .eq("is_active", true)
    .order("version", { ascending: false })
    .limit(1);

  if (k.mode !== undefined) {
    query = query.eq("mode", k.mode);
  }
  if (k.tone !== undefined) {
    query = query.eq("tone", k.tone);
  }
  if (k.archetype !== undefined) {
    query = query.eq("archetype", k.archetype);
  }

  const { data, error } = await query.maybeSingle();
  if (error) throw new Error(`prompt-loader error: ${error.message}`);
  if (!data) {
    throw new Error(`no active prompt for ${cacheKey}`);
  }

  cache.set(cacheKey, {
    id: data.id,
    content: data.content,
    fetchedAt: Date.now(),
  });

  return { id: data.id, content: data.content };
}

/// Bulk loader — Stage 2 generation için tek seferde tüm katmanlar.
export async function loadFullPromptStack(
  client: SupabaseClient,
  mode: Mode,
  tone: Tone,
): Promise<{
  L0: { id: string; content: string };
  L1: { id: string; content: string };
  L2: { id: string; content: string };
  L4: { id: string; content: string };
  tone: { id: string; content: string };
}> {
  const [L0, L1, L2, L4, toneLayer] = await Promise.all([
    loadPrompt(client, { layer: "L0" }),
    loadPrompt(client, { layer: "L1", mode }),
    loadPrompt(client, { layer: "L2" }),
    loadPrompt(client, { layer: "L4" }),
    loadPrompt(client, { layer: "tone", tone }),
  ]);
  return { L0, L1, L2, L4, tone: toneLayer };
}

/// Cache'i temizle (test veya manuel rollout sonrası).
export function clearPromptCache(): void {
  cache.clear();
}
