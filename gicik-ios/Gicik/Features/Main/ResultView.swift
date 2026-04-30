import SwiftUI

/// Result — observation hint + 3 reply card + tone switcher + actions footer.
/// replies boşsa explicit failure state (boş scroll yerine retry CTA'lı kart).
struct ResultView: View {
    @Bindable var vm: HomeViewModel
    let result: GenerationResult

    @State private var copiedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if result.replies.isEmpty {
                failureState
            } else {
                contentScroll
                actionFooter
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Content

    private var contentScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                observationVerdict(result.observation)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    ForEach(result.replies) { reply in
                        ReplyCard(
                            toneAngle: replyLabel(reply),
                            text: reply.text,
                            isCopied: copiedIndex == reply.index,
                            onCopy: { copy(reply) },
                            onThumbsUp: { sendFeedback(reply, positive: true) },
                            onThumbsDown: { sendFeedback(reply, positive: false) }
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
    }

    /// Em-dash yerine interpunct (·) — marka tonu minimal, AI imzası uzak dur.
    private func replyLabel(_ reply: ReplyOption) -> String {
        let idx = String(format: "%02d", reply.index + 1)
        return "\(idx) · \(reply.toneLabel.trLower)"
    }

    /// Observation = gıcık'ın gözlemi. Eskiden italic info bar'dı (kimse
    /// okumuyordu). Artık page-title treatment: büyük lowercase display, küçük
    /// "gözlem" mono label üstünde. Markanın gerçek anı, footnote değil.
    /// Boş gelirse hiç render edilmez.
    @ViewBuilder
    private func observationVerdict(_ text: String) -> some View {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).trLower
        if !trimmed.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("gözlem")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)
                Text(trimmed)
                    .font(AppFont.display(20, weight: .bold))
                    .tracking(-0.02 * 20)
                    .foregroundColor(.white)
                    .lineSpacing(20 * 0.10)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - TopBar

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityLabel("geri")
            Spacer()
            Text(result.mode.label.trLower)
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    // MARK: - Failure state

    /// replies=[] olduğunda boş ScrollView yerine açık retry CTA.
    /// observation alanı backend'in fail copy'sini taşır ("bağlantı sorunu...").
    private var failureState: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(AppColor.text40)
            Text("üretim tutmadı.")
                .font(AppFont.display(20, weight: .bold))
                .tracking(-0.02 * 20)
                .foregroundColor(.white)
            Text(result.observation.isEmpty
                 ? "bağlantı veya parse sorunu. tekrar dene."
                 : result.observation)
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 10) {
                PrimaryButton("tekrar dene") { vm.regenerate() }
                Button("geri dön") { vm.backToHome() }
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text40)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action footer (tone switcher + actions)

    private var actionFooter: some View {
        VStack(spacing: 14) {
            toneSwitcher
            HStack(spacing: 10) {
                SecondaryButton(title: "tekrarla") { vm.regenerate() }
                PrimaryButton("baştan") { vm.backToHome() }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            // Footer'ı içerikten ayır — küçük üst stroke, fill yok.
            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppColor.text05)
                    .frame(height: 1)
                Spacer()
            }
        )
    }

    /// Sonuç ekranında ton değiştir → sadece seçim yapılır, üretim tetiklenmez.
    /// Kullanıcı seçimi onaylamak için "tekrarla" butonuna basınca yeni tonla
    /// regenerate olur. Önceki tap-anında-üret davranışı sürpriz costtu — yanlış
    /// tona basınca kazara yeni LLM call (free tier'da kotaya geçer).
    /// "üç farklı" pill default'a geri dönüş.
    private var toneSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Chip(
                    label: "üç farklı",
                    isSelected: vm.selectedTone == nil
                ) {
                    vm.selectedTone = nil
                }
                ForEach(Tone.allCases) { tone in
                    Chip(
                        label: tone.label.trLower,
                        isSelected: vm.selectedTone == tone,
                        emoji: tone.emoji
                    ) {
                        vm.selectedTone = tone
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Actions

    private func copy(_ reply: ReplyOption) {
        UIPasteboard.general.string = reply.text
        copiedIndex = reply.index
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if copiedIndex == reply.index { copiedIndex = nil }
        }
    }

    private func sendFeedback(_ reply: ReplyOption, positive: Bool) {
        guard let conversationId = result.conversationId else { return }

        struct FeedbackBody: Encodable {
            let conversation_id: String
            let selected_reply_index: Int?
            let feedback: String
        }

        struct FeedbackResp: Decodable { let ok: Bool }

        Task {
            do {
                _ = try await APIClient.shared.invokeJSON(
                    .promptFeedback,
                    body: FeedbackBody(
                        conversation_id: conversationId,
                        selected_reply_index: reply.index,
                        feedback: positive ? "positive" : "negative"
                    ),
                    as: FeedbackResp.self
                )
            } catch {
                AnalyticsService.shared.track(.generationFailed, properties: [
                    "context": "prompt_feedback",
                    "error": error.localizedDescription,
                ])
            }
        }
    }
}
