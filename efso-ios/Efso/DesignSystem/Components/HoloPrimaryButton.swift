import SwiftUI

/// Refined-y2k hero CTA — 1.5pt holographic gradient stroke, ink fill, dark text.
/// Hero kullanım: "üç cevap üret", "ücretsiz başlat", "açılış üret".
/// Sıradan ekran-içi devam butonları için PrimaryButton kullan.
struct HoloPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColor.holographic)
                RoundedRectangle(cornerRadius: 16.5, style: .continuous)
                    .fill(AppColor.ink)
                    .padding(1.5)
                Text(title.trLower)
                    .font(AppFont.body(16, weight: .semibold))
                    .tracking(-0.01 * 16)
                    .foregroundColor(AppColor.bg0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: title)
    }
}
