import SwiftUI

/// Refined-y2k brand mark — speech bubble (asymmetric, tail tucked down-left)
/// + holographic chrome stroke + italic "e" inside.
/// Aynı tasarım app icon master'ında (Resources/.../AppIcon-1024.png) yaşar;
/// bu SwiftUI versiyonu in-app yerlerde (notification preview, sign-in mark)
/// aynı görseli vector çözünürlüksüz çizer.
struct EfsoBubbleMark: View {
    var size: CGFloat = 48
    /// `true` → koyu iris/inkstone diagonal arka plan ile (icon görünümü).
    /// `false` → şeffaf arka plan, sadece bubble + e (inline glyph).
    var withBackground: Bool = true

    var body: some View {
        Canvas { context, canvasSize in
            let s = min(canvasSize.width, canvasSize.height)

            if withBackground {
                let bgRect = CGRect(origin: .zero, size: canvasSize)
                let bgPath = Path(roundedRect: bgRect, cornerRadius: s * 0.225)
                context.fill(
                    bgPath,
                    with: .linearGradient(
                        Gradient(stops: [
                            .init(color: Color(red: 0x1C/255, green: 0x15/255, blue: 0x30/255), location: 0),
                            .init(color: Color(red: 0x0E/255, green: 0x0A/255, blue: 0x14/255), location: 0.70),
                        ]),
                        startPoint: CGPoint(x: s * 0.85, y: s * 0.05),
                        endPoint: CGPoint(x: s * 0.15, y: s * 0.95)
                    )
                )
            }

            // Bubble path — viewBox 100×100 scaled to 74% of canvas, centered.
            let drawSize = withBackground ? s * 0.74 : s
            let inset = (s - drawSize) / 2
            let scale = drawSize / 100

            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: inset + x * scale, y: inset + y * scale)
            }

            var bubble = Path()
            bubble.move(to: p(50, 8))
            bubble.addCurve(to: p(90, 45), control1: p(73, 8), control2: p(90, 22))
            bubble.addCurve(to: p(56, 80), control1: p(90, 64), control2: p(76, 78))
            bubble.addLine(to: p(38, 92))
            bubble.addLine(to: p(40, 78))
            bubble.addCurve(to: p(10, 45), control1: p(22, 74), control2: p(10, 60))
            bubble.addCurve(to: p(50, 8), control1: p(10, 22), control2: p(27, 8))
            bubble.closeSubpath()

            // Fill bubble
            context.fill(bubble, with: .color(Color(red: 0x15/255, green: 0x10/255, blue: 0x1F/255)))

            // Holographic chrome stroke
            let strokeWidth = scale * 1.6
            context.stroke(
                bubble,
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(red: 0xC9/255, green: 0xA8/255, blue: 0xFF/255), location: 0),
                        .init(color: Color(red: 0xFF/255, green: 0xC8/255, blue: 0xE1/255), location: 0.35),
                        .init(color: Color(red: 0xE8/255, green: 0xFF/255, blue: 0x6B/255), location: 0.60),
                        .init(color: Color(red: 0x9D/255, green: 0xD9/255, blue: 0xFF/255), location: 1.0),
                    ]),
                    startPoint: CGPoint(x: inset, y: inset),
                    endPoint: CGPoint(x: inset + drawSize, y: inset + drawSize)
                ),
                lineWidth: strokeWidth
            )

            // Italic "e" centered at viewBox (50, 56)
            let eFontSize = 38 * scale
            let eText = Text("e")
                .font(.system(size: eFontSize, weight: .medium, design: .serif).italic())
                .foregroundColor(Color(red: 0xF4/255, green: 0xEF/255, blue: 0xE6/255))
            let resolved = context.resolve(eText)
            let textSize = resolved.measure(in: CGSize(width: s, height: s))
            let center = p(50, 56)
            context.draw(
                resolved,
                at: CGPoint(x: center.x, y: center.y - textSize.height * 0.05),
                anchor: .center
            )
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("efso")
    }
}

#Preview {
    VStack(spacing: 20) {
        EfsoBubbleMark(size: 120)
        EfsoBubbleMark(size: 56)
        EfsoBubbleMark(size: 38, withBackground: false)
    }
    .padding(40)
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
