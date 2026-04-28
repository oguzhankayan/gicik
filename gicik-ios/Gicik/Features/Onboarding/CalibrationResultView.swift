import SwiftUI

/// Calibration result reveal — orbital + arketip emoji + 3 obs cümlesi.
/// design-source/parts/quiz.jsx → CalibrationResult
struct CalibrationResultView: View {
    @Bindable var vm: OnboardingViewModel
    @State private var rotation: Double = 0
    @State private var revealedCount: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Reveal ekranında back/close butonu yok — kullanıcı alttaki
            // 'devam et' veya 'yeniden kalibre et' ile ilerler.
            Spacer().frame(height: 60)

            VStack(spacing: 0) {
                orbital
                    .padding(.top, 8)

                Text("SENİN TARZIN…")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.lime)
                    .padding(.top, 18)

                if let result = vm.archetype {
                    Text(result.archetypePrimary.label.dropFirst(2))
                        .font(AppFont.display(40, weight: .bold))
                        .tracking(-0.01 * 40)
                        .foregroundColor(.white)
                        .padding(.top, 6)
                } else if let err = vm.lastError {
                    VStack(spacing: 8) {
                        Text("hesaplanamadı")
                            .font(AppFont.display(28, weight: .bold))
                            .foregroundColor(AppColor.danger)
                        Text(err)
                            .font(AppFont.body(12))
                            .foregroundColor(AppColor.text40)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 6)
                } else {
                    Text("yükleniyor…")
                        .font(AppFont.body(16))
                        .foregroundColor(AppColor.text40)
                        .padding(.top, 6)
                }
            }
            .padding(.horizontal, 24)

            // 3 obs cards (typewriter reveal)
            VStack(spacing: 10) {
                if let result = vm.archetype {
                    ForEach(Array(result.displayDescription.enumerated()), id: \.offset) { idx, line in
                        if idx < revealedCount {
                            ObservationCard(text: line)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 10) {
                Text("HER ZAMAN DEĞİŞEBİLİR. AYARLARDAN.")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)

                if vm.lastError != nil {
                    PrimaryButton("tekrar dene") {
                        vm.retryCalibrationSubmit()
                    }
                    .padding(.horizontal, 24)
                } else {
                    PrimaryButton("devam et",
                                  isEnabled: vm.archetype != nil,
                                  action: vm.advance)
                    .padding(.horizontal, 24)
                }

                Button("yeniden kalibre et") {
                    vm.quizIndex = 0
                    vm.quizAnswers.removeAll()
                    vm.archetype = nil
                    vm.step = .calibrationQuiz
                }
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            // Submit calibration if not done yet
            if vm.archetype == nil {
                await vm.submitCalibration()
            }
            startReveal()
        }
        .onAppear {
            withAnimation(AppAnimation.spinSlow) {
                rotation = 360
            }
        }
    }

    private var orbital: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.pink.opacity(0.55),
                                 AppColor.purple.opacity(0.30),
                                 .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 28)

            ForEach(0..<3) { i in
                let size = [230, 175, 125][i]
                Circle()
                    .strokeBorder(AppColor.holographic, lineWidth: 1)
                    .frame(width: CGFloat(size), height: CGFloat(size))
                    .opacity(0.6 - Double(i) * 0.05)
                    .rotationEffect(.degrees(i % 2 == 0 ? rotation : -rotation))
            }

            // Arketip emoji center
            Text(emojiFromArchetype())
                .font(.system(size: 80))
                .shadow(color: AppColor.pink.opacity(0.7), radius: 22)
        }
        .frame(width: 240, height: 240)
    }

    private func emojiFromArchetype() -> String {
        guard let label = vm.archetype?.archetypePrimary.label else { return "✨" }
        // First scalar (emoji)
        return String(label.first ?? "✨")
    }

    private func startReveal() {
        revealedCount = 0
        Task { @MainActor in
            for i in 1...3 {
                try? await Task.sleep(nanoseconds: 350_000_000)
                withAnimation(AppAnimation.standard) {
                    revealedCount = i
                }
            }
        }
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.archetype = ArchetypeResult(
        archetypePrimary: .dryroaster,
        archetypeSecondary: .observer,
        displayLabel: ArchetypePrimary.dryroaster.label,
        displayDescription: ArchetypePrimary.dryroaster.description
    )
    return CalibrationResultView(vm: vm)
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
