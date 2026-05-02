import SwiftUI

/// Refined-y2k "nasıl çalışır" — italic "4 adım. otomatik değil." +
/// numerik prefix'li 4 satırlı editorial liste + ink CTA.
struct HowItWorksView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            VStack(alignment: .leading, spacing: 12) {
                Text("4 adım.\notomatik değil.")
                    .font(AppFont.displayItalic(36, weight: .regular))
                    .tracking(-0.03 * 36)
                    .foregroundColor(AppColor.ink)
                    .lineSpacing(36 * 0.0)
                Text("efso senin yerine konuşmaz. bağlamı okur, ne demek istediğini netleştirir.")
                    .font(AppFont.body(14))
                    .foregroundColor(AppColor.text60)
                    .lineSpacing(14 * 0.4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            VStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { idx in
                    let s = steps[idx]
                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        Text(s.0)
                            .font(AppFont.mono(11, weight: .medium))
                            .tracking(0.16 * 11)
                            .foregroundColor(AppColor.accent)
                            .frame(width: 28, alignment: .leading)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(s.1)
                                .font(AppFont.displayItalic(22, weight: .regular))
                                .tracking(-0.02 * 22)
                                .foregroundColor(AppColor.ink)
                            Text(s.2)
                                .font(AppFont.body(13.5))
                                .foregroundColor(AppColor.text60)
                                .lineSpacing(13.5 * 0.30)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .overlay(alignment: .top) {
                        Rectangle().fill(AppColor.text10).frame(height: 1)
                    }
                    .overlay(alignment: .bottom) {
                        if idx == steps.count - 1 {
                            Rectangle().fill(AppColor.text10).frame(height: 1)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            HoloPrimaryButton(title: "tamam, başlayalım", action: onClose)
                .padding(.horizontal, 20)
                .padding(.bottom, 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        HStack {
            Button { onClose() } label: {
                Text("← geri")
                    .font(AppFont.mono(12))
                    .tracking(0.10 * 12)
                    .foregroundColor(AppColor.text60)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
            }
            Spacer()
            EfsoTag("nasıl çalışır", color: AppColor.text40)
            Spacer()
            Color.clear.frame(width: 60, height: 44)
        }
        .padding(.top, 6)
    }

    private let steps: [(String, String, String)] = [
        ("01", "kalibre et", "9 soru. nasıl yazdığını öğrenir."),
        ("02", "konuşmayı ver", "screenshot ya da elle. neyi tartıştığınızı anlar."),
        ("03", "üç açıyla cevap al", "farklı tonlar. seçimini sen yap."),
        ("04", "gözlemi oku", "ne hissettiğini fark et. cümleden önce."),
    ]
}

#Preview {
    HowItWorksView(onClose: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
