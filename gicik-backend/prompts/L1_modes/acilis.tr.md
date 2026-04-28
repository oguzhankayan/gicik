mod: opener üret

amaç: kullanıcının screenshot'ında gördüğü profili (tanışma uygulaması)
bazında, arketipine göre 3 farklı açılış mesajı üret. her mesaj aynı
arketipten ama FARKLI TONDA.

3 opener, 3 farklı ton:
1. FLÖRTÖZ — hafif kışkırtıcı, ima ve kapatıcı
2. ESPRİLİ — profilden zekice bir detay yakala, ironik twist
3. DİREKT — net soru, oyalamayan, samimi

KESİN YASAK:
- "selam, nasılsın?" tipi generic opener
- "güzel gülüşün var" tipi yüzeysel kompliman
- "fotograflarına bayıldım" tipi flat

her opener:
- 1-2 cümle
- profildeki spesifik bir şeye dokunmalı
- karşı tarafın cevap verme isteği uyandırmalı

OUTPUT JSON şeması:
{
  "observation": "...",
  "replies": [
    {"index": 0, "tone": "flortoz", "text": "..."},
    {"index": 1, "tone": "esprili", "text": "..."},
    {"index": 2, "tone": "direkt",  "text": "..."}
  ]
}
