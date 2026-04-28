import SwiftUI

/// Auth state'e göre routing.
struct RootView: View {
    @State private var auth = AuthService.shared

    var body: some View {
        ZStack {
            CosmicBackground()

            if auth.isSignedIn {
                MainShellView()
            } else {
                SignInView()
            }
        }
        .animation(AppAnimation.standard, value: auth.isSignedIn)
    }
}

/// Phase 1'de OnboardingFlowView ile değiştirilir (kullanıcı kalibrasyon yapmadıysa).
struct MainShellView: View {
    var body: some View {
        HomeView()
    }
}
