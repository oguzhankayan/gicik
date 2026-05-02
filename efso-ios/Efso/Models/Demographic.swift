import Foundation

enum Gender: String, Codable, CaseIterable {
    case female, male, unspecified
    var label: String {
        switch self {
        case .female: "kadın"
        case .male: "erkek"
        case .unspecified: "belirtmiyorum"
        }
    }
}

enum AgeBracket: String, Codable, CaseIterable {
    case b18_24 = "18-24"
    case b25_34 = "25-34"
    case b35_44 = "35-44"
    case b45 = "45+"
    var label: String { rawValue }
}

enum Intent: String, Codable, CaseIterable {
    case relationship, casual, fun, taken
    var emoji: String {
        switch self {
        case .relationship: "💞"
        case .casual: "🌙"
        case .fun: "🎭"
        case .taken: "💍"
        }
    }
    var label: String {
        switch self {
        case .relationship: "ilişki"
        case .casual: "rahat"
        case .fun: "eğlence"
        case .taken: "ilişkim var"
        }
    }
}

struct DemographicAnswers: Codable, Equatable {
    var gender: Gender?
    var ageBracket: AgeBracket?
    var intent: Intent?

    var isComplete: Bool {
        gender != nil && ageBracket != nil && intent != nil
    }
}
