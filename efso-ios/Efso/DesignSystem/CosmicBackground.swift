import SwiftUI

/// Refined-y2k arka plan — inkstone bg + üstte sessiz chrome lilac wash.
/// Önceki sürümün pink/purple çift bloom'u emekli; tek mor radial yeter.
struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppColor.bg0
                .ignoresSafeArea()

            // Üstte chrome lilac wash — sessiz, dozajlı
            RadialGradient(
                colors: [AppColor.accent.opacity(0.18), .clear],
                center: UnitPoint(x: 0.5, y: -0.05),
                startRadius: 0,
                endRadius: 420
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
