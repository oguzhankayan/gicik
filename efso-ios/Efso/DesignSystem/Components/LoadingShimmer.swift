import SwiftUI

/// Skeleton shimmer placeholder. Tokens.css `@keyframes shimmer` SwiftUI versiyonu.
/// Yuvarlak köşeli alanlarda kullanırken `cornerRadius` parametresi geçilmeli;
/// shimmer overlay aynı şekle clip edilir, aksi halde kareden taşar.
///
/// `delay` parametresi staggered shimmer için: 3 kart yan yana animate ederken
/// her birini ~150ms kaydırarak "tek duvar" izlenimini kırıyoruz (kritik notu).
struct ShimmerModifier: ViewModifier {
    let cornerRadius: CGFloat
    let delay: Double
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        AppColor.bg1,
                        Color.white.opacity(0.06),
                        AppColor.bg1,
                    ],
                    startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                    endPoint: UnitPoint(x: phase + 0.3, y: 0.5)
                )
                .blendMode(.plusLighter)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(AppAnimation.shimmer) {
                        phase = 2
                    }
                }
            }
    }
}

extension View {
    func shimmer(cornerRadius: CGFloat = AppRadius.card, delay: Double = 0) -> some View {
        modifier(ShimmerModifier(cornerRadius: cornerRadius, delay: delay))
    }
}

/// Reply card placeholder while LLM is streaming.
/// `index` numbered label ("01 —", "02 —", "03 —") + width varyasyonu için kullanılır;
/// gerçek ReplyCard'la aynı geometry, hizalama bozulmasın diye.
struct ReplyCardSkeleton: View {
    let index: Int

    init(index: Int = 0) {
        self.index = index
    }

    /// Her satır için biraz farklı genişlik — 3 kart yan yana "tek duvar" gibi
    /// görünmesin diye. Pattern: ilk satır geniş, son satır daha kısa.
    private var rowWidths: [CGFloat?] {
        switch index {
        case 0: return [nil, nil, 180]
        case 1: return [nil, 220, nil]
        default: return [nil, 200, 140]
        }
    }

    private var labelText: String {
        String(format: "%02d —", index + 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(labelText)
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text05)
                .padding(.bottom, 14)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    if let w = rowWidths[row] {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColor.bg1)
                            .frame(width: w, height: 16)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColor.bg1)
                            .frame(height: 16)
                    }
                }
            }
            .padding(.bottom, 14)
            Capsule().fill(AppColor.bg1).frame(width: 100, height: 32)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .glassCard()
        .shimmer(delay: Double(index) * 0.15)
    }
}
