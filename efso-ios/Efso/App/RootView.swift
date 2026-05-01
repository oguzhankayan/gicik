import SwiftUI

/// Auth + onboarding state'ine göre routing.
/// 1. Sign in olmadıysa → SignInView
/// 2. Sign in oldu ama onboarding tamamlanmadıysa → OnboardingFlowView
/// 3. İkisi de tamam → MainShellView
struct RootView: View {
    @State private var auth = AuthService.shared
    // String literal yerine UDKey case'i — drift riski sıfır, tek doğru kaynak.
    @AppStorage(UDKey.onboardingCompleted.rawValue) private var onboardingCompleted: Bool = false

    var body: some View {
        ZStack {
            CosmicBackground()

            // Cold-launch: restoreSession bitene kadar minimal brand
            // bekleme ekranı. Aksi halde 1 frame SignInView flash ediyor,
            // sonra Home'a atlıyordu. SplashView onboarding-spesifik
            // (cinematic + onContinue) olduğu için reuse etmiyoruz.
            if auth.isRestoring {
                AuthRestoreSplash()
            } else if !auth.isSignedIn {
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
        .animation(AppAnimation.standard, value: auth.isRestoring)
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

/// Auth restore sırasında gösterilen statik brand splash.
/// Cinematic SplashView'dan farklı: onContinue beklemez, sadece marka.
private struct AuthRestoreSplash: View {
    var body: some View {
        VStack {
            Spacer()
            Logo(size: 36)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
