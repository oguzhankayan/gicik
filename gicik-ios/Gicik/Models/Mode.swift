import Foundation

/// 5 mod + locked "yakında" placeholder.
/// Backend types.ts ile uyumlu.
enum Mode: String, Codable, CaseIterable, Identifiable {
    case cevap, acilis, bio, hayalet, davet
    var id: String { rawValue }

    var label: String {
        switch self {
        case .cevap: "CEVAP"
        case .acilis: "AÇILIŞ"
        case .bio: "BIO"
        case .hayalet: "HAYALET"
        case .davet: "DAVET"
        }
    }

    var subtitle: String {
        switch self {
        case .cevap: "gelen mesaja cevap"
        case .acilis: "ilk mesaj"
        case .bio: "profil yazısı"
        case .hayalet: "ghost edildi"
        case .davet: "buluşmaya çağır"
        }
    }

    var systemIcon: String {
        switch self {
        case .cevap: "bubble.left"
        case .acilis: "sparkles"
        case .bio: "list.bullet"
        case .hayalet: "moon"
        case .davet: "paperplane"
        }
    }

    /// Free tier'da sadece cevap kullanılabilir.
    var requiresPremium: Bool { self != .cevap }
}
