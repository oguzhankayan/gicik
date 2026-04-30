import SwiftUI
import RevenueCat

/// Paywall — Rizz playbook (2026-04-30): üstte feature carousel + tek "ücretsiz başlat"
/// CTA. Fiyat ana ekranda görünmez. CTA tap → bottom sheet ile plan + price + ödeme.
/// `lockReason` opsiyonel. nil = onboarding sonu hard paywall.
struct PaywallView: View {
    let onContinue: () -> Void
    let onDismiss: (() -> Void)?
    var lockReason: EntitlementGate.LockReason?

    @State private var subs = SubscriptionManager.shared
    @State private var carouselIndex = 0
    @State private var showPlanSheet = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    init(
        onContinue: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil,
        lockReason: EntitlementGate.LockReason? = nil
    ) {
        self.onContinue = onContinue
        self.onDismiss = onDismiss
        self.lockReason = lockReason
    }

    var body: some View {
        ZStack(alignment: .top) {
            CosmicBackground()
            VStack(spacing: 0) {
                if onDismiss != nil { dismissBar }

                carousel
                    .frame(height: 460)
                    .padding(.top, onDismiss == nil ? 36 : 0)

                Spacer(minLength: 0)

                bottomBlock
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await runCarouselTimer() }
        .sheet(isPresented: $showPlanSheet) {
            PlanSelectorSheet(
                onPurchased: {
                    showPlanSheet = false
                    onContinue()
                }
            )
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(AppColor.bg1)
        }
    }

    // MARK: - Top dismiss

    private var dismissBar: some View {
        HStack {
            Spacer()
            Button { onDismiss?() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.text40)
                    .padding(10)
            }
        }
        .padding(.top, 50)
        .padding(.trailing, 12)
    }

    // MARK: - Carousel

    private struct CarouselSlide: Identifiable {
        let id = UUID()
        let asset: String
        let headline: String
        let body: String
    }

    private let slides: [CarouselSlide] = [
        .init(
            asset: "paywall1",
            headline: "sınırsız\ncevap üret",
            body: "ekran görüntüsü at, 3 cevap çıksın. günlük limit yok."
        ),
        .init(
            asset: "paywall2",
            headline: "5 ton,\ntek tıkla",
            body: "flörtöz, esprili, direkt, sıcak, gizemli. her senaryoya uyan ses."
        ),
        .init(
            asset: "paywall3",
            headline: "tarzın saklı,\nsenin",
            body: "kalibrasyon ve örnek metnin sadece sende. ekranlar 24 saatte siliniyor."
        )
    ]

    private var carousel: some View {
        VStack(spacing: 14) {
            TabView(selection: $carouselIndex) {
                ForEach(slides.indices, id: \.self) { idx in
                    slideView(slides[idx])
                        .tag(idx)
                        .padding(.horizontal, 24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: carouselIndex)

            ProgressDots(total: slides.count, active: carouselIndex)
        }
    }

    @ViewBuilder
    private func slideView(_ s: CarouselSlide) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(s.asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 280)

            if let reason = lockReason, s.asset == "paywall1" {
                Text(reason.headline.trLower)
                    .font(AppFont.display(28, weight: .bold))
                    .tracking(-0.02 * 28)
                    .foregroundColor(.white)
            } else {
                Text(s.headline)
                    .font(AppFont.display(28, weight: .bold))
                    .tracking(-0.02 * 28)
                    .foregroundColor(.white)
                    .lineSpacing(28 * 0.05)
            }

            Text(s.body)
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .lineSpacing(14 * 0.4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Bottom CTA

    private var bottomBlock: some View {
        VStack(spacing: 10) {
            PrimaryButton("3 gün ücretsiz dene") {
                showPlanSheet = true
            }

            Button("ücretsiz devam et") {
                onContinue()
            }
            .font(AppFont.body(14))
            .foregroundColor(AppColor.text40)
            .padding(.top, 4)

            HStack(spacing: 18) {
                Button("geri yükle") { Task { await runRestore() } }
                Text("·").foregroundColor(AppColor.text20)
                Button("şartlar") { showTerms = true }
                Text("·").foregroundColor(AppColor.text20)
                Button("gizlilik") { showPrivacy = true }
            }
            .font(AppFont.body(11))
            .foregroundColor(AppColor.text40)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .sheet(isPresented: $showTerms) {
            LegalSheet(kind: .terms) { showTerms = false }
                .presentationBackground(AppColor.bg0)
        }
        .sheet(isPresented: $showPrivacy) {
            LegalSheet(kind: .privacy) { showPrivacy = false }
                .presentationBackground(AppColor.bg0)
        }
    }

    private func runRestore() async {
        let ok = await subs.restore()
        if ok { onContinue() }
    }

    /// Carousel auto-advance — `.task` ile bağlandığı için view disappear'da
    /// SwiftUI cancellation otomatik propagate olur. Önceden iç içe Task
    /// spawn edip handle'ı kaybediyordu (paywall kapansa da loop çalışmaya
    /// devam ediyordu).
    private func runCarouselTimer() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(6))
            } catch {
                return // cancellation
            }
            withAnimation(.easeInOut(duration: 0.35)) {
                carouselIndex = (carouselIndex + 1) % slides.count
            }
        }
    }
}

// MARK: - Plan selector sheet

/// Rizz-style alttan açılan plan sheet'i. Trial header + tek tier kart + CTA.
struct PlanSelectorSheet: View {
    let onPurchased: () -> Void

    @State private var subs = SubscriptionManager.shared
    @State private var purchasing = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("planını seç")
                    .font(AppFont.display(22, weight: .bold))
                    .tracking(-0.02 * 22)
                    .foregroundColor(.white)
                Text("3 gün ücretsiz, sonra istersen devam et.")
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text60)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            planCard

            VStack(spacing: 10) {
                PrimaryButton(
                    purchasing ? "..." : "ücretsiz başlat",
                    isEnabled: !purchasing
                ) {
                    Task { await runPurchase() }
                }

                if let error {
                    Text(error)
                        .font(AppFont.body(11))
                        .foregroundColor(AppColor.danger)
                        .multilineTextAlignment(.center)
                }

                Text("3 gün sonra haftalık \(weeklyPriceText), iptal etmezsen yenilenir. ayarlardan istediğin an iptal.")
                    .font(AppFont.body(10))
                    .foregroundColor(AppColor.text40)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10 * 0.4)
                    .padding(.horizontal, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var planCard: some View {
        VStack(spacing: 0) {
            // Trial badge — kart üstüne yapışık
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.bg0)
                Text("3 GÜN ÜCRETSİZ")
                    .font(AppFont.mono(10))
                    .tracking(0.06 * 10)
                    .foregroundColor(AppColor.bg0)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(AppColor.lime)

            // Plan body
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("haftalık")
                        .font(AppFont.body(16, weight: .bold))
                        .foregroundColor(.white)
                    Text("sınırsız cevap, tüm tonlar")
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(weeklyPriceText)
                        .font(AppFont.body(16, weight: .bold))
                        .foregroundColor(.white)
                    if let perDay = perDayText {
                        Text(perDay)
                            .font(AppFont.body(11))
                            .foregroundColor(AppColor.text40)
                    }
                }
            }
            .padding(14)
        }
        .background(AppColor.bg2.opacity(0.7))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.holographic.opacity(0.6), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var weeklyPriceText: String {
        subs.weeklyPackage?.storeProduct.localizedPriceString ?? "₺49 / hafta"
    }

    /// Günlük ekvivalent — "₺7 / gün" gibi UX için.
    private var perDayText: String? {
        guard let pkg = subs.weeklyPackage else { return "günlük ~₺7" }
        let price = pkg.storeProduct.price as Decimal
        let perDay = NSDecimalNumber(decimal: price / 7).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = pkg.storeProduct.priceFormatter?.locale ?? Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 1
        let str = formatter.string(from: NSNumber(value: perDay)) ?? ""
        return str.isEmpty ? nil : "günlük \(str)"
    }

    private func runPurchase() async {
        error = nil
        guard let pkg = subs.weeklyPackage else {
            error = "ödeme şu an kullanılamıyor. lütfen birazdan tekrar dene."
            return
        }
        purchasing = true
        let ok = await subs.purchase(pkg)
        purchasing = false
        if ok {
            onPurchased()
        } else {
            error = "ödeme tamamlanamadı veya iptal edildi."
        }
    }
}

#Preview("hard paywall") {
    PaywallView(onContinue: {})
        .background(AppColor.bg0)
        .preferredColorScheme(.dark)
}

#Preview("soft modal") {
    PaywallView(
        onContinue: {},
        onDismiss: {},
        lockReason: .dailyLimit
    )
    .background(AppColor.bg0)
    .preferredColorScheme(.dark)
}

#Preview("plan sheet") {
    PlanSelectorSheet(onPurchased: {})
        .background(AppColor.bg0)
        .preferredColorScheme(.dark)
}
