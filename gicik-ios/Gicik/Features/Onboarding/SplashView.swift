import SwiftUI

/// Splash — cinematic spotlight reveal, auto-advance ~2.6s.
/// Rizz playbook: tek hareket, manuel CTA yok, hemen value carousel'a düş.
struct SplashView: View {
    let onContinue: () -> Void

    @State private var spotlightOpen = false
    @State private var logoIn = false
    @State private var taglineIn = false
    @State private var hasAdvanced = false

    var body: some View {
        ZStack {
            // Spotlight halo — radial light "açılır"
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.pink.opacity(0.55),
                            AppColor.purple.opacity(0.35),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: spotlightOpen ? 320 : 4
                    )
                )
                .frame(width: 640, height: 640)
                .blur(radius: 50)
                .opacity(spotlightOpen ? 1 : 0)
                .offset(y: -40)

            VStack(spacing: 24) {
                Logo(size: 88)
                    .opacity(logoIn ? 1 : 0)
                    .scaleEffect(logoIn ? 1 : 0.85)
                    .blur(radius: logoIn ? 0 : 12)

                Text("yazma. gıcık yazsın.")
                    .font(AppFont.body(15))
                    .foregroundColor(AppColor.text60)
                    .opacity(taglineIn ? 1 : 0)
                    .offset(y: taglineIn ? 0 : 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await runSequence()
        }
    }

    private func runSequence() async {
        withAnimation(.easeOut(duration: 0.85)) { spotlightOpen = true }
        try? await Task.sleep(for: .milliseconds(220))
        withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) { logoIn = true }
        try? await Task.sleep(for: .milliseconds(420))
        withAnimation(.easeOut(duration: 0.5)) { taglineIn = true }
        try? await Task.sleep(for: .milliseconds(1500))
        guard !hasAdvanced else { return }
        hasAdvanced = true
        onContinue()
    }
}

#Preview {
    SplashView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
