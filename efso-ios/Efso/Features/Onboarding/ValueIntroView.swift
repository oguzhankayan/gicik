import SwiftUI

/// 2-page value carousel — full-bleed hero background + alt CTA bloğu.
/// Hero görseller (input/output) zaten orta-alt ağırlıklı kompoze; üst metin alanı temiz kalır.
struct ValueIntroView: View {
    let onContinue: () -> Void

    @State private var page: Int = 0

    private let pages: [Page] = [
        Page(
            heroImage: "hero1",
            title: "konuşmayı yükle,",
            titleAccent: "cevabı bize bırak.",
            body: "dm, bio, eşleşme ya da eski mesaj. ne varsa ekle.",
            cta: "devam"
        ),
        Page(
            heroImage: "hero2",
            title: "cevaplar anında hazır.",
            titleAccent: "senin tarzında.",
            body: "senin tonuna uygun üç cevap.",
            cta: "başla"
        ),
    ]

    var body: some View {
        ZStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { idx in
                    heroImage(pages[idx])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(idx)
                        .ignoresSafeArea()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // okunurluk için iki uçtan yumuşak scrim — gradientler ekran kenarlarından başlar
            ZStack {
                VStack { Spacer(minLength: 0) }

                LinearGradient(
                    colors: [AppColor.bg0.opacity(0.88), AppColor.bg0.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 260)
                .frame(maxHeight: .infinity, alignment: .top)

                LinearGradient(
                    colors: [.clear, AppColor.bg0.opacity(0.55), AppColor.bg0.opacity(0.97)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                copyBlock
                    .padding(.top, AppSpacing.xxl + AppSpacing.md)

                Spacer(minLength: 0)

                VStack(spacing: AppSpacing.lg) {
                    progressDots
                    HoloPrimaryButton(title: pages[page].cta) {
                        if page < pages.count - 1 {
                            withAnimation(AppAnimation.standard) { page += 1 }
                        } else {
                            onContinue()
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var copyBlock: some View {
        VStack(spacing: AppSpacing.sm + 2) {
            VStack(spacing: 0) {
                Text(pages[page].title)
                    .font(AppFont.displayItalic(38, weight: .regular))
                    .tracking(-0.03 * 38)
                    .foregroundColor(AppColor.ink)
                Text(pages[page].titleAccent)
                    .font(AppFont.displayItalic(38, weight: .regular))
                    .tracking(-0.03 * 38)
                    .foregroundColor(AppColor.accent)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.75)

            Text(pages[page].body)
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .lineSpacing(14 * 0.4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppSpacing.lg)
        }
        .id(page)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == page ? AppColor.ink : AppColor.bg2)
                    .frame(width: i == page ? 24 : 6, height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    private func heroImage(_ p: Page) -> some View {
        Image(p.heroImage)
            .resizable()
            .scaledToFill()
    }

    private struct Page {
        let heroImage: String
        let title: String
        let titleAccent: String
        let body: String
        let cta: String
    }
}

#Preview {
    ValueIntroView(onContinue: {})
        .preferredColorScheme(.dark)
}
