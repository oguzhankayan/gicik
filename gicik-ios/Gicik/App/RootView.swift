import SwiftUI

/// Auth + onboarding state'ine göre routing.
/// 1. Sign in olmadıysa → SignInView
/// 2. Sign in oldu ama onboarding tamamlanmadıysa → OnboardingFlowView
/// 3. İkisi de tamam → MainShellView
struct RootView: View {
    @State private var auth = AuthService.shared
    @AppStorage("gicik.onboarding.completed") private var onboardingCompleted: Bool = false

    var body: some View {
        ZStack {
            CosmicBackground()

            if !auth.isSignedIn {
                SignInView()
            } else if !onboardingCompleted {
                OnboardingFlowView {
                    onboardingCompleted = true
                }
            } else {
                MainShellView()
            }
        }
        .animation(AppAnimation.standard, value: auth.isSignedIn)
        .animation(AppAnimation.standard, value: onboardingCompleted)
        // Y2K / kompakt UI tasarımı çok büyük accessibility size'larda dağılır.
        // Cap büyük accessibility level'lere (XL3'e kadar). Phase 5 polish'te
        // her text style ayrı kalibre edilebilir.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

/// Phase 2'de mode kartları + history ile değiştirilir.
struct MainShellView: View {
    var body: some View {
        HomeView()
    }
}
