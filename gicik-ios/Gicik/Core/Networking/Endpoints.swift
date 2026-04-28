import Foundation

/// Edge function endpoint isimleri — `SupabaseService.shared.functions.invoke(...)` ile çağrılır.
enum Endpoint: String {
    case calibrate = "calibrate"
    case parseScreenshot = "parse-screenshot"
    case generateReplies = "generate-replies"
    case promptFeedback = "prompt-feedback"
    case revenueCatWebhook = "revenuecat-webhook"
}
