import SwiftUI

/// Refined-y2k çıkış kartı — kullanıcının atacağı mesaj.
/// Primary varyant (en üst kart): bg2 + holographic 2pt highlight stripe + ink CTA.
/// Diğer kartlar: bg1 + nötr border + outline CTA.
struct ReplyCard: View {
    let toneAngle: String
    let text: String
    var isPrimary: Bool = false
    let isCopied: Bool
    let onCopy: () -> Void
    let onThumbsUp: () -> Void
    let onThumbsDown: () -> Void

    init(
        toneAngle: String,
        text: String,
        isPrimary: Bool = false,
        isCopied: Bool = false,
        onCopy: @escaping () -> Void,
        onThumbsUp: @escaping () -> Void = {},
        onThumbsDown: @escaping () -> Void = {}
    ) {
        self.toneAngle = toneAngle
        self.text = text
        self.isPrimary = isPrimary
        self.isCopied = isCopied
        self.onCopy = onCopy
        self.onThumbsUp = onThumbsUp
        self.onThumbsDown = onThumbsDown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("angle · \(toneAngle.trLower)")
                    .font(AppFont.mono(10, weight: .medium))
                    .tracking(0.16 * 10)
                    .foregroundColor(AppColor.accent)
                    .textCase(.uppercase)

                Spacer()

                feedbackButtons
            }
            .padding(.bottom, 10)

            Text(text)
                .font(AppFont.body(15.5))
                .foregroundColor(AppColor.ink)
                .lineSpacing(15.5 * 0.45)
                .tracking(-0.01 * 15.5)
                .padding(.bottom, 14)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                copyButton
                feedbackButtons
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isPrimary ? AppColor.bg2 : AppColor.bg1)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isPrimary ? AppColor.text20 : AppColor.text10, lineWidth: 1)
                if isPrimary {
                    Capsule()
                        .fill(AppColor.holographic)
                        .frame(width: 36, height: 2)
                        .offset(y: -1)
                }
            }
        )
    }

    private var copyButton: some View {
        Button(action: onCopy) {
            HStack(spacing: 6) {
                if isCopied {
                    Text("kopyalandı")
                    Image(systemName: "checkmark")
                } else {
                    Text("kopyala")
                }
            }
            .font(AppFont.body(13, weight: .medium))
            .foregroundColor(isPrimary ? AppColor.bg0 : AppColor.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isPrimary ? AppColor.ink : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(isPrimary ? Color.clear : AppColor.text20, lineWidth: 1)
            )
        }
        .accessibilityLabel(isCopied ? "kopyalandı" : "kopyala")
        .sensoryFeedback(.success, trigger: isCopied)
    }

    private var feedbackButtons: some View {
        HStack(spacing: 6) {
            Button(action: onThumbsUp) {
                Image(systemName: "heart")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 24, height: 24)
                    .background(Circle().strokeBorder(AppColor.text10, lineWidth: 1))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("beğen")
            Button(action: onThumbsDown) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 24, height: 24)
                    .background(Circle().strokeBorder(AppColor.text10, lineWidth: 1))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("beğenme")
        }
    }
}
