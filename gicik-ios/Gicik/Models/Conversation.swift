import Foundation

/// Single reply suggestion (output sesi).
/// Her reply farklı bir tonda üretilir; backend 3 default ton seçer.
struct ReplyOption: Identifiable, Codable, Equatable, Sendable {
    let index: Int
    /// "flortoz" | "esprili" | "direkt" | "sicak" | "gizemli" | "silence" (hayalet)
    var tone: String
    var text: String

    var id: Int { index }

    /// `Tone` enum'a parse edilebiliyorsa onu döner; "silence" veya bilinmeyen ise nil.
    var toneEnum: Tone? { Tone(rawValue: tone) }

    /// UI'da gösterilecek label.
    var toneLabel: String {
        if let t = toneEnum { return t.label }
        if tone == "silence" { return "SESSİZLİK" }
        return tone.trUpper
    }
}

/// Full generation result (asistan obs + 3 reply, her reply kendi ton'unda).
struct GenerationResult: Codable, Equatable, Sendable {
    var observation: String       // Asistan sesi
    var replies: [ReplyOption]    // 3 cevap önerisi (her biri farklı ton)
    var conversationId: String?
    var mode: Mode
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
