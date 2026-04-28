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
    func submitCalibration() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let answers = Array(quizAnswers.values)

        struct CalibrateBody: Encodable {
            let answers: [CalibrationAnswer]
        }

        do {
            let result: ArchetypeResult = try await APIClient.shared.invokeJSON(
                .calibrate,
                body: CalibrateBody(answers: answers),
                as: ArchetypeResult.self
            )
            self.archetype = result
        } catch {
            self.lastError = error.localizedDescription
            // Fallback: don't block onboarding even if backend fails — pick best-guess archetype
            // so user can still continue.
            let fallback: ArchetypePrimary = .dryroaster
            self.archetype = ArchetypeResult(
                archetypePrimary: fallback,
                archetypeSecondary: .observer,
                displayLabel: fallback.label,
                displayDescription: fallback.description
            )
        }
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
