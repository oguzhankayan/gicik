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
            ObservationCard(text: result.observation)
                .padding(.horizontal, 24)
                .padding(.top, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(result.replies) { reply in
                        ReplyCard(
                            toneAngle: "\(String(format: "%02d", reply.index + 1)) — \(reply.toneAngle)",
                            text: reply.text,
                            isCopied: copiedIndex == reply.index,
                            onCopy: { copy(reply) },
                            onThumbsUp: { sendFeedback(reply, positive: true) },
                            onThumbsDown: { sendFeedback(reply, positive: false) }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 180)
            }

            Spacer(minLength: 0)
            actionFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            Spacer()
            Button {
                // Regenerate
                if case .result = vm.stage {
                    vm.stage = .generation(result.mode, result.tone, screenshot: vm.pickedScreenshot ?? Data())
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var header: some View {
        Text("\(result.mode.label) › \(result.tone.label)")
            .font(AppFont.mono(11))
            .tracking(0.04 * 11)
            .foregroundColor(AppColor.text40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 10)
    }

    private var actionFooter: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                SecondaryButton(title: "farklı ton dene") {
                    vm.stage = .tone(result.mode, screenshot: vm.pickedScreenshot ?? Data())
                }
                PrimaryButton("yeni cevap üret") {
                    vm.stage = .generation(result.mode, result.tone, screenshot: vm.pickedScreenshot ?? Data())
                }
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
        // Phase 2'de mock. Phase 2.7 backend'e bağlanır:
        // POST /functions/v1/prompt-feedback
        // { conversation_id, selected_reply_index, feedback: positive ? "positive" : "negative" }
    }
}
