import SwiftUI

/// Calibration intro — orbital ring animation + "9 soru. 2 dakika" + başla.
/// design-source/parts/onboarding.jsx → CalibrationIntro
struct CalibrationIntroView: View {
    let onContinue: () -> Void
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 1, total: 8)
            Spacer()
            orbital
            Text("gıcık'ı kalibre et")
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
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0xFF0080, alpha: 0.35), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 30)

            ForEach(0..<4) { i in
                let size = [260, 200, 140, 90][i]
                Circle()
                    .strokeBorder(AppColor.holographic, lineWidth: 1)
                    .frame(width: CGFloat(size), height: CGFloat(size))
                    .opacity(0.7 - Double(i) * 0.1)
                    .rotationEffect(.degrees(i % 2 == 0 ? rotation : -rotation))
            }

            // Center pulsing dot
            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .shadow(color: Color(hex: 0xFF0080), radius: 20)
                .shadow(color: Color(hex: 0x8000FF), radius: 40)
        }
        .frame(width: 280, height: 280)
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
