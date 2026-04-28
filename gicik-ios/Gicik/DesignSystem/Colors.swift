import SwiftUI

// gıcık — color tokens
// Kaynak: design-source/project/tokens.css

enum AppColor {
    // Surfaces
    static let bg0 = Color(hex: 0x0A0612)              // deep cosmic black
    static let bg1 = Color(hex: 0x1A0F2E)              // deep purple
    static let bg2 = Color(hex: 0x2D1B4E)              // lifted purple, cards
    static let bgGlass = Color(hex: 0x2D1B4E, alpha: 0.55)
    static let bgGlass2 = Color(hex: 0x1A0F2E, alpha: 0.70)

    // Text (alpha cascade)
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
}
