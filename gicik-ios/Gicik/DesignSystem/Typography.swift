import SwiftUI

// gıcık — typography
// Display: Space Grotesk (Y2K, başlık + display momenti)
// Body: SF Pro (sistem)
// Mono: JetBrains Mono (label, etiket, technical)

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("SpaceGrotesk-\(weight.spaceGrotesk)", size: size)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

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
