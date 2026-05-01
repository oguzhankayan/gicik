import SwiftUI

/// Tokens.css `cosmic-bg` SwiftUI versiyonu.
/// Deep cosmic black + üstte purple bloom + sağ-altta pink bloom.
struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppColor.bg0
                .ignoresSafeArea()

            // Top purple bloom (radial)
            RadialGradient(
                colors: [Color(hex: 0x8000FF, alpha: 0.18), .clear],
                center: UnitPoint(x: 0.5, y: -0.10),
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()

            // Bottom-right pink bloom
            RadialGradient(
                colors: [Color(hex: 0xFF0080, alpha: 0.08), .clear],
                center: UnitPoint(x: 1.0, y: 1.0),
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }
}

extension View {
    /// Tüm full-screen view'larda arka plan olarak kullan.
    /// Örnek: `MyView().background(CosmicBackground())`
    func cosmicBackground() -> some View {
        background(CosmicBackground())
    }
}

#Preview {
    CosmicBackground()
        .preferredColorScheme(.dark)
}
