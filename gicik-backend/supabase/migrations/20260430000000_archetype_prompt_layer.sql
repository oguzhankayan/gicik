-- ──────────────────────────────────────────────────────────
-- Archetype prompt layer
-- ──────────────────────────────────────────────────────────
-- 6 archetype'a (dryroaster/observer/softie_with_edges/chaos_agent/
-- strategist/romantic_pessimist) özel system prompt'lar inject edilebilsin
-- diye yeni bir layer ekleniyor.
--
-- Önceden tarz sadece L4 runtime template'inde tek satır olarak geçiyordu;
-- LLM çıkışında archetype rengi tone'un altında eziliyordu (test 2026-04-30).
-- Şimdi her archetype'ın kendi prompt fragmentı var (tone gibi), generate-replies
-- bunu inject ediyor.

ALTER TABLE public.prompt_versions
    ADD COLUMN archetype TEXT;

-- Eski UNIQUE'i düşür, yenisinde archetype dahil.
ALTER TABLE public.prompt_versions
    DROP CONSTRAINT IF EXISTS prompt_versions_layer_mode_tone_version_key;

ALTER TABLE public.prompt_versions
    ADD CONSTRAINT prompt_versions_layer_mode_tone_archetype_version_key
    UNIQUE (layer, mode, tone, archetype, version);

-- CHECK constraint'e 'archetype' layer ekle.
ALTER TABLE public.prompt_versions
    DROP CONSTRAINT IF EXISTS prompt_versions_layer_check;

ALTER TABLE public.prompt_versions
    ADD CONSTRAINT prompt_versions_layer_check
    CHECK (layer IN ('L0', 'L1', 'L2', 'L3', 'L4', 'tone', 'archetype', 'stage1'));

-- Lookup index — generate-replies'da archetype prompt'u çekerken kullanılır.
DROP INDEX IF EXISTS public.idx_prompt_versions_active;
CREATE INDEX idx_prompt_versions_active
    ON public.prompt_versions (layer, mode, tone, archetype)
    WHERE is_active = TRUE;
