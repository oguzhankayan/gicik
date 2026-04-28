import SwiftUI

/// Y2K "gıcık" logo. `i` harfi üzerinde holographic dot.
/// Kullanım: `Logo(size: 88)` — splash screen'de
struct Logo: View {
    let size: CGFloat

    init(size: CGFloat = 64) { self.size = size }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("g")
            ZStack(alignment: .top) {
                Text("ı")
                Circle()
                    .fill(AppColor.holographic)
                    .frame(width: size * 0.14, height: size * 0.14)
                    .shadow(color: Color(hex: 0xFF0080, alpha: 0.7), radius: 6)
                    .shadow(color: Color(hex: 0x8000FF, alpha: 0.5), radius: 12)
                    .offset(y: size * 0.07)
            }
            Text("cık")
        }
        .font(AppFont.display(size, weight: .bold))
        .tracking(-size * 0.04)
        .foregroundColor(.white)
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
