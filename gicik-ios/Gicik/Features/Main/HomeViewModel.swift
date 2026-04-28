import Foundation
import SwiftUI
import PhotosUI

/// Main flow state machine: Home → Picker → Tone → Generation → Result.
/// Phase 2'de mock data kullanır. Phase 2.4'te gerçek backend bağlanır.
enum FlowStage: Equatable {
    case home
    case picker(Mode)
    case generation(Mode, screenshot: Data)
    case result(GenerationResult)
}

@Observable
@MainActor
final class HomeViewModel {
    var stage: FlowStage = .home
    var pickerState: PickerState = .empty
    var lastError: String?
    var history: [ConversationHistoryItem] = []

    // For picker
    var pickedItem: PhotosPickerItem? {
        didSet { Task { await handlePickedItem() } }
    }
    var pickedScreenshot: Data?

    // Profile cache (set after onboarding)
    var archetype: ArchetypePrimary? = .dryroaster

    enum PickerState: Equatable {
        case empty
        case uploading(progress: Double)
        case done(thumbnail: Data)
    }

    init() {
        loadMockHistory()
    }

    // MARK: - Stage transitions

    func selectMode(_ mode: Mode) {
        stage = .picker(mode)
        pickerState = .empty
        pickedScreenshot = nil
    }

    func backToHome() {
        stage = .home
    }

    /// Picker'dan generation'a doğrudan geç — ton seçimi yok.
    func proceedToGeneration() {
        guard case .picker(let mode) = stage,
              let data = pickedScreenshot else { return }
        stage = .generation(mode, screenshot: data)
        Task { await runRealGeneration(mode: mode, imageData: data) }
    }

    /// Streaming partial result — GenerationView reads this for live UI.
    /// Phase 2.4 wired to real SSE.
    var streamingObservation: String = ""
    var streamingReplies: [Int: ReplyOption] = [:]
    var conversationId: String?

    func reset() {
        stage = .home
        pickerState = .empty
        pickedScreenshot = nil
        pickedItem = nil
    }

    // MARK: - Picker handling

    private func handlePickedItem() async {
        guard let item = pickedItem else { return }
        pickerState = .uploading(progress: 0.3)
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                pickerState = .uploading(progress: 0.7)
                try? await Task.sleep(nanoseconds: 400_000_000)
                pickedScreenshot = data
                pickerState = .done(thumbnail: data)
            } else {
                lastError = "fotoğraf yüklenemedi"
                pickerState = .empty
            }
        } catch {
            lastError = error.localizedDescription
            pickerState = .empty
        }
    }

    // MARK: - Real generation (Phase 2.3 + 2.4 wired)

    private func runRealGeneration(mode: Mode, imageData: Data) async {
        streamingObservation = ""
        streamingReplies = [:]
        conversationId = nil

        // Stage 1: parse-screenshot (multipart)
        struct ParseResp: Decodable {
            let conversation_id: String
            let parse_result: ParseResultDTO
            let duration_ms: Int
        }

        let parseResp: ParseResp
        do {
            parseResp = try await APIClient.shared.invokeMultipart(
                .parseScreenshot,
                imageData: imageData,
                imageMimeType: "image/jpeg",
                formFields: ["mode": mode.rawValue],
                as: ParseResp.self
            )
            conversationId = parseResp.conversation_id
        } catch {
            lastError = "parse: \(error.localizedDescription)"
            // Show error state on result screen so user can retry
            stage = .result(GenerationResult(
                observation: "bağlantı sorunu. tekrar dene.",
                replies: [],
                conversationId: nil,
                mode: mode
            ))
            return
        }

        // Stage 2: generate-replies (SSE) — backend 3 ton seçer
        struct GenBody: Encodable {
            let conversation_id: String
        }

        let body = GenBody(conversation_id: parseResp.conversation_id)
        var finalReplies: [ReplyOption] = []
        var observation = ""

        do {
            for try await event in APIClient.shared.invokeStream(.generateReplies, body: body) {
                switch event {
                case .observation(let text):
                    observation = text
                    streamingObservation = text
                case .reply(let index, let tone, let text):
                    let r = ReplyOption(index: index, tone: tone, text: text)
                    streamingReplies[index] = r
                case .done:
                    break
                case .error(let msg):
                    lastError = "generate: \(msg)"
                case .unknown:
                    continue
                }
            }
        } catch {
            lastError = "generate: \(error.localizedDescription)"
        }

        finalReplies = (0..<3).compactMap { streamingReplies[$0] }

        if finalReplies.isEmpty {
            stage = .result(GenerationResult(
                observation: observation.isEmpty ? "üretim başarısız." : observation,
                replies: [],
                conversationId: conversationId,
                mode: mode
            ))
            return
        }

        stage = .result(GenerationResult(
            observation: observation,
            replies: finalReplies,
            conversationId: conversationId,
            mode: mode
        ))

        // Append to history
        history.insert(.init(
            id: conversationId ?? UUID().uuidString,
            mode: mode,
            platform: "image",
            createdAt: Date(),
            snippet: "\"\(finalReplies.first?.text.prefix(40) ?? "")...\""
        ), at: 0)
    }

    /// Mirror of backend ParseResult — only fields we care about on the client.
    private struct ParseResultDTO: Decodable {
        let platform_detected: String?
        let context_summary_tr: String?
    }

    // ─── mock helpers retired (backend gerçek üretim yapıyor) ───
    /*

    private func mockObservation(for mode: Mode) -> String {
        switch mode {
        case .cevap: "üçü de farklı açıdan giriyor. 02 risk seviyesi en yüksek."
        case .acilis: "profilde bir detay var, klişeden uzak. ona dokun."
        case .bio: "üç versiyon, üç farklı ses. en az birinde kendini gör."
        case .hayalet: "üçüncü gün eşiği. yazma da geçerli bir cevap."
        case .davet: "konuşmanın zemini iyi. davet için hazır."
        }
    }

    private func mockReplies(for mode: Mode, tone: Tone) -> [ReplyOption] {
        // Sample data — gerçek üretim Phase 2.4'te.
        switch mode {
        case .cevap:
            return [
                .init(index: 0, toneAngle: "DOĞRUDAN ENGAGE",
                      text: "üç gün sonra 'selam' yetmez. en azından 'merhaba' deseydin. ne yapıyoruz?"),
                .init(index: 1, toneAngle: "İMA",
                      text: "ortadan kaybolan birinin geri dönüşü, genelde dönmek için değil bakmak için olur. hangisi sen?"),
                .init(index: 2, toneAngle: "KISA",
                      text: "selam. üç gün uzun bir sessizlik. iyi misin?"),
            ]
        case .acilis:
            return [
                .init(index: 0, toneAngle: "SPESİFİK", text: "huysuz kediyle huysuz insan arasında fark var mı?"),
                .init(index: 1, toneAngle: "SORU", text: "üç huysuzluğun ortak özelliği ne?"),
                .init(index: 2, toneAngle: "İRONİ", text: "kahve, kitap, kedi listene 'huy' eklersen tehlikeli oluyor."),
            ]
        default:
            return [
                .init(index: 0, toneAngle: "ANGLE 1", text: "mock cevap 1"),
                .init(index: 1, toneAngle: "ANGLE 2", text: "mock cevap 2"),
                .init(index: 2, toneAngle: "ANGLE 3", text: "mock cevap 3"),
            ]
        }
    }

    */

    private func loadMockHistory() {
        // Boş başla — gerçek conversations DB'den yüklenecek (Phase 3'te).
        history = []
    }
}
