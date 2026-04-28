import Foundation

/// API error model — backend `_shared/types.ts`'deki `ApiError` ile uyumlu.
struct APIErrorResponse: Decodable, Error {
    let error: ErrorBody

    struct ErrorBody: Decodable {
        let code: String
        let message: String
    }
}

enum APIError: Error, LocalizedError {
    case unauthenticated
    case rateLimited
    case freeTierExceeded
    case invalidInput(String)
    case injectionBlocked
    case llmFailure
    case unsupportedImage
    case network(URLError)
    case decoding(Error)
    case server(code: String, message: String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .unauthenticated: "oturum açmalısın"
        case .rateLimited: "çok hızlı denedin, biraz bekle"
        case .freeTierExceeded: "günlük limitin doldu"
        case .invalidInput(let msg): "geçersiz girdi: \(msg)"
        case .injectionBlocked: "bu mesaj işlenemedi"
        case .llmFailure: "üretim başarısız, tekrar dene"
        case .unsupportedImage: "bu görsel desteklenmiyor"
        case .network: "bağlantı sorunu"
        case .decoding: "yanıt çözümlenemedi"
        case .server(_, let msg): msg
        case .unknown(let msg): msg
        }
    }

    static func map(_ response: APIErrorResponse) -> APIError {
        switch response.error.code {
        case "unauthenticated": .unauthenticated
        case "rate_limited": .rateLimited
        case "free_tier_exceeded": .freeTierExceeded
        case "invalid_input": .invalidInput(response.error.message)
        case "injection_blocked": .injectionBlocked
        case "llm_failure": .llmFailure
        case "unsupported_image": .unsupportedImage
        default: .server(code: response.error.code, message: response.error.message)
        }
    }
}
