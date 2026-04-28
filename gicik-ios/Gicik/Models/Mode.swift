import Foundation

/// 2 mod (MVP).
/// Bio / Hayalet / Davet master prompt'tan çıkarıldı — Phase 3+'ta yeniden değerlendirilebilir.
enum Mode: String, Codable, CaseIterable, Identifiable {
    case cevap, acilis
    var id: String { rawValue }

    var label: String {
        switch self {
        case .cevap: "CEVAP"
        case .acilis: "AÇILIŞ"
        }
    }

    var subtitle: String {
        switch self {
        case .cevap: "gelen mesaja cevap"
        case .acilis: "ilk mesaj"
        }
    }

    var systemIcon: String {
        switch self {
        case .cevap: "bubble.left"
        case .acilis: "sparkles"
        }
    }

    /// MVP: tüm modlar açık. Phase 4'te paywall gelirse buradan gate edilir.
    var requiresPremium: Bool { false }
}
