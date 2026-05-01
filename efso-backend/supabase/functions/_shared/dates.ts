// Tarih helper'ları — Brand TR-first, "bugün" boundary'si Europe/Istanbul.
//
// Önceki bug: `new Date().toISOString().slice(0, 10)` UTC date veriyordu;
// usage_daily satırları UTC günü ile yazılıyordu. iOS ise (önceden) cihaz
// TZ'ne göre `isDateInToday` çağırıyordu. Sınır saatlerde (UTC 21-24,
// TR 00-03) iki taraf farklı "bugün" düşünüyordu.
//
// Çözüm: iki taraf da Europe/Istanbul kullansın. iOS:
// `Calendar.istanbul`. Backend: `todayIstanbulISODate()`.

export function todayIstanbulISODate(): string {
  // Intl ile ISO tarih (YYYY-MM-DD), Istanbul TZ.
  // en-CA locale ISO format döndürür: "2026-05-01".
  const fmt = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Istanbul",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  return fmt.format(new Date());
}
