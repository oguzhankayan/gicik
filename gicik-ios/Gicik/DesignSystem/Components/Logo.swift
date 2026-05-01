import SwiftUI

/// Y2K "efso" logo. `o` harfi içinde holographic dot
/// (önceden "ı" üzerindeydi; isim değişti).
/// Kullanım: `Logo(size: 88)` — splash screen'de
struct Logo: View {
    let size: CGFloat

    init(size: CGFloat = 64) { self.size = size }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("efs")
            ZStack {
                Text("o")
                Circle()
                    .fill(AppColor.holographic)
                    .frame(width: size * 0.16, height: size * 0.16)
                    .shadow(color: AppColor.pink.opacity(0.7), radius: 6)
                    .shadow(color: AppColor.purple.opacity(0.5), radius: 12)
            }
        }
        .font(AppFont.display(size, weight: .bold))
        .tracking(-size * 0.04)
        .foregroundColor(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("efso")
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
