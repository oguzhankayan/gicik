// gıcık — design tokens (SwiftUI)
// Kaynak: design-source/project/tokens.css
// Phase 0.4'te `gicik-ios/Gicik/DesignSystem/` altına taşı.

import SwiftUI

// MARK: - Color

enum AppColor {
    // Surfaces
    static let bg0 = Color(hex: 0x0A0612)              // deep cosmic black
    static let bg1 = Color(hex: 0x1A0F2E)              // deep purple
    static let bg2 = Color(hex: 0x2D1B4E)              // lifted purple, cards
    static let bgGlass = Color(hex: 0x2D1B4E, alpha: 0.55)
    static let bgGlass2 = Color(hex: 0x1A0F2E, alpha: 0.70)

    // Text
    static let text100 = Color.white
    static let text60 = Color.white.opacity(0.6)
    static let text40 = Color.white.opacity(0.4)
    static let text30 = Color.white.opacity(0.3)
    static let text20 = Color.white.opacity(0.2)
    static let text10 = Color.white.opacity(0.1)
    static let text08 = Color.white.opacity(0.08)
    static let text05 = Color.white.opacity(0.05)

    // Accents
    static let pink = Color(hex: 0xFF0080)
    static let lime = Color(hex: 0xCCFF00)
    static let blue = Color(hex: 0x0080FF)
    static let danger = Color(hex: 0xFF3366)
    static let warning = Color(hex: 0xFFAA00)

    // Holographic gradient — pink → purple → cyan → lime
    static let holographic = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xFF0080), location: 0.00),
            .init(color: Color(hex: 0x8000FF), location: 0.33),
            .init(color: Color(hex: 0x00FFFF), location: 0.66),
            .init(color: Color(hex: 0x00FF80), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.10, y: 0.10),
        endPoint: UnitPoint(x: 0.90, y: 0.90)
    )

    static let holographicSoft = LinearGradient(
        colors: [Color(hex: 0xFF0080), Color(hex: 0x8000FF), Color(hex: 0x00FFFF)],
        startPoint: UnitPoint(x: 0.10, y: 0.10),
        endPoint: UnitPoint(x: 0.90, y: 0.90)
    )

    // Cosmic background — radial purple bloom on black
    static let cosmicBackground = Gradient(stops: [
        .init(color: Color(hex: 0x8000FF, alpha: 0.18), location: 0.00),
        .init(color: .clear, location: 0.55),
        .init(color: Color(hex: 0xFF0080, alpha: 0.08), location: 0.55),
        .init(color: .clear, location: 1.00),
    ])
}

// MARK: - Typography

enum AppFont {
    /// Display — Space Grotesk (Y2K, sadece başlık ve display momentlerinde)
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("SpaceGrotesk-\(weight.spaceGrotesk)", size: size)
    }

    /// Body — SF Pro (her yer)
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Mono — JetBrains Mono (label/etiket)
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .custom("JetBrainsMono-\(weight.jetBrainsMono)", size: size)
    }
}

private extension Font.Weight {
    var spaceGrotesk: String {
        switch self {
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "SemiBold"
        case .bold: return "Bold"
        default: return "Regular"
        }
    }

    var jetBrainsMono: String {
        switch self {
        case .medium: return "Medium"
        default: return "Regular"
        }
    }
}

// MARK: - Spacing

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radius

enum AppRadius {
    static let card: CGFloat = 20
    static let button: CGFloat = 16
    static let input: CGFloat = 12
    static let chip: CGFloat = 999  // pill
}

// MARK: - Shadow / Glow

enum AppShadow {
    static func holoGlow(intensity: CGFloat = 1.0) -> [ShadowSpec] {
        [
            ShadowSpec(color: Color(hex: 0xFF0080, alpha: 0.45 * intensity), radius: 28, x: 0, y: 0),
            ShadowSpec(color: Color(hex: 0x8000FF, alpha: 0.35 * intensity), radius: 56, x: 0, y: 0),
        ]
    }
}

struct ShadowSpec {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation

enum AppAnimation {
    /// Default spring — `.spring(response: 0.4, dampingFraction: 0.7)`
    static let standard = Animation.spring(response: 0.4, dampingFraction: 0.7)

    /// Ease-out-quart (custom)
    static let easeOutQuart = Animation.timingCurve(0.165, 0.84, 0.44, 1, duration: 0.4)

    /// Slow spin (orbital rings) — 20s linear infinite
    static let spinSlow = Animation.linear(duration: 20).repeatForever(autoreverses: false)

    /// Pulse glow — 2.6s ease-in-out infinite
    static let pulseGlow = Animation.easeInOut(duration: 2.6).repeatForever()

    /// Shimmer — 1.6s linear infinite
    static let shimmer = Animation.linear(duration: 1.6).repeatForever(autoreverses: false)
}

// MARK: - Color hex helper

extension Color {
    /// `Color(hex: 0xFF0080)` veya `Color(hex: 0xFF0080, alpha: 0.5)`
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Cosmic background view modifier

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            AppColor.bg0
                .ignoresSafeArea()
            // Top purple bloom
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
    func cosmicBackground() -> some View {
        ZStack {
            CosmicBackground()
            self
        }
    }
}
