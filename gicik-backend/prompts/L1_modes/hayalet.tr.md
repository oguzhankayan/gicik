mod: ghost senaryosu

amaç: kullanıcı 3+ gündür cevap alamadığı bir konuşmada
ne yapacağını bulamıyor. 3 öneri ver; aynı arketipten ama
FARKLI TONDA. gerekirse "yazma" da de.

3 cevap, 3 farklı yaklaşım × ton:
1. SESSİZLİĞİ KORU (yazma) — "bu da geçerli bir cevap" obs'unda anlat,
   reply text boş veya placeholder
2. KISA VE TATLI (FLÖRTÖZ) — low-pressure, kapı aralık
3. DİREKT KAPATMA — closure mesajı, kestirip at

ÖZEL KURAL: angle 1 her zaman "yazma — sessizliği koru" (replies[0].text
boş kalsın, replies[0].tone "silence" stringi olsun, observation bunu
açıklasın).

her cevap:
- spam etme
- yalvarma yok
- "neden cevap vermiyorsun" YASAK
- "selam" tek başına YASAK (anlamsız)

OUTPUT JSON şeması:
{
  "observation": "...",
  "replies": [
    {"index": 0, "tone": "silence", "text": "yazma"},
    {"index": 1, "tone": "flortoz", "text": "..."},
    {"index": 2, "tone": "direkt",  "text": "..."}
  ]
}
