import SwiftUI

/// 56pt yüksekliği. Lowercase. 3 stil:
/// - `.solid`: beyaz fill, dark text (default)
/// - `.holoBorder`: dark fill + 1.5pt holographic border
/// - `.holoFill`: holographic gradient fill + dramatic glow (Y2K hero CTA)
struct PrimaryButton: View {
    enum Style {
        case solid
        case holoBorder
        case holoFill
    }

    let title: String
    let style: Style
    let action: () -> Void
    var isEnabled: Bool

    init(_ title: String, style: Style = .solid, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                background
                Text(displayTitle)
                    .font(textFont)
                    .tracking(textTracking)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .modifier(HoloFillGlow(active: style == .holoFill))
            .opacity(isEnabled ? 1.0 : 0.4)
        }
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: title)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .solid:
            AppColor.ink
        case .holoBorder:
            ZStack {
                AppColor.bg1
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .strokeBorder(AppColor.holographic, lineWidth: 1.5)
            }
        case .holoFill:
            AppColor.holographic
        }
    }

    private var displayTitle: String {
        style == .holoFill ? title.trUpper : title.trLower
    }

    private var textFont: Font {
        style == .holoFill ? AppFont.display(17, weight: .bold) : AppFont.body(17, weight: .semibold)
    }

    private var textTracking: CGFloat {
        style == .holoFill ? 0.04 * 17 : -0.01 * 17
    }

    private var textColor: Color {
        switch style {
        case .solid, .holoFill: return AppColor.bg0
        case .holoBorder: return AppColor.ink
        }
    }
}

private struct HoloFillGlow: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: AppColor.pink.opacity(0.45), radius: 28)
                .shadow(color: AppColor.purple.opacity(0.35), radius: 56)
        } else {
            content
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton("başla") {}
        PrimaryButton("kalibre et", style: .holoBorder) {}
        PrimaryButton("ücretsiz başlat", style: .holoFill) {}
        PrimaryButton("disabled", isEnabled: false) {}
    }
    .padding(24)
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
