import SwiftUI

/// Calibration intro — orbital ring animation + "9 soru. 2 dakika" + başla.
/// design-source/parts/onboarding.jsx → CalibrationIntro
struct CalibrationIntroView: View {
    let onContinue: () -> Void
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 1, total: 12)
            Spacer()
            orbital
            Text("efso'ı kalibre et")
                .font(AppFont.display(30, weight: .bold))
                .tracking(-0.02 * 30)
                .foregroundColor(.white)
                .padding(.top, 32)
                .multilineTextAlignment(.center)

            Text("9 soru. 2 dakika. soru sormaya gerek yok,\ngözlem yapmamız gerek.")
                .font(AppFont.body(15))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 32)
                .lineSpacing(15 * 0.45)
            Spacer()

            HStack(spacing: 18) {
                statItem("9 soru")
                statItem("~2 dk")
                statItem("atlanamaz")
            }
            .padding(.bottom, 18)

            PrimaryButton("başla", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(AppAnimation.spinSlow) {
                rotation = 360
            }
        }
    }

    private var orbital: some View {
        Image("calibration-orbital")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 280, height: 280)
            .rotationEffect(.degrees(rotation * 0.05)) // hafif drift
    }

    private func statItem(_ label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AppColor.lime)
                .frame(width: 6, height: 6)
            Text(label)
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
        }
    }
}

#Preview {
    CalibrationIntroView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
