import SwiftUI

/// "nasıl çalışır" — 4 slayt, opacity cross-fade. Her slayt static; içeriği
/// bir defada gösterir. Tıkanmadan okunsun, glitch yapmasın diye sade.
///
/// Slaytlar (5s × 4 = 20s loop):
///   1. ekran görüntüsü ver  — chat screenshot, başlık "1. EKRAN GÖRÜNTÜSÜ VER"
///   2. gıcık okuyor          — aynı screenshot + observation cümlesi
///   3. üç farklı ton         — 3 reply card listesi
///   4. seç ve gönder         — aynı 3 kart, ortadaki lime stroke ile seçili
///
/// Reduced Motion: slayt süresi 7s, transition opacity yine açık (basit fade
/// erişilebilirlik için sorunsuz; spring/scale yok).
struct HowItWorksView: View {
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var slide: Int = 0

    private let slideCount = 4

    private var slideDuration: TimeInterval { reduceMotion ? 7.0 : 5.0 }

    var body: some View {
        ZStack {
            CosmicBackground()

            // Tüm slaytlar aynı ZStack'ta; sadece opacity ile değişir.
            // Layout shift olmaz, identity stabil.
            ZStack {
                slide1.opacity(slide == 0 ? 1 : 0)
                slide2.opacity(slide == 1 ? 1 : 0)
                slide3.opacity(slide == 2 ? 1 : 0)
                slide4.opacity(slide == 3 ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.45), value: slide)

            VStack {
                topBar
                Spacer()
                progressDots.padding(.bottom, 36)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(slideA11y[slide])
        .task(id: "how-it-works-loop") {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(slideDuration * 1_000_000_000))
                if Task.isCancelled { break }
                slide = (slide + 1) % slideCount
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { onClose() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .padding(10)
            }
            Spacer()
            Text("nasıl çalışır")
                .font(AppFont.body(15))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Button {
                slide = 0
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .padding(10)
            }
            .accessibilityLabel("baştan oynat")
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
    }

    // MARK: - Progress dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<slideCount, id: \.self) { i in
                Capsule()
                    .fill(i == slide ? AppColor.pink : AppColor.text20)
                    .frame(width: i == slide ? 18 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.35), value: slide)
            }
        }
    }

    // MARK: - Slides

    private var slide1: some View {
        VStack(spacing: 28) {
            stepLabel("1", "EKRAN GÖRÜNTÜSÜ VER")
            ChatScreenshot(highlightedIndex: nil)
            Spacer().frame(height: 28)
        }
    }

    private var slide2: some View {
        VStack(spacing: 22) {
            stepLabel("2", "GICIK OKUYOR")
            // Son bubble (karşı tarafın sorusu) vurgulanır — "cevap bekliyor".
            ChatScreenshot(highlightedIndex: 2)
            HStack(spacing: 6) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.text40)
                Text("kahveyi o öneriyor. sıra sende.")
                    .font(AppFont.mono(13))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 24)
        }
    }

    private var slide3: some View {
        VStack(spacing: 22) {
            stepLabel("3", "ÜÇ FARKLI TON")
            replyList(selectedIndex: nil)
        }
    }

    private var slide4: some View {
        VStack(spacing: 22) {
            stepLabel("4", "SEÇ. YAPIŞTIR. GÖNDER.")
            replyList(selectedIndex: 1)
        }
    }

    private func replyList(selectedIndex: Int?) -> some View {
        VStack(spacing: 12) {
            ReplyMini(
                tone: "flörtöz",
                text: "kahve klasik. başka bir şey önerirsen evet.",
                selected: selectedIndex == 0
            )
            ReplyMini(
                tone: "esprili",
                text: "kahveyle aram iyi, mekan da iyi olsun yeter.",
                selected: selectedIndex == 1
            )
            ReplyMini(
                tone: "direkt",
                text: "olur. perşembe akşam müsaitim.",
                selected: selectedIndex == 2
            )
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step label

    private func stepLabel(_ num: String, _ title: String) -> some View {
        VStack(spacing: 8) {
            Text(num)
                .font(AppFont.mono(12, weight: .medium))
                .tracking(0.06 * 12)
                .foregroundColor(AppColor.text40)
            Text(title)
                .font(AppFont.display(20, weight: .bold))
                .tracking(0.04 * 20)
                .foregroundColor(AppColor.pink)
                .shadow(color: AppColor.pinkGlow, radius: 12)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 60)
    }

    // MARK: - A11y

    private let slideA11y = [
        "1. ekran görüntüsü ver. konuşmayı yükle.",
        "2. gıcık okuyor. üç gün sustuğunu fark ediyor.",
        "3. üç farklı tonda cevap üretiyor: flörtöz, esprili, direkt.",
        "4. seç, yapıştır, gönder."
    ]
}

// MARK: - ChatScreenshot

/// Statik chat görseli — anlık konuşma örneği:
///   0 (sol, karşı): "n'aber"
///   1 (sağ, sen):   "iyiyim, sen?"
///   2 (sol, karşı): "kahve içelim mi?"
/// `highlightedIndex` verilirse o bubble lime'a döner — slayt 2'de son söz
/// karşıdan, "sıra sende" sinyali için.
private struct ChatScreenshot: View {
    let highlightedIndex: Int?

    private struct Msg {
        let text: String
        let isOther: Bool   // true = sol, false = sağ (kullanıcı)
    }

    private let messages: [Msg] = [
        .init(text: "n'aber", isOther: true),
        .init(text: "iyiyim, sen?", isOther: false),
        .init(text: "kahve içelim mi?", isOther: true),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(messages.enumerated()), id: \.offset) { idx, msg in
                bubble(text: msg.text, isOther: msg.isOther,
                       highlighted: highlightedIndex == idx)
            }
        }
        .padding(18)
        .frame(width: 260, height: 180, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.bg1.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AppColor.holographic, lineWidth: 1.5)
                        .opacity(0.5)
                )
        )
    }

    @ViewBuilder
    private func bubble(text: String, isOther: Bool, highlighted: Bool) -> some View {
        HStack {
            if !isOther { Spacer() }
            Text(text)
                .font(AppFont.body(13, weight: .medium))
                .foregroundColor(highlighted ? AppColor.bg0 : .white.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(highlighted ? AppColor.lime : AppColor.bg2.opacity(0.95))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            highlighted ? AppColor.lime : AppColor.text10,
                            lineWidth: highlighted ? 1 : 0.5
                        )
                )
                .shadow(color: highlighted ? AppColor.lime.opacity(0.4) : .clear, radius: 10)
            if isOther { Spacer() }
        }
    }
}

// MARK: - ReplyMini

/// Statik reply kartı — tone chip + tek satır gerçek cevap. Seçiliyse lime
/// stroke + soft glow. Spring/scale yok; sadece state değiştiğinde fade.
private struct ReplyMini: View {
    let tone: String
    let text: String
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Circle()
                    .fill(AppColor.holographic)
                    .frame(width: 4, height: 4)
                Text(tone)
                    .font(AppFont.body(10, weight: .medium))
                    .tracking(0.04 * 10)
                    .foregroundColor(AppColor.text60)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColor.lime)
                }
            }
            Text(text)
                .font(AppFont.body(13))
                .foregroundColor(.white.opacity(0.92))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg2.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            selected ? AppColor.lime : AppColor.text10,
                            lineWidth: selected ? 1.5 : 0.5
                        )
                )
        )
        .shadow(
            color: selected ? AppColor.lime.opacity(0.3) : .clear,
            radius: selected ? 16 : 0
        )
    }
}

// MARK: - Preview

#Preview("nasıl çalışır") {
    HowItWorksView(onClose: {})
        .preferredColorScheme(.dark)
}
