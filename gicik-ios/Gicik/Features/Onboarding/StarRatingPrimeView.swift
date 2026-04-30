import SwiftUI
import StoreKit

/// Star rating prime — Rizz playbook: paywall'dan ÖNCE rating iste.
/// Yıldızlar tıklanabilir (boş outline → tap → fill + native review dialog).
/// Altta sadece "şimdi değil" çıkışı.
struct StarRatingPrimeView: View {
    @Bindable var vm: OnboardingViewModel

    @State private var starsIn = false
    @State private var filled: Int = 0
    @State private var primed = false
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 8, total: 12, showBack: false)

            Spacer()

            VStack(spacing: 28) {
                starRow
                    .frame(height: 80)

                VStack(spacing: 12) {
                    Text("gıcık'a\n5 yıldız ver")
                        .font(AppFont.display(30, weight: .bold))
                        .tracking(-0.02 * 30)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(30 * 0.05)

                    Text("yeni başladık. yıldızın bizi büyütüyor.\nyıldızlara dokun.")
                        .font(AppFont.body(15))
                        .foregroundColor(AppColor.text60)
                        .multilineTextAlignment(.center)
                        .lineSpacing(15 * 0.4)
                        .padding(.horizontal, 28)
                }

                quoteCard
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            Spacer()

            Button("şimdi değil") {
                vm.advance()
            }
            .font(AppFont.body(14))
            .foregroundColor(AppColor.text40)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await runIntro() }
    }

    private var starRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { idx in
                Button {
                    handleStarTap(idx: idx)
                } label: {
                    Image(systemName: idx < filled ? "star.fill" : "star")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(idx < filled ? AnyShapeStyle(AppColor.lime) : AnyShapeStyle(AppColor.text40))
                        .shadow(color: idx < filled ? AppColor.lime.opacity(0.6) : .clear, radius: 14)
                        .scaleEffect(starsIn ? 1 : 0.3)
                        .opacity(starsIn ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.55)
                                .delay(Double(idx) * 0.08),
                            value: starsIn
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: filled)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: filled)
            }
        }
    }

    private func handleStarTap(idx: Int) {
        let target = idx + 1
        // Sequential fill animation
        Task {
            for n in (filled + 1)...target {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    filled = n
                }
                try? await Task.sleep(for: .milliseconds(80))
            }
            try? await Task.sleep(for: .milliseconds(350))
            guard !primed else { return }
            primed = true
            requestReview()
            try? await Task.sleep(for: .milliseconds(900))
            vm.advance()
        }
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.lime)
                }
                Spacer()
                Text("@ay****")
                    .font(AppFont.mono(10))
                    .foregroundColor(AppColor.text40)
            }
            Text("\"klişe attırmıyor. ex'le konuşurken kurtardı.\"")
                .font(AppFont.body(13))
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }

    private func runIntro() async {
        try? await Task.sleep(for: .milliseconds(120))
        starsIn = true
    }
}

#Preview {
    StarRatingPrimeView(vm: OnboardingViewModel())
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
