import SwiftUI

/// Post-paywall kalibrasyon başlangıç — full-bleed hero bg + alt copy + 3-row list + CTA.
struct CalibrationIntroView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
                .frame(maxHeight: .infinity)

            VStack(alignment: .center, spacing: AppSpacing.sm + 4) {
                Text("seni tanıyalım.")
                    .font(AppFont.displayItalic(40, weight: .regular))
                    .tracking(-0.03 * 40)
                    .foregroundColor(AppColor.ink)
                    .multilineTextAlignment(.center)

                Text("9 kısa soru. tarzını belirleyelim,\ncevaplar sana göre olsun.")
                    .font(AppFont.body(14.5))
                    .foregroundColor(AppColor.text60)
                    .multilineTextAlignment(.center)
                    .lineSpacing(14.5 * 0.4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.lg)

            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.md + 2) {
                        Text(items[idx].0)
                            .font(AppFont.displayItalic(26, weight: .regular))
                            .tracking(-0.02 * 26)
                            .foregroundColor(AppColor.accent)
                            .frame(width: 32, alignment: .leading)
                        Text(items[idx].1)
                            .font(AppFont.body(14))
                            .foregroundColor(AppColor.ink)
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.md - 4)
                    .overlay(alignment: .top) {
                        if idx == 0 {
                            Rectangle().fill(AppColor.text10).frame(height: 1)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(AppColor.text10).frame(height: 1)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)

            HoloPrimaryButton(title: "başla", action: vm.advance)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                backgroundImage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [.clear, AppColor.bg0.opacity(0.55), AppColor.bg0.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 460)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea()
        )
    }

    private var backgroundImage: some View {
        Image("calibration-bg")
            .resizable()
            .scaledToFill()
    }

    private let items: [(String, String)] = [
        ("9", "soru. kısa, dürüst"),
        ("6", "arketipten birine yerleşeceksin"),
        ("∞", "istediğin zaman yenile"),
    ]
}

#Preview {
    CalibrationIntroView(vm: OnboardingViewModel())
        .preferredColorScheme(.dark)
}
