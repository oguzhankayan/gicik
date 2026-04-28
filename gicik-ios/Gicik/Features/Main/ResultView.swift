import SwiftUI

/// Result — 3 reply card + actions footer.
/// design-source/parts/result.jsx → Result
struct ResultView: View {
    @Bindable var vm: HomeViewModel
    let result: GenerationResult

    @State private var copiedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header

            // Cevaplar = ana içerik (ekranın çoğu).
            // Observation hint replies'la birlikte scroll ediyor, sabit değil.
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    inlineHint(result.observation)
                        .padding(.top, 6)

                    VStack(spacing: 12) {
                        ForEach(result.replies) { reply in
                            ReplyCard(
                                toneAngle: "\(String(format: "%02d", reply.index + 1)) — \(reply.toneLabel)",
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
                .padding(.top, 12)
                .padding(.bottom, 32)
            }

            actionFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Demo screen ile aynı kompakt hint bileşeni — info icon + italic text.
    /// Kart yerine satır içi gösterim; cevaplar için maksimum dikey alan.
    private func inlineHint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(AppColor.lime)
                .padding(.top, 2)
            Text(text.lowercased())
                .font(AppFont.body(13))
                .italic()
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityLabel("geri")
            Spacer()
            Button {
                vm.regenerate()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityLabel("yeniden üret")
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var header: some View {
        Text(result.mode.label)
            .font(AppFont.mono(11))
            .tracking(0.04 * 11)
            .foregroundColor(AppColor.text40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 10)
    }

    private var actionFooter: some View {
        VStack(spacing: 12) {
            PrimaryButton("yeni cevap üret") {
                vm.regenerate()
            }
            Button("konuşmayı bitir") {
                vm.backToHome()
            }
            .font(AppFont.body(13))
            .foregroundColor(AppColor.text40)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

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
                // Silent failure'i Sentry'e log et — non-blocking
                AnalyticsService.shared.track(.generationFailed, properties: [
                    "context": "prompt_feedback",
                    "error": error.localizedDescription,
                ])
            }
        }
    }
}
