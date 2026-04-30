import Foundation
import Observation

/// Onboarding flow state machine — Rizz playbook (2026-04-30 reorder).
/// Yeni sıra: value önce, demographic sona. Calibration ortada (kullanıcı zaten içeride).
/// Paywall öncesi value carousel + star prime ile commitment ramping.
enum OnboardingStep: Int, CaseIterable {
    case splash               // cinematic, auto-advance
    case valueIntro           // 3-page swipeable carousel
    case calibrationIntro
    case calibrationQuiz
    case calibrationResult
    case demographic          // sona alındı, kullanıcı zaten ısındı
    case demoUpload
    case notification         // cinematic 3D bell
    case starRating           // SKStoreReview prime
    case prePaywallValue      // archetype-aware reinforcement
    case aiConsent
    case paywall              // single tier weekly + carousel
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
            advance()
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
            goBack()
        }
    }

    // MARK: - Calibration submission

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
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
            self.archetype = nil
        }
    }

    func retryCalibrationSubmit() {
        Task { await submitCalibration() }
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
