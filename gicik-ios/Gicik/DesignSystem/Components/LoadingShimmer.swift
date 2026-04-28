import SwiftUI

/// Skeleton shimmer placeholder. Tokens.css `@keyframes shimmer` SwiftUI versiyonu.
/// Yuvarlak köşeli alanlarda kullanırken `cornerRadius` parametresi geçilmeli;
/// shimmer overlay aynı şekle clip edilir, aksi halde kareden taşar.
struct ShimmerModifier: ViewModifier {
    let cornerRadius: CGFloat
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
                withAnimation(AppAnimation.shimmer) {
                    phase = 2
                }
            }
    }
}

extension View {
    func shimmer(cornerRadius: CGFloat = AppRadius.card) -> some View {
        modifier(ShimmerModifier(cornerRadius: cornerRadius))
    }
}

/// Reply card placeholder while LLM is streaming
struct ReplyCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule().fill(AppColor.bg1).frame(width: 80, height: 11).padding(.bottom, 14)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(AppColor.bg1).frame(height: 16)
                RoundedRectangle(cornerRadius: 4).fill(AppColor.bg1).frame(height: 16)
                RoundedRectangle(cornerRadius: 4).fill(AppColor.bg1).frame(width: 200, height: 16)
            }
            .padding(.bottom, 14)
            Capsule().fill(AppColor.bg1).frame(width: 100, height: 32)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .glassCard()
        .shimmer()
    }
}
