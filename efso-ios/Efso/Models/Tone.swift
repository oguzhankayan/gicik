import Foundation

enum Tone: String, Codable, CaseIterable, Identifiable {
    case flortoz, esprili, direkt, sicak, gizemli
    var id: String { rawValue }

    var label: String {
        switch self {
        case .flortoz: "FLÖRTÖZ"
        case .esprili: "ESPRİLİ"
        case .direkt: "DİREKT"
        case .sicak: "SICAK"
        case .gizemli: "GİZEMLİ"
        }
    }

    var emoji: String {
        switch self {
        case .flortoz: "💋"
        case .esprili: "😏"
        case .direkt: "🎯"
        case .sicak: "🤍"
        case .gizemli: "🌑"
        }
    }

    var description: String {
        switch self {
        case .flortoz: "ima + cesaret + kapatıcı"
        case .esprili: "zekayla flört, pun yok"
        case .direkt: "net, oyalamayan, saygılı"
        case .sicak: "samimi, biraz vulnerable"
        case .gizemli: "az veren, merak uyandıran"
        }
    }

    static let allLabels: [String] = allCases.map { $0.label.trLower }

    /// Arketipe göre default önerilen tone.
    static func recommended(for archetype: ArchetypePrimary?) -> Tone {
        switch archetype {
        case .dryroaster: .esprili
        case .observer: .gizemli
        case .softie_with_edges: .sicak
        case .chaos_agent: .flortoz
        case .strategist: .direkt
        case .romantic_pessimist: .sicak
        case nil: .esprili
        }
    }
}
