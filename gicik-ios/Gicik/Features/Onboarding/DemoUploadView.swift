import SwiftUI

/// Demo upload — aha moment.
/// Yukarıda küçük bir konuşma geçmişi (rounded rectangle, son mesaj cevapsız).
/// Ortada Gıcık'ın o son mesaja dair gözlemi.
/// Aşağıda kalibrasyon modellerinin önereceği 3 farklı cevap (typewriter reveal).
///
/// Cevap modu deneyimini birebir taklit eder.
struct DemoUploadView: View {
    let onContinue: () -> Void
    @State private var revealedCount: Int = 0
    @State private var pulseEmphasis: Bool = false

    private struct ChatMessage {
        let isMine: Bool
        let text: String
    }

    private let chat: [ChatMessage] = [
        .init(isMine: false, text: "akşam ne yapıyon"),
        .init(isMine: true,  text: "valla bilmiyom ne yapsak?"),
        .init(isMine: false, text: "8'de kadıköy boğa uyar mı?"),  // last, unanswered
    ]

    /// Demo'da 6 arketipten 3'ünü gösteriyoruz: en kontrastlı uçlar
    /// (kuru-zekice / soğukkanlı-stratejik / sıcak-samimi) ki kullanıcı
    /// kalibrasyonun çıktıyı nasıl etkilediğini hisseden.
    private let demoReplies: [(label: String, text: String)] = [
        ("🥀 GICIK olsa",  "8 erken ama gelirim. nereye otursak, boğa'nın orda mı dikilelim?"),
        ("✨ HAVALI olsa", "8 ok, yola çıkmadan önce haber veririm. bir yerlerden yer ayarlarsın."),
        ("🍬 TATLI olsa",  "olur, geliyorum. seni görmek iyi gelecek."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 5, total: 8, showBack: false)

            VStack(alignment: .leading, spacing: 0) {
                Text("DEMO / DENEME")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)

                Text("son mesaj cevapsız.\ngıcık olsa ne yazardı?")
                    .font(AppFont.display(22, weight: .bold))
                    .tracking(-0.02 * 22)
                    .foregroundColor(.white)
                    .lineSpacing(22 * 0.10)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)

            chatBubbleCard
                .padding(.horizontal, 24)
                .padding(.top, 18)

            ObservationCard(text: "davet karşıdan. uzun cevap istemiyor — gel ya da kontra teklif et.")
                .padding(.horizontal, 24)
                .padding(.top, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Array(demoReplies.enumerated()), id: \.offset) { idx, item in
                        if idx < revealedCount {
                            ReplyCard(
                                toneAngle: item.label,
                                text: item.text,
                                onCopy: {}
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            ReplyCardSkeleton()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)

            SecondaryButton(title: "ben de denemek istiyorum →", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            revealedCount = 0
            for i in 1...demoReplies.count {
                try? await Task.sleep(nanoseconds: 800_000_000)
                withAnimation(AppAnimation.standard) {
                    revealedCount = i
                }
            }
        }
        .onAppear {
            withAnimation(AppAnimation.pulseGlow) {
                pulseEmphasis = true
            }
        }
    }

    private var chatBubbleCard: some View {
        VStack(spacing: 8) {
            ForEach(Array(chat.enumerated()), id: \.offset) { idx, msg in
                chatBubble(msg, isLast: idx == chat.count - 1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.55))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppColor.text08, lineWidth: 1)
            }
        )
    }

    @ViewBuilder
    private func chatBubble(_ msg: ChatMessage, isLast: Bool) -> some View {
        HStack(spacing: 0) {
            if msg.isMine { Spacer(minLength: 60) }

            Text(msg.text)
                .font(AppFont.body(14))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    bubbleBackground(isMine: msg.isMine, emphasized: isLast && !msg.isMine)
                )
                .scaleEffect(isLast && !msg.isMine && pulseEmphasis ? 1.02 : 1.0)
                .shadow(
                    color: isLast && !msg.isMine
                        ? Color(hex: 0xFF0080, alpha: pulseEmphasis ? 0.35 : 0.15)
                        : .clear,
                    radius: 14
                )

            if !msg.isMine { Spacer(minLength: 60) }
        }
    }

    @ViewBuilder
    private func bubbleBackground(isMine: Bool, emphasized: Bool) -> some View {
        if emphasized {
            // Last unanswered "their" bubble — holographic 1pt border + glow
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg2.opacity(0.85))
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(AppColor.holographic, lineWidth: 1)
            }
        } else if isMine {
            // User's reply bubble — pink fill
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: 0xFF0080, alpha: 0.5))
        } else {
            // Their bubble — neutral glass
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.10))
        }
    }
}

#Preview {
    DemoUploadView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
