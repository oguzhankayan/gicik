import SwiftUI

/// Auth + onboarding state'ine göre routing.
/// Anonymous-first: SignInView yok. Bootstrap bitene kadar splash, sonra
/// onboarding tamamlanmadıysa flow, tamamlandıysa MainShell.
struct RootView: View {
    @State private var auth = AuthService.shared
    // String literal yerine UDKey case'i — drift riski sıfır, tek doğru kaynak.
    @AppStorage(UDKey.onboardingCompleted.rawValue) private var onboardingCompleted: Bool = false

    var body: some View {
        ZStack {
            CosmicBackground()

            if auth.isRestoring {
                AuthRestoreSplash()
            } else if !auth.isSignedIn {
                AuthFailureView { Task { await auth.bootstrap() } }
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

/// Bootstrap (session restore + anon sign-in) sırasında gösterilen statik
/// brand splash. Cinematic SplashView'dan farklı: onContinue beklemez, sadece
/// marka.
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

private struct AuthFailureView: View {
    let onRetry: () -> Void
    @State private var isRetrying = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "wifi.slash")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppColor.text40)
            Text("bağlantı kurulamadı")
                .font(AppFont.displayItalic(22))
                .foregroundColor(AppColor.ink)
            Text("internet bağlantını kontrol edip tekrar dene.")
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            PrimaryButton("tekrar dene", isEnabled: !isRetrying) {
                isRetrying = true
                onRetry()
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isRetrying = false
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
