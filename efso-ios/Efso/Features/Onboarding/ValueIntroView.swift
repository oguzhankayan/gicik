import SwiftUI

/// Value carousel — splash sonrası, kullanıcı henüz hiçbir şey vermeden ne yaptığımızı gösterir.
/// 3 sayfa, swipe + bottom CTA. son sayfada CTA "kalibre et" olur, kalibrasyona düşer.
/// Visual'ler 1536×1024 PNG asset (slide1/slide2/slide3) — Nano Banana Pro üretim.
struct ValueIntroView: View {
    let onContinue: () -> Void

    @State private var page: Int = 0

    private let pages: [Page] = [
        Page(
            kicker: "ne yapar",
            headline: "ekran görüntüsü\nat. cevap çıksın.",
            body: "dm, eski, patron, eşleşme — fark etmez. konuşmayı oku, 3 cevap üret. senin tarzında.",
            asset: "slide1"
        ),
        Page(
            kicker: "neden farklı",
            headline: "klişe değil.\nseni dinler.",
            body: "kalibrasyonla tarzını öğrenir. flörtöz, esprili, direkt — sen seçersin, efso o ses olur.",
            asset: "slide2"
        ),
        Page(
            kicker: "nasıl çalışır",
            headline: "iki dakikada\ntanışalım.",
            body: "9 soru. tarzını belirleyelim. sonrası kolay.",
            asset: "slide3"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("atla") { onContinue() }
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text40)
                    .padding(.trailing, 20)
            }
            .padding(.top, 60)

            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { idx in
                    pageView(pages[idx])
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: page)

            ProgressDots(total: pages.count, active: page)
                .padding(.bottom, 24)

            PrimaryButton(page == pages.count - 1 ? "kalibre et" : "devam") {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    onContinue()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func pageView(_ p: Page) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            Image(p.asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 240)
                .padding(.horizontal, 24)

            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: 14) {
                Text(p.kicker.trUpper)
                    .font(AppFont.mono(11))
                    .tracking(0.06 * 11)
                    .foregroundColor(AppColor.lime)
                Text(p.headline)
                    .font(AppFont.display(30, weight: .bold))
                    .tracking(-0.02 * 30)
                    .foregroundColor(.white)
                    .lineSpacing(30 * 0.04)
                Text(p.body)
                    .font(AppFont.body(15))
                    .foregroundColor(AppColor.text60)
                    .lineSpacing(15 * 0.4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.bottom, 12)
        }
    }

    private struct Page {
        let kicker: String
        let headline: String
        let body: String
        let asset: String
    }
}

#Preview {
    ValueIntroView(onContinue: {})
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
