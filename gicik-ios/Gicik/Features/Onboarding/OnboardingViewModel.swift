import Foundation
import Observation

/// Onboarding flow state machine — splash to paywall.
/// Master prompt §5: 12 ekran (skip yok, paywall hariç).
enum OnboardingStep: Int, CaseIterable {
    case splash
    case demographic
    case calibrationIntro
    case calibrationQuiz
    case calibrationResult
    case demoUpload
    case notification
    case aiConsent
    case paywall            // Phase 4'te aktif
    case completed
}

@Observable
@MainActor
final class OnboardingViewModel {
    var step: OnboardingStep = .splash

    var demographic = DemographicAnswers()
    var quizAnswers: [String: CalibrationAnswer] = [:]
    var quizIndex: Int = 0
    var questions: [CalibrationQuestion] = []

    var archetype: ArchetypeResult?
    var notificationGranted: Bool = false
    var aiConsentGiven: Bool = false

    var isSubmitting = false
    var lastError: String?

    init() {
        loadQuestions()
    }

    // MARK: - Step navigation

    func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let prev = OnboardingStep(rawValue: step.rawValue - 1), prev.rawValue >= 0 else { return }
        step = prev
    }

    // MARK: - Quiz

    var currentQuestion: CalibrationQuestion? {
        questions.indices.contains(quizIndex) ? questions[quizIndex] : nil
    }

    var totalQuestions: Int { questions.count }

    func recordAnswer(_ answer: CalibrationAnswer) {
        quizAnswers[answer.questionId] = answer
    }

    func nextQuestion() {
        if quizIndex < questions.count - 1 {
            quizIndex += 1
        } else {
            // Quiz tamam, sonuca geç
            advance()  // calibrationQuiz → calibrationResult
        }
    }

    func skipCurrentQuestion() {
        guard let q = currentQuestion, q.optional == true else { return }
        nextQuestion()
    }

    func goToPreviousQuestion() {
        if quizIndex > 0 {
            quizIndex -= 1
        } else {
            goBack() // back to calibrationIntro
        }
    }

    // MARK: - Calibration submission

    /// Phase 1.4 — backend `/calibrate` endpoint'ini çağırır.
    /// Şu an mock. Gerçek deploy sonrası SupabaseService.shared.functions.invoke kullanılacak.
    func submitCalibration() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let answers = Array(quizAnswers.values)

        // Mock: deterministic local archetype (matches backend logic)
        let archetype = mockDeriveArchetype(from: answers)
        try? await Task.sleep(nanoseconds: 800_000_000)
        self.archetype = ArchetypeResult(
            archetypePrimary: archetype,
            archetypeSecondary: .observer,
            displayLabel: archetype.label,
            displayDescription: archetype.description
        )
    }

    private func mockDeriveArchetype(from answers: [CalibrationAnswer]) -> ArchetypePrimary {
        let directness = answers.first { $0.questionId == "directness" }?.selected.first
        let humor = answers.first { $0.questionId == "humor_style" }?.selected.first

        if directness == "direct" && humor?.contains("sarcasm") == true {
            return .dryroaster
        }
        if directness == "indirect" {
            return .observer
        }
        return .dryroaster // safe default
    }

    // MARK: - Question loading

    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "calibration-questions", withExtension: "json") else {
            self.lastError = "calibration-questions.json bulunamadı"
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.questions = try JSONDecoder().decode([CalibrationQuestion].self, from: data)
        } catch {
            self.lastError = "questions decode failed: \(error.localizedDescription)"
        }
    }
}
