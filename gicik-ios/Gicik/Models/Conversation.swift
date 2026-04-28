import Foundation

/// Single reply suggestion (output sesi).
struct ReplyOption: Identifiable, Codable, Equatable, Sendable {
    let index: Int
    let toneAngle: String   // "doğrudan engage" | "ima" | "kısa" | ...
    var text: String

    var id: Int { index }
}

/// Full generation result (asistan obs + 3 reply).
struct GenerationResult: Codable, Equatable, Sendable {
    var observation: String       // Asistan sesi
    var replies: [ReplyOption]    // 3 cevap önerisi
    var conversationId: String?
    var mode: Mode
    var tone: Tone
}

/// History row (HomeView'da son kullanım kartları).
struct ConversationHistoryItem: Identifiable, Equatable {
    let id: String
    let mode: Mode
    let platform: String  // "tinder" | "bumble" | "imessage" | ...
    let createdAt: Date
    let snippet: String

    var relativeTime: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "şimdi" }
        if interval < 3600 { return "\(Int(interval/60))dk önce" }
        if interval < 86400 { return "\(Int(interval/3600))sa önce" }
        if interval < 172800 { return "dün" }
        return "\(Int(interval/86400))g önce"
    }
}
