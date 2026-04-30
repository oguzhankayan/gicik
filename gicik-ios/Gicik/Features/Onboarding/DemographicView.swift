import SwiftUI

/// Demographic — 3 grup chip seçimi (cinsiyet, yaş, niyet).
/// design-source/parts/onboarding.jsx → DemographicScreen
struct DemographicView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopBar(active: 4, total: 12, onBack: { vm.goBack() })

            VStack(alignment: .leading, spacing: 0) {
                Text("01 / KISA TANIŞMA")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.lime)

                Text("önce biraz\ntanışalım")
                    .font(AppFont.display(30, weight: .bold))
                    .tracking(-0.02 * 30)
                    .foregroundColor(.white)
                    .padding(.top, 12)

                section(title: "cinsiyet") {
                    HStack(spacing: 8) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Chip(label: g.label,
                                 isSelected: vm.demographic.gender == g,
                                 size: .large) {
                                vm.demographic.gender = g
                            }
                        }
                    }
                }
                .padding(.top, 36)

                section(title: "yaş") {
                    HStack(spacing: 8) {
                        ForEach(AgeBracket.allCases, id: \.self) { a in
                            Chip(label: a.label,
                                 isSelected: vm.demographic.ageBracket == a,
                                 size: .large) {
                                vm.demographic.ageBracket = a
                            }
                        }
                    }
                }
                .padding(.top, 28)

                section(title: "ne arıyorsun") {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                                        GridItem(.flexible(), spacing: 10)],
                              spacing: 10) {
                        ForEach(Intent.allCases, id: \.self) { intent in
                            intentCard(intent)
                        }
                    }
                }
                .padding(.top, 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            PrimaryButton("devam", isEnabled: vm.demographic.isComplete) {
                vm.advance()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
            content()
        }
    }

    private func intentCard(_ intent: Intent) -> some View {
        Button {
            vm.demographic.intent = intent
        } label: {
            HStack(spacing: 12) {
                Text(intent.emoji)
                    .font(.system(size: 22))
                Text(intent.label)
                    .font(AppFont.body(16))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 80)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(vm.demographic.intent == intent ? AppColor.bgGlass : AppColor.bg1.opacity(0.55))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            vm.demographic.intent == intent
                                ? AnyShapeStyle(AppColor.holographic)
                                : AnyShapeStyle(AppColor.text08),
                            lineWidth: 1
                        )
                }
            )
        }
        .sensoryFeedback(.selection, trigger: vm.demographic.intent)
    }
}

#Preview {
    DemographicView(vm: OnboardingViewModel())
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
