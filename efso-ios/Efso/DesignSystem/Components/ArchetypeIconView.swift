import SwiftUI

/// Custom-tasarlanmış arketip PNG'lerini chrome lilac glow ile gösterir.
/// Kullanım: reveal (~180), profile (~88), gallery (~56), switcher (~48).
struct ArchetypeIconView: View {
    let archetype: String      // "dryroaster" | "observer" | "softie" | "chaos" | "strategist" | "romantic"
    var size: CGFloat = 96
    var glow: Bool = true

    var body: some View {
        ZStack {
            if glow {
                Circle()
                    .fill(AppColor.accent.opacity(0.35))
                    .blur(radius: 14)
                    .padding(size * 0.08)
            }
            // Asset key zaten `arch-` prefixliyse double-prefix engelle.
            Image(archetype.hasPrefix("arch-") ? archetype : "arch-\(archetype)")
                .resizable()
                .scaledToFit()
                .shadow(color: AppColor.purpleInk.opacity(0.35), radius: 12, y: 6)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(archetype) arketipi")
    }
}
