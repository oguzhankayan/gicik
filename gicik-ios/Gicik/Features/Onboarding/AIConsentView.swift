import SwiftUI

/// AI consent — KVKK + AI yasası gereği. 4 madde + holographic toggle + kaydet.
/// design-source/parts/onboard2.jsx → AIConsent
struct AIConsentView: View {
    @Bindable var vm: OnboardingViewModel
    @State private var consentToggle: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button { vm.goBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColor.text60)
                }
                Text("veri ve yapay zeka")
                    .font(AppFont.body(16))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 8)

            Text("açıkça\nne oluyor")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
                .lineSpacing(22 * 0.10)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    consentSection(
                        title: "EKRAN GÖRÜNTÜLERİN",
                        items: [
                            "yüklediğin görüntü 24 saat sonra silinir.",
                            "üzerindeki yazıyı yorumlamak için yapay zeka modellerine gönderilir.",
                            "isimleri otomatik bulanıklaştırmaya çalışıyoruz, deneysel.",
                        ]
                    )
                    consentSection(
                        title: "KONUŞMA KAYITLARIN",
                        items: [
                            "ürettiğimiz cevaplar 30 gün saklanır.",
                            "hangi cevabı seçtiğini, geri bildirimini gözlemleriz.",
                            "modeli senin tarzına göre eğitmek için kullanmıyoruz, sadece kalibre ediyoruz.",
                        ]
                    )
                    rightsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 220)
            }

            Spacer(minLength: 0)

            VStack(spacing: 14) {
                consentToggleRow
                Text("bu olmadan çalışmaz. her zaman geri çekebilirsin.")
                    .font(AppFont.body(11))
                    .foregroundColor(AppColor.text40)
                    .multilineTextAlignment(.center)

                PrimaryButton("kaydet", isEnabled: consentToggle) {
                    vm.aiConsentGiven = consentToggle
                    vm.advance()
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func consentSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AppFont.body(15))
                    .foregroundColor(AppColor.text60)
                    .lineSpacing(15 * 0.50)
                    .padding(.bottom, 6)
            }
        }
    }

    private var rightsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HAKLARIN")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)
                .padding(.bottom, 8)

            ForEach(["verilerini istediğin an silebilirsin",
                     "dışa aktarabilirsin",
                     "kalibrasyonu yenileyebilirsin"], id: \.self) { right in
                HStack {
                    Text(right)
                        .font(AppFont.body(15))
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.text40)
                }
                .padding(.vertical, 14)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                )
            }
        }
    }

    private var consentToggleRow: some View {
        HStack {
            Text("yapay zeka kullanımına onay veriyorum")
                .font(AppFont.body(14))
                .foregroundColor(.white)
            Spacer()
            holoToggle
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text08, lineWidth: 1)
                )
        )
    }

    private var holoToggle: some View {
        Button {
            withAnimation(AppAnimation.standard) {
                consentToggle.toggle()
            }
        } label: {
            ZStack(alignment: consentToggle ? .trailing : .leading) {
                Capsule()
                    .fill(consentToggle ? AppColor.pink : AppColor.text20)
                    .frame(width: 46, height: 28)
                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .padding(2)
            }
        }
        .sensoryFeedback(.selection, trigger: consentToggle)
    }
}

#Preview {
    AIConsentView(vm: OnboardingViewModel())
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
