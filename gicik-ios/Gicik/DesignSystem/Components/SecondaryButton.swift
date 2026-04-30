import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.trLower)
                .font(AppFont.body(17, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                        .stroke(AppColor.text20, lineWidth: 1)
                )
        }
        .sensoryFeedback(.impact(weight: .light), trigger: title)
    }
}
