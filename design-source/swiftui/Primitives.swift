// gıcık — primitive components (SwiftUI)
// Kaynak: design-source/project/parts/shared.jsx + tokens.css
// Phase 0.4'te `gicik-ios/Gicik/DesignSystem/Components/` altına böl ve taşı.

import SwiftUI

// MARK: - Logo

/// Y2K "gıcık" logo. `i` üzerinde holographic dot.
/// Kullanım: `Logo(size: 88)`
struct Logo: View {
    let size: CGFloat

    init(size: CGFloat = 64) { self.size = size }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("g")
            ZStack(alignment: .top) {
                Text("ı")
                Circle()
                    .fill(AppColor.holographic)
                    .frame(width: size * 0.14, height: size * 0.14)
                    .shadow(color: Color(hex: 0xFF0080, alpha: 0.7), radius: 6)
                    .shadow(color: Color(hex: 0x8000FF, alpha: 0.5), radius: 12)
                    .offset(y: size * 0.07)
            }
            Text("cık")
        }
        .font(AppFont.display(size, weight: .bold))
        .tracking(-size * 0.04)
        .foregroundColor(.white)
    }
}

// MARK: - PrimaryButton

/// 56pt yüksekliği, 17pt font, lowercase. 3 varyant: solid, holographic border, holographic fill.
struct PrimaryButton: View {
    enum Style {
        case solid          // beyaz fill, dark text
        case holoBorder     // dark fill + 1.5pt holographic border
        case holoFill       // holographic fill + dramatic glow (Y2K hero CTA)
    }

    let title: String
    let style: Style
    let action: () -> Void
    var isEnabled: Bool = true

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
                    .textCase(textCase)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
            .modifier(HoloFillGlow(active: style == .holoFill))
            .opacity(isEnabled ? 1.0 : 0.4)
        }
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: title) // haptic on tap
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .solid:
            Color.white
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
        style == .holoFill ? title.uppercased() : title.lowercased()
    }

    private var textFont: Font {
        style == .holoFill ? AppFont.display(17, weight: .bold) : AppFont.body(17, weight: .semibold)
    }

    private var textTracking: CGFloat {
        style == .holoFill ? 0.04 * 17 : -0.01 * 17
    }

    private var textCase: Text.Case? {
        style == .holoFill ? .uppercase : .lowercase
    }

    private var textColor: Color {
        switch style {
        case .solid, .holoFill: return AppColor.bg0
        case .holoBorder: return .white
        }
    }
}

private struct HoloFillGlow: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: Color(hex: 0xFF0080, alpha: 0.45), radius: 28)
                .shadow(color: Color(hex: 0x8000FF, alpha: 0.35), radius: 56)
        } else {
            content
        }
    }
}

// MARK: - SecondaryButton

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.lowercased())
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

// MARK: - Chip

struct Chip: View {
    let label: String
    let isSelected: Bool
    var size: Size = .regular
    var emoji: String? = nil
    let action: () -> Void

    enum Size { case regular, large }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji { Text(emoji).font(.system(size: 14)) }
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
                    if isSelected {
                        Capsule()
                            .strokeBorder(AppColor.holographic, lineWidth: 1)
                    } else {
                        Capsule()
                            .strokeBorder(AppColor.text10, lineWidth: 1)
                    }
                }
            )
            .modifier(HoloChipGlow(active: isSelected))
        }
    }
}

private struct HoloChipGlow: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: Color(hex: 0xFF0080, alpha: 0.30), radius: 10)
        } else {
            content
        }
    }
}

// MARK: - Dots (progress indicator)

struct ProgressDots: View {
    let total: Int
    let active: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == active ? Color.white : AppColor.text20)
                    .frame(width: index == active ? 16 : 6, height: 6)
                    .animation(AppAnimation.standard, value: active)
            }
        }
    }
}

// MARK: - TopBar

struct TopBar: View {
    let active: Int
    let total: Int
    var showBack: Bool = true
    var showClose: Bool = false
    var onBack: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil

    var body: some View {
        HStack {
            // Back
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .opacity(showBack ? 1 : 0)
            .disabled(!showBack)
            .frame(width: 28, alignment: .leading)

            Spacer()
            if total > 0 {
                ProgressDots(total: total, active: active)
            }
            Spacer()

            // Close
            Button(action: { onClose?() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.text40)
            }
            .opacity(showClose ? 1 : 0)
            .disabled(!showClose)
            .frame(width: 28, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }
}

// MARK: - ObservationCard (Asistan sesi — italik, lime stripe)

/// Gıcık'ın gözlem cümlesi. Lime stripe + italic body + glass card.
/// Sadece "asistan sesi" alanlarında kullanılır — ASLA kullanıcının çıktı mesajlarında.
struct ObservationCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Capsule()
                .fill(AppColor.lime)
                .frame(width: 3)
            Text(text.lowercased())
                .font(AppFont.body(15))
                .italic()
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(15 * 0.45)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .padding(.leading, 13)
        .padding(.trailing, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }
}

// MARK: - ReplyCard (Output sesi — kullanıcının atacağı mesaj)

/// 3 cevap önerisinden biri. Mono uppercase tone-angle label + body text + copy button + thumbs.
struct ReplyCard: View {
    let toneAngle: String   // "doğrudan engage" gibi
    let text: String
    let onCopy: () -> Void
    let onThumbsUp: () -> Void
    let onThumbsDown: () -> Void
    var isCopied: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(toneAngle.uppercased())
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
        .sensoryFeedback(.success, trigger: isCopied)
    }

    private var feedbackButtons: some View {
        HStack(spacing: 14) {
            Button(action: onThumbsUp) {
                Image(systemName: "hand.thumbsup")
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.text40)
            }
            Button(action: onThumbsDown) {
                Image(systemName: "hand.thumbsdown")
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.text40)
            }
        }
    }
}

// MARK: - GlassCard (re-usable surface)

struct GlassCard<Content: View>: ViewModifier {
    let cornerRadius: CGFloat
    let strokeOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColor.bgGlass)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(strokeOpacity), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = AppRadius.card, strokeOpacity: Double = 0.08) -> some View {
        modifier(GlassCard<Self>(cornerRadius: cornerRadius, strokeOpacity: strokeOpacity))
    }
}

// MARK: - Preview catalog

#Preview("Tokens · Primitives") {
    ScrollView {
        VStack(spacing: 24) {
            Logo(size: 88)
                .padding(.top, 40)

            VStack(spacing: 12) {
                PrimaryButton("başla", style: .solid) {}
                PrimaryButton("kalibre et", style: .holoBorder) {}
                PrimaryButton("ücretsiz başlat", style: .holoFill) {}
                SecondaryButton(title: "geç", action: {})
            }
            .padding(.horizontal, 24)

            HStack(spacing: 8) {
                Chip(label: "kadın", isSelected: true, size: .large, action: {})
                Chip(label: "erkek", isSelected: false, size: .large, action: {})
                Chip(label: "belirtmiyorum", isSelected: false, size: .large, action: {})
            }

            ProgressDots(total: 8, active: 2)

            ObservationCard(text: "3 gün cevap yok, sonra 'selam'. yazmamış sayılır.")
                .padding(.horizontal, 24)

            ReplyCard(
                toneAngle: "doğrudan engage",
                text: "merhaba diyen herkese güzel diyor musun yoksa sadece bana mı?",
                onCopy: {},
                onThumbsUp: {},
                onThumbsDown: {}
            )
            .padding(.horizontal, 24)

            Spacer(minLength: 60)
        }
    }
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
