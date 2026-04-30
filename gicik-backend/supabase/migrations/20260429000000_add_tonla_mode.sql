-- Hayalet modu çıkarıldı, tonla (taslak ton verme) eklendi.
-- conversations.mode CHECK constraint güncelleniyor.

ALTER TABLE public.conversations
  DROP CONSTRAINT IF EXISTS conversations_mode_check;

ALTER TABLE public.conversations
  ADD CONSTRAINT conversations_mode_check
  CHECK (mode IN ('cevap', 'acilis', 'tonla', 'davet', 'bio', 'hayalet'));

-- 'hayalet' geçici olarak listede kaldı: eski conversation row'larında mevcut
-- olabilir, drop edersek validation hata verir. Yeni row'lar yazılmaz.
-- 'bio' Phase 7+ için rezerve.
