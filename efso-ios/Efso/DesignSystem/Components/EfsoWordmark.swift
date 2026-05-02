import SwiftUI

/// Refined-y2k wordmark — lowercase italic editorial serif.
/// Eski Y2K logo (holographic dot in `o`) emekli — yerine: italic Fraunces-style
/// serif + opsiyonel mor nokta. Sadece bir kelime, büyük etki.
struct EfsoWordmark: View {
    let size: CGFloat
    let color: Color
    var withDot: Bool

    init(size: CGFloat = 28, color: Color = AppColor.ink, withDot: Bool = false) {
        self.size = size
        self.color = color
        self.withDot = withDot
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text("efso")
                .font(AppFont.displayItalic(size, weight: .medium))
                .tracking(-size * 0.04)
                .foregroundColor(color)
            if withDot {
                Text(".")
                    .font(AppFont.displayItalic(size, weight: .medium))
                    .foregroundColor(AppColor.purpleInk)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("efso")
    }
}
