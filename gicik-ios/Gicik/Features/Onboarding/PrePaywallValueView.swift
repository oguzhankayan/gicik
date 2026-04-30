import SwiftUI

/// Pre-paywall value reinforcement — paywall'dan hemen önce, archetype-aware.
/// "Senin tarzın belli, gıcık hazır" mesajı + 3 net benefit + bridge CTA.
/// Rizz playbook: paywall'dan önce son value moment.
struct PrePaywallValueView: View {
    @Bindable var vm: OnboardingViewModel
    let onContinue: () -> Void

    @State private var stepIn: [Bool] = [false, false, false]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopBar(active: 9, total: 12, showBack: false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("HAZIRSIN")
                        .font(AppFont.mono(11))
                        .tracking(0.06 * 11)
                        .foregroundColor(AppColor.lime)
                        .padding(.top, 12)

                    Text(headline)
                        .font(AppFont.display(30, weight: .bold))
                        .tracking(-0.02 * 30)
                        .foregroundColor(.white)
                        .lineSpacing(30 * 0.05)
                        .padding(.top, 10)

                    Text(subline)
                        .font(AppFont.body(15))
                        .foregroundColor(AppColor.text60)
                        .lineSpacing(15 * 0.4)
                        .padding(.top, 14)
                        .fixedSize(horizontal: false, vertical: true)

                    archetypeChip
                        .padding(.top, 22)

                    VStack(spacing: 14) {
                        ForEach(benefits.indices, id: \.self) { idx in
                            benefitRow(benefits[idx], index: idx)
                                .opacity(stepIn[idx] ? 1 : 0)
                                .offset(y: stepIn[idx] ? 0 : 12)
                        }
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }

            PrimaryButton("devam") { onContinue() }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            for i in 0..<benefits.count {
                try? await Task.sleep(for: .milliseconds(220))
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                    stepIn[i] = true
                }
            }
        }
    }

    private var headline: String {
        if vm.archetype != nil {
            return "tarzın belli.\ngıcık hazır."
        }
        return "tanıştık.\ngıcık hazır."
    }

    private var subline: String {
        "bundan sonra hangi mesaj zor gelirse, ekran görüntüsü at. cevap senin tarzında çıksın."
    }

    @ViewBuilder
    private var archetypeChip: some View {
        if let a = vm.archetype {
            let parts = splitLabel(a.displayLabel)
            HStack(spacing: 14) {
                Text(parts.emoji)
                    .font(.system(size: 32))
                Text(parts.name.trLower)
                    .font(AppFont.display(22, weight: .bold))
                    .tracking(-0.02 * 22)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AppColor.holographic, lineWidth: 1)
                            .opacity(0.45)
                    )
            )
        }
    }

    /// "🥀 GICIK" → (emoji: "🥀", name: "GICIK"). Boşluk yoksa label aynen kullanılır.
    private func splitLabel(_ raw: String) -> (emoji: String, name: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if let space = trimmed.firstIndex(of: " ") {
            let emoji = String(trimmed[..<space])
            let name = String(trimmed[trimmed.index(after: space)...]).trimmingCharacters(in: .whitespaces)
            return (emoji, name)
        }
        return ("✨", trimmed)
    }

    private struct Benefit { let icon: String; let title: String; let body: String }

    private let benefits: [Benefit] = [
        .init(icon: "bolt.fill", title: "saniyeler içinde",
              body: "ekran görüntüsü at, 3 cevap. düşünmek sana kalsın."),
        .init(icon: "slider.horizontal.3", title: "5 ton, sen seç",
              body: "flörtöz, esprili, direkt, sıcak, gizemli. gıcık o ses olur."),
        .init(icon: "lock.shield.fill", title: "senin tarzın saklı",
              body: "kalibrasyon ve örnek metnin sadece sende. 24 saatte ekranlar silinir.")
    ]

    private func benefitRow(_ b: Benefit, index: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColor.lime.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: b.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColor.lime)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(b.title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundColor(.white)
                Text(b.body)
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text60)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

#Preview {
    PrePaywallValueView(vm: OnboardingViewModel(), onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
