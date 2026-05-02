import SwiftUI

/// Refined-y2k logo — lowercase italic editorial serif. Y2K holographic dot
/// pattern emekli; yerine sadece typeface'in karakteri konuşur.
/// Bu wrapper geriye uyumluluk için kalıyor; yeni kodda `EfsoWordmark` kullan.
struct Logo: View {
    let size: CGFloat

    init(size: CGFloat = 64) { self.size = size }

    var body: some View {
        EfsoWordmark(size: size, color: AppColor.ink, withDot: false)
    }
}

#Preview {
    VStack(spacing: 24) {
        Logo(size: 88)
        Logo(size: 64)
        Logo(size: 32)
    }
    .padding(40)
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
