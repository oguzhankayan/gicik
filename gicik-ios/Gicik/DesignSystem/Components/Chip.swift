import SwiftUI

/// Pill chip — onboarding selection, tone selector, vb.
/// Selected state'te holographic 1pt border + soft pink glow.
struct Chip: View {
    let label: String
    let isSelected: Bool
    var size: Size
    var emoji: String?
    let action: () -> Void

    enum Size { case regular, large }

    init(
        label: String,
        isSelected: Bool = false,
        size: Size = .regular,
        emoji: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isSelected = isSelected
        self.size = size
        self.emoji = emoji
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji {
                    Text(emoji).font(.system(size: 14))
                }
                Text(label.lowercased())
            }
            .font(AppFont.body(size == .large ? 15 : 14))
            .foregroundColor(isSelected ? .white : AppColor.text60)
            .padding(.horizontal, size == .large ? 20 : 16)
            .frame(height: size == .large ? 44 : 36)
            .background(
                ZStack {
                    Capsule()
                        .fill(isSelected ? AppColor.bgGlass : AppColor.bg1)
                    Capsule()
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(AppColor.holographic) : AnyShapeStyle(AppColor.text10),
                            lineWidth: 1
                        )
                }
            )
            .modifier(HoloChipGlow(active: isSelected))
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

private struct HoloChipGlow: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content.shadow(color: Color(hex: 0xFF0080, alpha: 0.30), radius: 10)
        } else {
            content
        }
    }
}
