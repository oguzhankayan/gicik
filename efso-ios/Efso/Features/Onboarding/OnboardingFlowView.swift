import SwiftUI

/// Onboarding ana shell (Rizz playbook reorder).
/// Sıra: splash → value → notif → demographic → consent → paywall → calibration → home.
struct OnboardingFlowView: View {
    @State private var vm = OnboardingViewModel()

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
        case .notification:
            NotificationPermissionView(vm: vm)
        case .demographic:
            DemographicView(vm: vm)
        case .aiConsent:
            AIConsentView(vm: vm)
        case .paywall:
            PaywallView(onContinue: { vm.advance() })
        case .calibrationIntro:
            CalibrationIntroView(vm: vm)
        case .calibrationQuiz:
            CalibrationQuizView(vm: vm)
        case .calibrationResult:
            CalibrationResultView(vm: vm)
        case .completed:
            Color.clear.onAppear { onComplete() }
        }
    }
}
