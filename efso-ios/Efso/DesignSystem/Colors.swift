import SwiftUI

// efso — color tokens (refined y2k)
// Kaynak: design-source/project/efso-redesign.html (SystemBoard).
// DNA korundu (deep purple ink, chrome, holographic stroke); olgunlaştı:
// tek chrome lilac accent + dozajlı highlighter pop, pastel holo gradient.

enum AppColor {
    // Surfaces — inkstone → plum → iris
    static let bg0 = Color(hex: 0x0E0A14)              // inkstone (en dip)
    static let bg1 = Color(hex: 0x15101F)              // plum ink
    static let bg2 = Color(hex: 0x1C1530)              // iris depth, kart yüzeyi
    static let bgGlass = Color(hex: 0x1C1530, alpha: 0.55)
    static let bgGlass2 = Color(hex: 0x15101F, alpha: 0.70)

    // Text (alpha cascade, paper-warm üzerinden)
    static let ink = Color(hex: 0xF4EFE6)              // paper warm — primary
    static let text100 = Color(hex: 0xF4EFE6)
    static let text60 = Color(hex: 0xF4EFE6, alpha: 0.6)
    static let text40 = Color(hex: 0xF4EFE6, alpha: 0.4)
    static let text30 = Color(hex: 0xF4EFE6, alpha: 0.3)
    static let text20 = Color(hex: 0xF4EFE6, alpha: 0.2)
    static let text10 = Color(hex: 0xF4EFE6, alpha: 0.1)
    static let text08 = Color(hex: 0xF4EFE6, alpha: 0.08)
    static let text05 = Color(hex: 0xF4EFE6, alpha: 0.05)

    // Accents
    /// Tek mor accent — gövdedeki vurguların hepsi buradan (CTA çevresi, link, focus).
    static let accent = Color(hex: 0xC9A8FF)           // chrome lilac
    /// Highlighter — sadece kritik durum bildirgesi (kalan kota, "yeni" rozeti).
    static let pop = Color(hex: 0xE8FF6B)              // highlighter lime

    // Geriye uyumlu legacy isimler — refined paletin içinden remap edildi.
    // Yeni kodda `accent` / `pop` / `ink` tercih edin.
    static let purple = Color(hex: 0xC9A8FF)           // → accent (chrome lilac)
    static let purpleInk = Color(hex: 0x7B5BD9)        // wordmark nokta accent'i
    static let pink = Color(hex: 0xFFC8E1)             // holo stop, body'de doğrudan kullanma
    static let lime = Color(hex: 0xE8FF6B)             // → pop
    static let blue = Color(hex: 0x9DD9FF)             // holo stop
    static let cyan = Color(hex: 0x9DD9FF)             // holo stop (refined)
    static let green = Color(hex: 0xE8FF6B)            // → pop
    static let success = Color(hex: 0x7AE6A0)
    static let danger = Color(hex: 0xFF7A8A)
    static let warning = Color(hex: 0xFFB36B)

    // Glow seti — chrome lilac etrafında, sessiz
    static let purpleGlow = Color(hex: 0xC9A8FF, alpha: 0.30)
    static let pinkGlow = Color(hex: 0xFFC8E1, alpha: 0.25)
    static let pinkGlowSoft = Color(hex: 0xFFC8E1, alpha: 0.18)

    // Holographic — refined: pastel chrome ribbon, 110° eğim.
    // Kullanım: 1px stroke (CTA çevresi, premium kart kenarı, splash halka).
    // Gövdede zemin olarak kullanma — tek mor accent yeter.
    static let holographic = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xC9A8FF), location: 0.00),
            .init(color: Color(hex: 0xFFC8E1), location: 0.28),
            .init(color: Color(hex: 0xE8FF6B), location: 0.52),
            .init(color: Color(hex: 0x9DD9FF), location: 0.78),
            .init(color: Color(hex: 0xC9A8FF), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.05, y: 0.20),
        endPoint: UnitPoint(x: 0.95, y: 0.80)
    )

    static let holographicSoft = LinearGradient(
        colors: [Color(hex: 0xC9A8FF), Color(hex: 0xFFC8E1), Color(hex: 0x9DD9FF)],
        startPoint: UnitPoint(x: 0.05, y: 0.20),
        endPoint: UnitPoint(x: 0.95, y: 0.80)
    )
}
