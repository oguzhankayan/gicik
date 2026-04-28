import SwiftUI

/// Onboarding ana shell — ViewModel'in step'ine göre alt-view göster.
/// NavigationStack kullanmıyoruz — tek root view, içeriği transition ile değişiyor.
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
        case .demographic:
            DemographicView(vm: vm)
        case .calibrationIntro:
            CalibrationIntroView(onContinue: vm.advance)
        case .calibrationQuiz:
            CalibrationQuizView(vm: vm)
        case .calibrationResult:
            CalibrationResultView(vm: vm)
        case .demoUpload:
            DemoUploadView(onContinue: vm.advance)
        case .notification:
            NotificationPermissionView(vm: vm)
        case .aiConsent:
            AIConsentView(vm: vm)
        case .paywall:
            // Phase 4'te. Şimdilik direkt geç.
            PaywallPlaceholderView(onContinue: { vm.advance() })
        case .completed:
            Color.clear.onAppear { onComplete() }
        }
    }
}

/// Phase 4'e kadar placeholder.
struct PaywallPlaceholderView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack {
            Spacer()
            Text("paywall")
                .font(AppFont.display(40, weight: .bold))
                .foregroundColor(.white)
            Text("phase 4'te aktif olacak")
                .font(AppFont.body(13))
                .italic()
                .foregroundColor(AppColor.text40)
            Spacer()
            PrimaryButton("şimdilik geç", style: .holoBorder, action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
    }
}
