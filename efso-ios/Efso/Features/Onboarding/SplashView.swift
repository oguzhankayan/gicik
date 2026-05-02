import SwiftUI

/// Refined-y2k splash — iki konsantrik chrome halka + italic wordmark.
/// Auto-advance ~2.6s, manuel CTA yok.
struct SplashView: View {
    let onContinue: () -> Void

    @State private var ringsIn = false
    @State private var logoIn = false
    @State private var taglineIn = false
    @State private var hasAdvanced = false

    var body: some View {
        ZStack {
            // chrome halka 1 (içte)
            HoloRing(diameter: 220, opacity: 0.85)
                .opacity(ringsIn ? 1 : 0)
                .scaleEffect(ringsIn ? 1 : 0.7)

            // chrome halka 2 (dışta, daha sönük)
            HoloRing(diameter: 320, opacity: 0.40)
                .opacity(ringsIn ? 1 : 0)
                .scaleEffect(ringsIn ? 1 : 0.7)

            VStack(spacing: 28) {
                EfsoWordmark(size: 84)
                    .opacity(logoIn ? 1 : 0)
                    .scaleEffect(logoIn ? 1 : 0.92)
                    .blur(radius: logoIn ? 0 : 10)
            }

            VStack {
                Spacer()
                Text("ne diyeceğini değil,\nne dediğini gör.")
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text60)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(taglineIn ? 1 : 0)
                    .padding(.bottom, 12)

                EfsoTag("v 2.0 · refined", color: AppColor.text40)
                    .opacity(taglineIn ? 1 : 0)
                    .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await runSequence() }
    }

    private func runSequence() async {
        withAnimation(.easeOut(duration: 0.85)) { ringsIn = true }
        try? await Task.sleep(for: .milliseconds(220))
        guard !Task.isCancelled else { return }
        withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) { logoIn = true }
        try? await Task.sleep(for: .milliseconds(420))
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.5)) { taglineIn = true }
        try? await Task.sleep(for: .milliseconds(1500))
        guard !Task.isCancelled, !hasAdvanced else { return }
        hasAdvanced = true
        onContinue()
    }
}

/// 1pt chrome halka — radial mask ile sadece kenar.
private struct HoloRing: View {
    let diameter: CGFloat
    var opacity: Double = 1

    var body: some View {
        Circle()
            .stroke(AppColor.holographic, lineWidth: 1)
            .frame(width: diameter, height: diameter)
            .opacity(opacity)
            .accessibilityHidden(true)
    }
}

#Preview {
    SplashView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
