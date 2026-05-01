-- ──────────────────────────────────────────────────────────
-- voice_sample + extra_context
-- ──────────────────────────────────────────────────────────
-- voice_sample: Onboarding'deki "bize biraz kendinden bahset" cevabı.
-- LLM prompt'una L4 user_voice block olarak inject edilir; LLM kullanıcının
-- kendi yazma sesini referans alıp ona uygun cevaplar üretir.
-- Settings'ten istenildiğinde güncellenebilir.
--
-- extra_context: Her conversation için per-generation kullanıcı notu.
-- "bu kişi eski sevgilim", "iş partneri" gibi screenshot'ın anlamadığı
-- bağlamı LLM'e taşır. screenshot ile birlikte 24h sonra silinir
-- (conversations.created_at retention'ı altında).

ALTER TABLE public.profiles
    ADD COLUMN voice_sample TEXT;

COMMENT ON COLUMN public.profiles.voice_sample IS
    'Kullanıcının kendi yazma sesi örneği. Onboarding free-text + Settings update.';

ALTER TABLE public.conversations
    ADD COLUMN extra_context TEXT;

COMMENT ON COLUMN public.conversations.extra_context IS
    'Per-generation kullanıcı notu — LLM prompt''una <extra_context> olarak inject edilir.';
