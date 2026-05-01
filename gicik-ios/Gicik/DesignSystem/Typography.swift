import SwiftUI

// efso — typography
// Display: Space Grotesk (variable font, weight axis)
// Body: SF Pro (sistem)
// Mono: JetBrains Mono (Regular + Medium static weights)

enum AppFont {
    /// Display — Space Grotesk variable font. iOS 16+ `.weight()` modifier
    /// variable font weight axis'ini otomatik aktive eder.
    /// PostScript name "SpaceGrotesk-Light" base, weight axis ile değişir.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("SpaceGrotesk-Light", size: size).weight(weight)
    }

    /// Body — SF Pro
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Mono — JetBrains Mono. Dynamic Type'a duyarlı (relativeTo: .body).
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        let face = weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular"
        return .custom(face, size: size, relativeTo: .body)
    }
}
