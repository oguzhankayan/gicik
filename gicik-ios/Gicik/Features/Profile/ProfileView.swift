import SwiftUI
import StoreKit
import UIKit
import UserNotifications

/// "sen" hub — eskiden Profile + Settings ayrıydı, kullanıcı iki tap atıyordu.
/// Birleştirildi (2026-04-30): topBar avatar/profil tap'i direkt buraya açar.
///
/// Iterasyon (2026-05-01, /impeccable critique):
/// - sıralama: archetype → son konuşmalar → premium kart → ayarlar (revenue
///   surface ortada).
/// - subscription card free user için tıklanır → upgrade pitch (önceden pasif).
/// - AI consent satırı chevron yerine status pill (visual lie düzeltildi).
/// - "verilerimi sil" mailto link (önceden static info satırı).
/// - destek + hesap kart yerine sade liste / standalone (identical-card-grid
///   önlendi).
/// - topBar chevron 44pt hit-target.
/// - decorative icon'lar VO hidden.
/// - asistan sesinden tek satır footer üstüne.
struct ProfileView: View {
    @Bindable var vm: HomeViewModel
    let onClose: () -> Void
    let onHowItWorks: () -> Void
    let onSignOut: () -> Void
    let onAIConsent: () -> Void
    let onRecalibrate: () -> Void
    let onUpgrade: () -> Void

    @State private var subs = SubscriptionManager.shared
    @State private var showingSignOutConfirm = false
    @State private var showingVoiceSample = false
    @State private var showingDeleteConfirm = false
    @State private var deletingAccount = false
    @State private var deleteError: String?
    @State private var notificationAuthorized: Bool = false

    /// AI consent durumunu UD'den oku — AIConsentView'ın yazdığı flag.
    @AppStorage(UDKey.aiConsentGiven.rawValue) private var aiConsentGiven: Bool = false

    /// iOS 16+ native review prompt — App Store URL yerine in-app heuristic.
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ZStack(alignment: .top) {
            CosmicBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    topBar
                    archetypeCard
                    historyBlock
                    subscriptionCard
                    personalSection
                    privacySection
                    supportInline
                    signOutButton
                    brandFooter
                    versionFooter
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("çıkmak istediğine emin misin?", isPresented: $showingSignOutConfirm) {
            Button("vazgeç", role: .cancel) {}
            Button("çıkış yap", role: .destructive) { onSignOut() }
        }
        .alert("hesabı silmek geri alınamaz", isPresented: $showingDeleteConfirm) {
            Button("vazgeç", role: .cancel) {}
            Button("sil", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("tüm konuşmaların, kalibrasyonun, abone bilgin silinir. apple ile tekrar giriş yapsan bile veriler dönmez.")
        }
        .alert("hesap silinemedi", isPresented: .constant(deleteError != nil)) {
            Button("tamam", role: .cancel) { deleteError = nil }
        } message: {
            Text(deleteError ?? "")
        }
        .sheet(isPresented: $showingVoiceSample) {
            VoiceSampleEditorView(onClose: { showingVoiceSample = false })
                .presentationBackground(AppColor.bg0)
        }
        .disabled(deletingAccount)
        .overlay {
            if deletingAccount {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView().tint(.white)
                        Text("hesap siliniyor")
                            .font(AppFont.body(13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
        }
    }

    /// delete-account edge function'ını çağır, sonra UD reset + signOut.
    /// Apple Guideline 5.1.1 — in-app account deletion.
    @MainActor
    private func deleteAccount() async {
        deletingAccount = true
        defer { deletingAccount = false }
        struct EmptyBody: Encodable {}
        struct EmptyResp: Decodable { let ok: Bool }
        do {
            _ = try await APIClient.shared.invokeJSON(
                .deleteAccount,
                body: nil as EmptyBody?,
                as: EmptyResp.self
            )
            // Local state temizle.
            UserDefaults.standard.set(false, .onboardingCompleted)
            UserDefaults.standard.set(false, .aiConsentGiven)
            UserDefaults.standard.set(false, .archetypeSpotlightSeen)
            await SubscriptionManager.shared.signOut()
            try? await AuthService.shared.signOut()
            // ProfileView sheet'i otomatik kapanır çünkü auth state'e bağlı
            // root yeniden render olur.
        } catch {
            deleteError = "silinemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { onClose() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("kapat")
            Spacer()
            Text("sen")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    // MARK: - Archetype card (hero)

    private var archetypeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                if let arch = vm.archetype {
                    Image(arch.iconAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .accessibilityHidden(true)
                } else {
                    Text("✨").font(.system(size: 32))
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("şu an")
                        .font(AppFont.mono(11))
                        .tracking(0.04 * 11)
                        .foregroundColor(AppColor.text40)
                    Text(archetypeFullLabel)
                        .font(AppFont.display(20, weight: .bold))
                        .tracking(-0.02 * 20)
                        .foregroundColor(.white)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(archetypeDescription, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("·")
                            .foregroundColor(AppColor.text40)
                            .accessibilityHidden(true)
                        Text(line)
                            .font(AppFont.body(13))
                            .foregroundColor(AppColor.text60)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.bg1.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(AppColor.holographic, lineWidth: 1)
                        .opacity(0.45)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("arketipin: \(archetypeFullLabel). \(archetypeDescription.joined(separator: ". "))")
    }

    // MARK: - History (hub'ın dibinde değil; archetype'ın altında)

    @ViewBuilder
    private var historyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("son konuşmalar")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)

            if vm.history.isEmpty {
                Text("henüz yok. olduğunda burada durur.")
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text40)
                    .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(vm.history.prefix(5)) { item in
                        historyRow(item)
                    }
                }
            }
        }
    }

    private func historyRow(_ item: ConversationHistoryItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(item.mode.label.trLower)
                .font(AppFont.body(12, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.snippet)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text60)
                    .lineLimit(2)
                Text(item.relativeTime)
                    .font(AppFont.mono(10))
                    .foregroundColor(AppColor.text40)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.4))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.mode.label.trLower), \(item.relativeTime), \(item.snippet)")
    }

    // MARK: - Subscription (state-aware, free=tıklanır)

    private var subscriptionCard: some View {
        Group {
            if subs.isActive {
                premiumActiveCard
            } else {
                premiumPitchCard
            }
        }
    }

    /// Aktif: holographic border + lime mühür. Tıklanmıyor (info).
    private var premiumActiveCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18))
                .foregroundColor(AppColor.lime)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("premium aktif")
                    .font(AppFont.body(14, weight: .medium))
                    .foregroundColor(.white)
                Text("sınırsız + tüm modlar")
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.holographic, lineWidth: 1)
                        .opacity(0.55)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("premium aktif, sınırsız ve tüm modlar açık")
    }

    /// Free: pink stroke + glow + chevron — tıklanır, paywall trigger.
    private var premiumPitchCard: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onUpgrade()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "lock")
                    .font(.system(size: 18))
                    .foregroundColor(AppColor.pink)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("premium'a geç")
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("günde \(EntitlementGate.freeDailyLimit) üretim, default 3-ton. sınırsız + tek-ton seçimi için yükselt.")
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.pink.opacity(0.8))
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColor.pink.opacity(0.45), lineWidth: 1.2)
                    )
                    .shadow(color: AppColor.pink.opacity(0.18), radius: 16, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("premium'a geç, sınırsız üretim")
    }

    // MARK: - Sections

    private var personalSection: some View {
        section("kişisel") {
            row(icon: "play.circle",
                title: "nasıl çalışır",
                subtitle: "14 saniyede ne yaptığımız.",
                chevron: true,
                action: onHowItWorks)
            divider
            row(icon: "person.text.rectangle",
                title: "kendi sesin",
                subtitle: "nasıl yazıyorsun, biz öğreniriz.",
                chevron: true) { showingVoiceSample = true }
            divider
            row(icon: "wand.and.stars.inverse",
                title: "kalibrasyonu yenile",
                subtitle: "9 soru, 90 saniye.",
                chevron: true,
                action: onRecalibrate)
            divider
            // Notification toggle — onboarding'de izin alındı, sonradan
            // değiştirme yolu yoktu. iOS'ta toggle kontrolü Settings.app
            // dışından mümkün değil; bu satır current state'i göstermek +
            // Ayarlar'a deeplink açmak için.
            notificationRow
        }
    }

    /// Bildirim durumu satırı — UNUserNotificationCenter'dan async oku,
    /// "açık/kapalı" pill ile göster, tap iOS Ayarlar'a deeplink.
    @ViewBuilder
    private var notificationRow: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "bell")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 24)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("bildirimler")
                        .font(AppFont.body(14))
                        .foregroundColor(.white.opacity(0.92))
                    Text("ayarlar'dan değiştir.")
                        .font(AppFont.body(11))
                        .foregroundColor(AppColor.text40)
                }
                Spacer()
                notificationStatusPill
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.text40)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .task { await refreshNotificationStatus() }
        .accessibilityLabel("bildirimler, durum: \(notificationStatusLabel). ayarlar'a git.")
    }

    @ViewBuilder
    private var notificationStatusPill: some View {
        let isOn = notificationAuthorized
        Text(isOn ? "açık" : "kapalı")
            .font(AppFont.mono(10))
            .tracking(0.04 * 10)
            .foregroundColor(isOn ? AppColor.lime : AppColor.text60)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((isOn ? AppColor.lime : AppColor.text40).opacity(0.12))
                    .overlay(
                        Capsule()
                            .strokeBorder((isOn ? AppColor.lime : AppColor.text40).opacity(0.35),
                                          lineWidth: 1)
                    )
            )
    }

    private var notificationStatusLabel: String {
        notificationAuthorized ? "açık" : "kapalı"
    }

    private func refreshNotificationStatus() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            notificationAuthorized = (s.authorizationStatus == .authorized
                                      || s.authorizationStatus == .provisional
                                      || s.authorizationStatus == .ephemeral)
        }
    }

    private var privacySection: some View {
        section("gizlilik") {
            // AI consent — chevron yerine status pill, visual truth.
            Button(action: onAIConsent) {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 24)
                        .accessibilityHidden(true)
                    Text("yapay zeka onayı")
                        .font(AppFont.body(14))
                        .foregroundColor(.white.opacity(0.92))
                    Spacer()
                    consentStatusPill
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("yapay zeka onayı, durum: \(aiConsentGiven ? "açık" : "kapalı"). yönet.")
            divider
            link(icon: "lock", title: "gizlilik politikası",
                 url: URL(string: "https://gicik.app/privacy"))
            divider
            link(icon: "doc.text", title: "kullanım şartları",
                 url: URL(string: "https://gicik.app/terms"))
            divider
            // Apple Guideline 5.1.1 — in-app account deletion zorunlu.
            // Tek tap → confirm alert → backend RPC → signOut + reset.
            row(icon: "trash", title: "hesabı sil",
                subtitle: "geri alınamaz",
                chevron: true) {
                showingDeleteConfirm = true
            }
        }
    }

    /// "destek" — kart şeklinde değil, sade satırlar (variety).
    private var supportInline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("destek")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
                .padding(.horizontal, 4)
            VStack(spacing: 0) {
                inlineLink(icon: "envelope", title: "destek e-postası",
                           url: URL(string: "mailto:support@gicik.app"))
                hairline
                inlineButton(icon: "star", title: "değerlendir") {
                    requestReview()
                }
            }
        }
    }

    /// "hesap" — standalone destructive button, section header'sız.
    private var signOutButton: some View {
        Button { showingSignOutConfirm = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.danger)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                Text("çıkış yap")
                    .font(AppFont.body(15))
                    .foregroundColor(AppColor.danger)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(AppColor.danger.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .accessibilityLabel("çıkış yap")
    }

    // MARK: - Brand voice line + version

    /// Asistan sesinden tek satır — "bu da bir ayar ekranı ama gıcık'ın".
    /// Aktif arketipe göre değişen kuru kapanış.
    private var brandFooter: some View {
        Text(brandLine)
            .font(AppFont.body(12))
            .italic()
            .foregroundColor(AppColor.text40)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .padding(.top, 14)
    }

    private var brandLine: String {
        switch vm.archetype {
        case .dryroaster:           return "ayar yapma. yaşa."
        case .observer:              return "burada her ayar bir gözlem."
        case .softie_with_edges:     return "gerekirse kapatırsın. burada durur."
        case .chaos_agent:           return "ayar değil, şimdi nereye bakıyorsun."
        case .strategist:            return "doğru düğme yok, sadece doğru sıra."
        case .romantic_pessimist:    return "ayar bittiği yerde başka bir şey başlar."
        default:                     return "buradan çıkmadan önce, kafanı bul."
        }
    }

    private var versionFooter: some View {
        Text("gıcık v\(Configuration.appVersion) (\(Configuration.buildNumber)) · \(Configuration.bundleID)")
            .font(AppFont.mono(10))
            .foregroundColor(AppColor.text40)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }

    // MARK: - Section helpers

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColor.text05)
            .frame(height: 1)
            .padding(.leading, 54) // ikon offset'i kadar
            .accessibilityHidden(true)
    }

    private var hairline: some View {
        Rectangle()
            .fill(AppColor.text05)
            .frame(height: 1)
            .padding(.horizontal, 16)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func row(
        icon: String,
        title: String,
        subtitle: String? = nil,
        chevron: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button { action?() } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 24)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.body(14))
                        .foregroundColor(.white.opacity(0.92))
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.body(11))
                            .foregroundColor(AppColor.text40)
                    }
                }
                Spacer()
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.text40)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }

    @ViewBuilder
    private func link(icon: String, title: String, url: URL?) -> some View {
        if let url {
            Link(destination: url) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 24)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(AppFont.body(14))
                        .foregroundColor(.white.opacity(0.92))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.text40)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    @ViewBuilder
    private func inlineLink(icon: String, title: String, url: URL?) -> some View {
        if let url {
            Link(destination: url) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.text60)
                        .frame(width: 22)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(AppFont.body(13))
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private func inlineButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 22)
                    .accessibilityHidden(true)
                Text(title)
                    .font(AppFont.body(13))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - AI consent status pill

    private var consentStatusPill: some View {
        let isOn = aiConsentGiven
        return Text(isOn ? "açık" : "kapalı")
            .font(AppFont.mono(10))
            .tracking(0.04 * 10)
            .foregroundColor(isOn ? AppColor.lime : AppColor.text60)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((isOn ? AppColor.lime : AppColor.text40).opacity(0.12))
                    .overlay(
                        Capsule()
                            .strokeBorder((isOn ? AppColor.lime : AppColor.text40).opacity(0.35),
                                          lineWidth: 1)
                    )
            )
    }

    // MARK: - Computed

    private var archetypeFullLabel: String {
        guard let a = vm.archetype else { return "kalibrasyon yok" }
        return a.label.trLower
    }

    private var archetypeDescription: [String] {
        vm.archetype?.description ?? []
    }
}
