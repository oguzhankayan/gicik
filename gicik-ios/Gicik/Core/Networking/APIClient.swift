import Foundation
import Supabase

/// Thin wrapper around Supabase edge functions with a JWT-aware client.
/// SSE streaming uses URLSession.bytes (iOS 15+, async).
@MainActor
final class APIClient {
    static let shared = APIClient()

    private init() {}

    private var supabase: SupabaseClient { SupabaseService.shared.client }

    // ──────────────────────────────────────────────────────────
    // JSON request → JSON response
    // ──────────────────────────────────────────────────────────

    func invokeJSON<Response: Decodable>(
        _ endpoint: Endpoint,
        body: Encodable? = nil,
        as: Response.Type = Response.self,
    ) async throws -> Response {
        let token = try await accessToken()

        let url = Configuration.supabaseURL.appendingPathComponent("functions/v1/\(endpoint.rawValue)")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(Configuration.supabaseAnonKey, forHTTPHeaderField: "apikey")

        if let body {
            req.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown("invalid response")
        }

        if http.statusCode >= 400 {
            throw try mapError(data: data, status: http.statusCode)
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }

    // ──────────────────────────────────────────────────────────
    // Multipart upload (parse-screenshot)
    // ──────────────────────────────────────────────────────────

    func invokeMultipart<Response: Decodable>(
        _ endpoint: Endpoint,
        imageData: Data,
        imageMimeType: String = "image/jpeg",
        formFields: [String: String] = [:],
        as: Response.Type = Response.self,
    ) async throws -> Response {
        let token = try await accessToken()
        let url = Configuration.supabaseURL.appendingPathComponent("functions/v1/\(endpoint.rawValue)")

        let boundary = "----GicikBoundary\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(Configuration.supabaseAnonKey, forHTTPHeaderField: "apikey")

        var body = Data()
        let crlf = "\r\n"

        for (k, v) in formFields {
            body.append("--\(boundary)\(crlf)".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(k)\"\(crlf)\(crlf)".data(using: .utf8)!)
            body.append(v.data(using: .utf8)!)
            body.append(crlf.data(using: .utf8)!)
        }

        body.append("--\(boundary)\(crlf)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"screenshot\"; filename=\"screenshot.jpg\"\(crlf)".data(using: .utf8)!)
        body.append("Content-Type: \(imageMimeType)\(crlf)\(crlf)".data(using: .utf8)!)
        body.append(imageData)
        body.append(crlf.data(using: .utf8)!)
        body.append("--\(boundary)--\(crlf)".data(using: .utf8)!)

        req.httpBody = body

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown("invalid response")
        }
        if http.statusCode >= 400 {
            throw try mapError(data: respData, status: http.statusCode)
        }
        return try JSONDecoder().decode(Response.self, from: respData)
    }

    // ──────────────────────────────────────────────────────────
    // SSE stream (generate-replies)
    // ──────────────────────────────────────────────────────────

    /// Yields parsed SSE events from a POST body.
    /// Caller pattern-matches on `SSEEvent`.
    func invokeStream(
        _ endpoint: Endpoint,
        body: Encodable,
    ) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let token = try await accessToken()
                    let url = Configuration.supabaseURL.appendingPathComponent("functions/v1/\(endpoint.rawValue)")
                    var req = URLRequest(url: url)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    req.setValue(Configuration.supabaseAnonKey, forHTTPHeaderField: "apikey")
                    req.httpBody = try JSONEncoder().encode(AnyEncodable(body))

                    let (bytes, response) = try await URLSession.shared.bytes(for: req)
                    guard let http = response as? HTTPURLResponse else {
                        continuation.finish(throwing: APIError.unknown("invalid response"))
                        return
                    }
                    if http.statusCode >= 400 {
                        var data = Data()
                        for try await b in bytes { data.append(b) }
                        continuation.finish(throwing: try mapError(data: data, status: http.statusCode))
                        return
                    }

                    var buffer = ""
                    for try await line in bytes.lines {
                        if line.isEmpty {
                            // SSE event terminator (single empty line after "data:")
                            // We accumulate via prefix-stripping per-line below.
                            continue
                        }
                        if line.hasPrefix("data:") {
                            let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                            if payload.isEmpty || payload == "[DONE]" { continue }
                            buffer = payload
                            if let data = buffer.data(using: .utf8),
                               let event = try? JSONDecoder().decode(SSEEvent.self, from: data) {
                                continuation.yield(event)
                                if case .done = event { break }
                            }
                            buffer = ""
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // ──────────────────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────────────────

    private func accessToken() async throws -> String {
        // Fall back to anon key if no user session (lets us call edge functions
        // that explicitly accept anon auth — none of ours, but safe).
        let session = try? await supabase.auth.session
        return session?.accessToken ?? Configuration.supabaseAnonKey
    }

    private func mapError(data: Data, status: Int) throws -> APIError {
        if let body = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return APIError.map(body)
        }
        let raw = String(data: data, encoding: .utf8) ?? ""
        return .server(code: "http_\(status)", message: raw.isEmpty ? "HTTP \(status)" : raw)
    }
}

// MARK: - SSE event model

enum SSEEvent: Decodable, Sendable {
    case observation(text: String)
    case reply(index: Int, tone: String, text: String)
    case done(durationMs: Int, conversationId: String)
    case error(message: String)
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type, text, index, tone
        case durationMs = "duration_ms"
        case conversationId = "conversation_id"
        case message
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? c.decode(String.self, forKey: .type)) ?? ""
        switch type {
        case "observation":
            let text = (try? c.decode(String.self, forKey: .text)) ?? ""
            self = .observation(text: text)
        case "reply":
            let index = (try? c.decode(Int.self, forKey: .index)) ?? 0
            let tone = (try? c.decode(String.self, forKey: .tone)) ?? ""
            let text = (try? c.decode(String.self, forKey: .text)) ?? ""
            self = .reply(index: index, tone: tone, text: text)
        case "done":
            let ms = (try? c.decode(Int.self, forKey: .durationMs)) ?? 0
            let id = (try? c.decode(String.self, forKey: .conversationId)) ?? ""
            self = .done(durationMs: ms, conversationId: id)
        case "error":
            let msg = (try? c.decode(String.self, forKey: .message)) ?? ""
            self = .error(message: msg)
        default:
            self = .unknown
        }
    }
}

// MARK: - AnyEncodable helper

private struct AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}
