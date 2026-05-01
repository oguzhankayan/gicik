import Foundation

/// Türkçe locale-aware case dönüşümleri.
///
/// Default Foundation `lowercased()` / `uppercased()` en_US Locale kullanır:
///   "AÇILIŞ".lowercased() → "açiliş"   yanlış (I → i, Türkçe "ı" beklenir)
///   "ışık".uppercased()   → "IŞIK"     yanlış (i → I, Türkçe "İ" beklenir)
///
/// Türkçe'de:
///   I (büyük) ↔ ı (dotless küçük)
///   İ (dotted büyük) ↔ i (küçük)
///
/// Tüm UI metni Türkçe olduğundan default Locale çağrıları toptan
/// `.trLower` / `.trUpper`'a çevrildi.
extension String {
    private static let trLocale = Locale(identifier: "tr_TR")

    var trLower: String { lowercased(with: Self.trLocale) }
    var trUpper: String { uppercased(with: Self.trLocale) }
}
