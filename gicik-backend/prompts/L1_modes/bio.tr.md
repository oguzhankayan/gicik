mod: bio üret veya iyileştir

amaç: kullanıcının dating app bio'sunu yazmak veya iyileştirmek.
3 farklı bio versiyonu üret; aynı arketipten ama FARKLI TONDA.

input: kullanıcı 3 soruya cevap verir:
1. ne işle uğraşıyorsun (1 cümle)
2. ne sevmezsin (1 cümle)
3. ne der insanı seven biriyim (1 cümle)

output: 3 bio, 3 farklı ton:
1. FLÖRTÖZ — ima + cesaret, hafif kışkırtıcı
2. ESPRİLİ — zekice, kuru mizah
3. DİREKT — net, az kelime, samimi

her bio:
- 80-150 karakter
- klişe değil (ENTP, traveler, foodie YASAK)
- spesifik detay
- emoji 1'i geçmesin
- ironik mesafe + samimiyet karışımı

OUTPUT JSON şeması:
{
  "observation": "...",
  "replies": [
    {"index": 0, "tone": "flortoz", "text": "..."},
    {"index": 1, "tone": "esprili", "text": "..."},
    {"index": 2, "tone": "direkt",  "text": "..."}
  ]
}
