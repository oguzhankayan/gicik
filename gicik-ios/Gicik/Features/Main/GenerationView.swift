import SwiftUI

/// Streaming generation UI — observation typewriter + 3 reply skeletons,
/// filled live as SSE events arrive from /generate-replies.
struct GenerationView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode
    let tone: Tone

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
            if !vm.streamingObservation.isEmpty {
                ObservationCard(text: vm.streamingObservation)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .transition(.opacity)
            }

            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { idx in
                    if let r = vm.streamingReplies[idx] {
                        ReplyCard(
                            toneAngle: "\(String(format: "%02d", idx + 1)) — \(r.toneAngle)",
                            text: r.text,
                            onCopy: {}
                        )
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        ReplyCardSkeleton()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .animation(AppAnimation.standard, value: vm.streamingReplies.count)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppAnimation.standard, value: vm.streamingObservation)
    }

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(mode.label) MODU / \(tone.label) TON")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text60)
            Text("GICIK YAZIYOR…")
                .font(AppFont.display(24, weight: .bold))
                .tracking(-0.02 * 24)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
