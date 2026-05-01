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
                Text(label.trLower)
            }
            .font(AppFont.body(size == .large ? 15 : 14))
            .foregroundColor(isSelected ? .white : AppColor.text60)
            .padding(.horizontal, size == .large ? 20 : 16)
            // Görsel yükseklik 36pt (regular) / 44pt (large) ama HIG hit-target
            // 44pt minimum. Regular'da görsel kapsülü küçük tutuyoruz, hit
            // alanını contentShape ile 44pt'a genişletiyoruz.
            .frame(height: size == .large ? 44 : 36)
            .background(
                ZStack {
                    Capsule()
                        .fill(isSelected ? AppColor.bgGlass : AppColor.bg1)
                    Capsule()
                        .strokeBorder(
                            isSelected ? AppColor.pink : AppColor.text10,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
            )
            .contentShape(Rectangle().inset(by: -4))   // ~4pt padding her yönde
            .frame(minHeight: 44)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

