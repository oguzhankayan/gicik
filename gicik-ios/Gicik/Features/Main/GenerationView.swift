import SwiftUI

/// Streaming generation UI — observation typewriter + 3 reply skeletons.
/// design-source/parts/result.jsx → Generation
struct GenerationView: View {
    let mode: Mode
    let tone: Tone

    @State private var observationText: String = ""
    private let fullObservation = "3 gün cevap yok, sonra 'selam'. yazmamış sayılır. ama ben yazacağım."

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
            // Observation typewriter
            if !observationText.isEmpty {
                ObservationCard(text: observationText)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }
            // 3 skeleton cards
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    ReplyCardSkeleton()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await typewrite(fullObservation)
        }
    }

    private var topBar: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppColor.text60)
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

    private func typewrite(_ text: String) async {
        observationText = ""
        for char in text {
            observationText.append(char)
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
    }
}
