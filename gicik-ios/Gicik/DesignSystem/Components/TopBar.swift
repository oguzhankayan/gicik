import SwiftUI

/// Standard onboarding top bar — back chevron + progress dots + close (optional).
struct TopBar: View {
    let active: Int
    let total: Int
    var showBack: Bool
    var showClose: Bool
    var onBack: (() -> Void)?
    var onClose: (() -> Void)?

    init(
        active: Int,
        total: Int,
        showBack: Bool = true,
        showClose: Bool = false,
        onBack: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.active = active
        self.total = total
        self.showBack = showBack
        self.showClose = showClose
        self.onBack = onBack
        self.onClose = onClose
    }

    var body: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityLabel("geri")
            .opacity(showBack ? 1 : 0)
            .disabled(!showBack)
            .frame(width: 28, alignment: .leading)

            Spacer()
            if total > 0 {
                ProgressDots(total: total, active: active)
            }
            Spacer()

            Button(action: { onClose?() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.text40)
            }
            .accessibilityLabel("kapat")
            .opacity(showClose ? 1 : 0)
            .disabled(!showClose)
            .frame(width: 28, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }
}
