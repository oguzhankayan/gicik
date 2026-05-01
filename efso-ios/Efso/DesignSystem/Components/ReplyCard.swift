import SwiftUI

/// Output sesi — kullanıcının atacağı mesaj.
/// 3 cevap önerisinden biri. Mono uppercase tone-angle label + body + copy + thumbs.
struct ReplyCard: View {
    let toneAngle: String   // "doğrudan engage" | "yön çevirme" | "ileri taşıma"
    let text: String
    let isCopied: Bool
    let onCopy: () -> Void
    let onThumbsUp: () -> Void
    let onThumbsDown: () -> Void

    init(
        toneAngle: String,
        text: String,
        isCopied: Bool = false,
        onCopy: @escaping () -> Void,
        onThumbsUp: @escaping () -> Void = {},
        onThumbsDown: @escaping () -> Void = {}
    ) {
        self.toneAngle = toneAngle
        self.text = text
        self.isCopied = isCopied
        self.onCopy = onCopy
        self.onThumbsUp = onThumbsUp
        self.onThumbsDown = onThumbsDown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(toneAngle.trUpper)
                .font(AppFont.mono(11))
                .tracking(0.08 * 11)
                .foregroundColor(AppColor.text40)
                .padding(.bottom, 10)

            Text(text)
                .font(AppFont.body(16))
                .foregroundColor(.white)
                .lineSpacing(16 * 0.45)
                .padding(.bottom, 14)

            HStack {
                copyButton
                Spacer()
                feedbackButtons
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.bg1.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }

    private var copyButton: some View {
        Button(action: onCopy) {
            HStack(spacing: 6) {
                if isCopied {
                    Text("kopyalandı")
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "doc.on.doc")
                    Text("kopyala")
                }
            }
            .font(AppFont.body(13, weight: .medium))
            .foregroundColor(isCopied ? AppColor.lime : .white.opacity(0.85))
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(isCopied ? AppColor.lime.opacity(0.08) : .clear)
                    .overlay(
                        Capsule().strokeBorder(
                            isCopied ? AppColor.lime.opacity(0.6) : AppColor.text10,
                            lineWidth: 1
                        )
                    )
            )
        }
        .accessibilityLabel(isCopied ? "kopyalandı" : "kopyala")
        .sensoryFeedback(.success, trigger: isCopied)
    }

    private var feedbackButtons: some View {
        HStack(spacing: 14) {
            Button(action: onThumbsUp) {
                Image(systemName: "hand.thumbsup")
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.text40)
            }
            .accessibilityLabel("beğen")
            Button(action: onThumbsDown) {
                Image(systemName: "hand.thumbsdown")
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.text40)
            }
            .accessibilityLabel("beğenme")
        }
    }
}
