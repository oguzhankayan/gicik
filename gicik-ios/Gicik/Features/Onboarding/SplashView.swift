import SwiftUI

/// Splash — Y2K logo + tagline + "başla" CTA.
/// design-source/parts/onboarding.jsx → SplashScreen
struct SplashView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // Glow halo behind logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.pink.opacity(0.5),
                            AppColor.purple.opacity(0.3),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 40)
                .offset(y: -120)

            VStack {
                Spacer()
                Logo(size: 88)
                Text("yazma. gıcık yazsın.")
                    .font(AppFont.body(16))
                    .foregroundColor(AppColor.text60)
                    .padding(.top, 28)
                Spacer()

                PrimaryButton("başla", action: onContinue)
                    .padding(.horizontal, 24)

                Text("giriş yaparak şartları kabul ediyorsun")
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
                    .padding(.top, 14)
                    .padding(.bottom, 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
