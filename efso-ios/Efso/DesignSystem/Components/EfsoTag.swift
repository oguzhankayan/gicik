import SwiftUI

/// Geist Mono uppercase label — küçük dot opsiyonel (lime pop).
/// Splash, mode header, "bugünün gözlemi" gibi yerlerde kullanılır.
struct EfsoTag: View {
    let text: String
    var color: Color
    var dot: Bool
    var dotColor: Color

    init(_ text: String, color: Color = AppColor.text40, dot: Bool = false, dotColor: Color = AppColor.pop) {
        self.text = text
        self.color = color
        self.dot = dot
        self.dotColor = dotColor
    }

    var body: some View {
        HStack(spacing: 6) {
            if dot {
                Circle()
                    .fill(dotColor)
                    .frame(width: 5, height: 5)
                    .shadow(color: dotColor.opacity(0.7), radius: 4)
            }
            Text(text.trUpper)
                .font(AppFont.mono(10, weight: .medium))
                .tracking(0.14 * 10)
                .foregroundColor(color)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
