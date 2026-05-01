import Foundation

extension Calendar {
    /// Brand TR-first; quota reset boundary'sini cihaz TZ'sine bırakmak yerine
    /// **Europe/Istanbul** kullanırız. Backend de aynı TZ'de hesaplıyor (bkz.
    /// gicik-backend/supabase/functions/_shared/dates.ts).
    ///
    /// Önceki bug: iOS `Calendar.current.isDateInToday` cihaz TZ; backend
    /// `new Date().toISOString().slice(0,10)` UTC. Sınırda saatlerde mismatch.
    static let istanbul: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        if let tz = TimeZone(identifier: "Europe/Istanbul") {
            cal.timeZone = tz
        }
        return cal
    }()
}
