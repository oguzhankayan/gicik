import SwiftUI

/// Onboarding ana shell — Rizz playbook (2026-04-30 reorder).
/// Yeni sıra: splash → value → calibrate → demographic → demo → notif → star → preview → consent → paywall.
struct OnboardingFlowView: View {
    @State private var vm = OnboardingViewModel()
    @State private var auth = AuthService.shared

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            currentStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .id(vm.step)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CosmicBackground())
        .animation(AppAnimation.standard, value: vm.step)
        .animation(AppAnimation.standard, value: vm.quizIndex)
    }

    @ViewBuilder
    private var currentStep: some View {
        switch vm.step {
        case .splash:
            SplashView(onContinue: vm.advance)
        case .valueIntro:
            ValueIntroView(onContinue: vm.advance)
        case .calibrationIntro:
            CalibrationIntroView(onContinue: vm.advance)
        case .calibrationQuiz:
            CalibrationQuizView(vm: vm)
        case .calibrationResult:
            CalibrationResultView(vm: vm)
        case .demographic:
            DemographicView(vm: vm)
        case .demoUpload:
            DemoUploadView(onContinue: vm.advance)
        case .notification:
            NotificationPermissionView(vm: vm)
        case .starRating:
            StarRatingPrimeView(vm: vm)
        case .prePaywallValue:
            PrePaywallValueView(vm: vm, onContinue: vm.advance)
        case .aiConsent:
            AIConsentView(vm: vm)
        case .paywall:
            PaywallView(onContinue: { vm.advance() })
        case .completed:
            Color.clear.onAppear { onComplete() }
        }
    }
}
