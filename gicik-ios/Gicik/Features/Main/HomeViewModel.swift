import Foundation
import SwiftUI
import PhotosUI

/// Main flow state machine: Home → Picker → Tone → Generation → Result.
/// Phase 2'de mock data kullanır. Phase 2.4'te gerçek backend bağlanır.
enum FlowStage: Equatable {
    case home
    case picker(Mode)
    case tone(Mode, screenshot: Data)
    case generation(Mode, Tone, screenshot: Data)
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

    func proceedToToneSelector() {
        guard case .picker(let mode) = stage,
              let data = pickedScreenshot else { return }
        stage = .tone(mode, screenshot: data)
    }

    func selectTone(_ tone: Tone) {
        guard case .tone(let mode, let data) = stage else { return }
        stage = .generation(mode, tone, screenshot: data)
        Task { await runGeneration(mode: mode, tone: tone) }
    }

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

    // MARK: - Mock generation

    /// Phase 2'de mock. Phase 2.4'te SSE backend stream'i ile değişir.
    private func runGeneration(mode: Mode, tone: Tone) async {
        let mock = GenerationResult(
            observation: mockObservation(for: mode),
            replies: mockReplies(for: mode, tone: tone),
            conversationId: UUID().uuidString,
            mode: mode,
            tone: tone
        )
        // Streaming benzeri bekleme
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        stage = .result(mock)
    }

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

    private func loadMockHistory() {
        history = [
            .init(id: "1", mode: .cevap, platform: "tinder",
                  createdAt: Date().addingTimeInterval(-720),
                  snippet: "\"huysuzluğun ortak özelliği...\""),
            .init(id: "2", mode: .acilis, platform: "bumble",
                  createdAt: Date().addingTimeInterval(-7200),
                  snippet: "\"profilin bana fazla iyi...\""),
            .init(id: "3", mode: .hayalet, platform: "instagram",
                  createdAt: Date().addingTimeInterval(-90000),
                  snippet: "\"3 gün cevap yok, sonra...\""),
        ]
    }
}
