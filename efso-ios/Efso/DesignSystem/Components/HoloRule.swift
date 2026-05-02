import SwiftUI

/// 1pt yatay holographic çizgi — sparing kullanım.
/// Home'da observation altı, kart ayraçları için.
struct HoloRule: View {
    var height: CGFloat = 1
    var opacity: Double = 0.7

    var body: some View {
        Rectangle()
            .fill(AppColor.holographic)
            .frame(height: height)
            .opacity(opacity)
            .accessibilityHidden(true)
    }
}

/// 1.5pt holographic gradient stroke — bg1 üzerine.
/// Premium kart kenarı (paywall trial card, profile archetype card).
struct HoloBorder<Content: View>: View {
    var radius: CGFloat = 16
    var lineWidth: CGFloat = 1.2
    var fill: Color = AppColor.bg1
    let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(fill)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(AppColor.holographic, lineWidth: lineWidth)
            content()
                .clipShape(RoundedRectangle(cornerRadius: radius - lineWidth, style: .continuous))
                .padding(lineWidth)
        }
    }
}
