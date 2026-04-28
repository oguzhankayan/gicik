import SwiftUI

/// Demo upload — pre-loaded sample profile + 4 hardcoded reply (typewriter).
/// design-source/parts/onboard2.jsx → DemoUpload
struct DemoUploadView: View {
    let onContinue: () -> Void
    @State private var revealedCount: Int = 0

    private let demoReplies: [(label: String, text: String)] = [
        ("01 — SPESİFİK", "huysuz kediyle huysuz insan arasında fark var mı?"),
        ("02 — SORU", "üç huysuzluğun ortak özelliği ne?"),
        ("03 — İRONİ", "kahve, kitap, kedi listene 'huy' eklersen tehlikeli oluyor."),
        ("04 — DİREKT", "mira, profilin bana fazla iyi görünüyor. neredesin?"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 5, total: 8, showBack: false)

            VStack(alignment: .leading, spacing: 0) {
                Text("DEMO / DENEME")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)

                Text("böyle bir şey")
                    .font(AppFont.display(26, weight: .bold))
                    .tracking(-0.02 * 26)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Faux screenshot
            fauxScreenshot
                .padding(.top, 18)

            ObservationCard(text: "kahve klişesi var ama 'huysuz' iyi detay. oradan tut.")
                .padding(.horizontal, 24)
                .padding(.top, 18)

            // Reply cards (animated reveal)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Array(demoReplies.enumerated()), id: \.offset) { idx, item in
                        if idx < revealedCount {
                            ReplyCard(
                                toneAngle: item.label,
                                text: item.text,
                                onCopy: {}
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 110)
            }

            Spacer(minLength: 0)

            SecondaryButton(title: "ben de denemek istiyorum →", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            revealedCount = 0
            for i in 1...demoReplies.count {
                try? await Task.sleep(nanoseconds: 700_000_000)
                withAnimation(AppAnimation.standard) {
                    revealedCount = i
                }
            }
        }
    }

    private var fauxScreenshot: some View {
        ZStack(alignment: .topTrailing) {
            // Diagonal striped bg
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x2D1B4E), Color(hex: 0x1A0F2E)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    DiagonalStripes(spacing: 16, lineWidth: 1, opacity: 0.04)
                )
                .frame(width: 240, height: 180)

            VStack(alignment: .leading) {
                Spacer()
                Text("Mira, 27")
                    .font(AppFont.body(18, weight: .semibold))
                    .foregroundColor(.white)
                Text("kahve, kitap, kedi.\nüçü de huysuz.")
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text60)
                    .padding(.top, 2)
            }
            .padding(12)
            .frame(width: 240, height: 180, alignment: .bottomLeading)

            // DEMO badge
            Text("DEMO")
                .font(AppFont.mono(10))
                .foregroundColor(AppColor.lime)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .overlay(
                    Capsule().strokeBorder(AppColor.lime.opacity(0.4), lineWidth: 1)
                )
                .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppColor.holographic, lineWidth: 1)
                .opacity(0.6)
        )
    }
}

private struct DiagonalStripes: View {
    let spacing: CGFloat
    let lineWidth: CGFloat
    let opacity: Double

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                var x: CGFloat = -h
                while x < w + h {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + h, y: h))
                    x += spacing
                }
            }
            .stroke(Color.white.opacity(opacity), lineWidth: lineWidth)
        }
    }
}

#Preview {
    DemoUploadView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
