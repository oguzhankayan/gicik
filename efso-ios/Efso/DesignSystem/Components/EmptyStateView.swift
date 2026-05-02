import SwiftUI

/// Generic empty/error state — icon + headline + subline + opsiyonel CTA.
/// Phase 5: tüm boş/hatalı sahnelerde kullan.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let cta: CTA?
    var tone: Tone = .neutral

    struct CTA {
        let label: String
        let action: () -> Void
    }

    enum Tone {
        case neutral, warning, danger
        var color: Color {
            switch self {
            case .neutral: AppColor.text40
            case .warning: AppColor.warning
            case .danger: AppColor.danger
            }
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(tone.color)
                .accessibilityHidden(true)
            Text(title)
                .font(AppFont.display(20, weight: .bold))
                .tracking(-0.02 * 20)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let cta {
                PrimaryButton(cta.label, action: cta.action)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }
}

extension EmptyStateView {
    static func network(retry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "bağlantı yok.",
            subtitle: "internetin döndüğünde tekrar dene.",
            cta: .init(label: "tekrar dene", action: retry),
            tone: .warning
        )
    }

    static func rateLimited(reset: String) -> EmptyStateView {
        EmptyStateView(
            icon: "hourglass",
            title: "biraz hızlı geldin.",
            subtitle: "\(reset) sonra tekrar dene.",
            cta: nil,
            tone: .warning
        )
    }

    static func unsupportedImage(retry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "photo.badge.exclamationmark",
            title: "ekran görüntüsünü okuyamadım.",
            subtitle: "konuşmanın tek karede göründüğünden emin ol.",
            cta: .init(label: "yeniden seç", action: retry),
            tone: .warning
        )
    }
}
