import SwiftUI
import UIKit

/// Main shell — avatar + logo, primary "cevap" hero, 3 secondary mode rows,
/// history scroll (history boşsa hiç gözükmez).
struct HomeView: View {
    @State private var vm = HomeViewModel()
    @State private var showArchetypeSwitcher = false
    @State private var showProfile = false
    @State private var showHowItWorks = false
    @State private var paywallReason: EntitlementGate.LockReason?
    @State private var subs = SubscriptionManager.shared
    /// AI consent revoke akışı — ProfileView'dan tetiklenir; onaylanırsa
    /// UD flag temizlenir + signOut. Veri silme support üzerinden (manuel).
    @State private var showingAIConsentRevoke = false
    /// Kalibrasyonu yenile akışı — onboardingCompleted false yapılır, signOut
    /// + RootView yeniden onboarding'e döner. Mevcut kalibrasyonun korunması
    /// Phase 7+; MVP'de "yenileme = baştan"un dürüst karşılığı.
    @State private var showingRecalibrate = false
    /// Tek-seferlik archetype spotlight overlay — first home view'da
    /// kullanıcıya sol üst avatar'ın "tarz değiştir" işlevini gösterir.
    /// UD flag dismiss'te yazılır, bir daha açılmaz.
    @AppStorage(UDKey.archetypeSpotlightSeen.rawValue) private var archetypeSpotlightSeen: Bool = false
    @State private var showArchetypeSpotlight: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            switch vm.stage {
            case .home:
                homeContent
            case .picker(let mode):
                if mode == .tonla {
                    TonlaDraftView(vm: vm)
                } else if vm.isManualMode {
                    if mode == .acilis {
                        ManualProfileEntryView(vm: vm)
                    } else {
                        ManualChatComposerView(vm: vm, mode: mode)
                    }
                } else {
                    ScreenshotPickerView(vm: vm, mode: mode)
                }
            case .generation(let mode):
                GenerationView(vm: vm, mode: mode)
            case .result(let result):
                ResultView(vm: vm, result: result)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppAnimation.standard, value: stageKey)
        // Paywall sheet ROOT level — generation/result stage'inden de tetiklenmeli.
        // Önceden homeContent içindeydi, sadece home stage'de iken çalışıyordu.
        .sheet(item: $paywallReason) { reason in
            PaywallView(
                onContinue: { paywallReason = nil },
                onDismiss: { paywallReason = nil },
                lockReason: reason
            )
            .presentationBackground(AppColor.bg0)
        }
        .onChange(of: vm.paywallTrigger) { _, new in
            if let new {
                paywallReason = new
                vm.paywallTrigger = nil
            }
        }
        .alert("yapay zeka onayını geri çek?", isPresented: $showingAIConsentRevoke) {
            Button("vazgeç", role: .cancel) {}
            Button("geri çek", role: .destructive) {
                // Zombie state önle: onboardingCompleted'ı da kaldır.
                // Aksi halde tekrar girişte HomeView açılır ama AI
                // consent kapalı, LLM call'ları sessizce fail eder.
                // Bu yapı: revoke → re-onboard → consent step'inde tekrar
                // onay gerek (veya iptal → çıkış).
                UserDefaults.standard.set(false, .aiConsentGiven)
                UserDefaults.standard.set(false, .onboardingCompleted)
                Task {
                    await SubscriptionManager.shared.signOut()
                    try? await AuthService.shared.signOut()
                }
            }
        } message: {
            Text("bu olmadan uygulama çalışamaz. çıkış yapılacak. verilerinin silinmesi için support@gicik.app ile iletişime geç.")
        }
        .alert("kalibrasyonu yeniden mi ölçelim?", isPresented: $showingRecalibrate) {
            Button("vazgeç", role: .cancel) {}
            Button("yenile", role: .destructive) {
                UserDefaults.standard.set(false, .onboardingCompleted)
                Task {
                    await SubscriptionManager.shared.signOut()
                    try? await AuthService.shared.signOut()
                }
            }
        } message: {
            Text("9 sorudan oluşan kalibrasyon yeniden başlar. mevcut arketip silinir.")
        }
        // First-launch tek-seferlik spotlight: sol-üst avatar'ın "tarz
        // değiştir" işlevini gösterir. Sadece home stage'inde, henüz
        // görmemiş kullanıcıda. Hesaplama: topBar leading 24 + avatar
        // çapı 36 → ortası (24+18, 58+18+22) safe-area top sonrası.
        // SafeArea zaten topBar 58pt push eder; geometry içinde
        // hesaplandığı için sabit değer iyi yaklaşım.
        .overlay {
            if showArchetypeSpotlight {
                SpotlightOverlay(
                    targetCenter: CGPoint(x: 24 + 22, y: 58 + 22 + safeAreaTopInset),
                    targetRadius: 22,
                    title: "tarzını buradan değiştir",
                    subtitle: "istediğin zaman sol-üst avatara dokun, başka bir arketipe geç.",
                    isPresented: $showArchetypeSpotlight,
                    onDismiss: { archetypeSpotlightSeen = true }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            // İlk home render'ında, eğer daha önce görülmediyse, kısa
            // gecikme ile spotlight aç. Gecikme: kullanıcı sayfayı
            // önce kavrasın, sonra dikkati buraya çekelim.
            if !archetypeSpotlightSeen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if !archetypeSpotlightSeen {
                        showArchetypeSpotlight = true
                    }
                }
            }
        }
    }

    /// Cihaz safe-area top inset — spotlight target koordinatı için.
    /// SwiftUI'da window inset'e direkt erişim çıkardığı için UIWindowScene
    /// üzerinden bir kez okur, default 47pt (iPhone 14+ Dynamic Island).
    private var safeAreaTopInset: CGFloat {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }.first
        return scene?.windows.first?.safeAreaInsets.top ?? 47
    }

    private var stageKey: String {
        switch vm.stage {
        case .home: "home"
        case .picker(let m): "picker-\(m.rawValue)"
        case .generation(let m): "gen-\(m.rawValue)"
        case .result: "result"
        }
    }

    // MARK: - Home content

    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            // Vertical rhythm AppSpacing scale'inde (8/16/24/32/48). 36/18/28
            // off-scale değerlerdi; göze farklı gelmiyor ama design tokens
            // disiplini polish'in koşulu (impeccable).
            VStack(spacing: 0) {
                topBar
                primaryMode.padding(.top, AppSpacing.xl)            // 32
                secondaryModes.padding(.top, AppSpacing.md)         // 16
                if vm.history.isEmpty {
                    emptyHistoryHint.padding(.top, AppSpacing.xl)
                } else {
                    // Stats chip yalnızca bu hafta üretim varsa.
                    // Öncesi: history boş olsa da değil, weekCount=0 olsa
                    // "0 cevap" + "en çok cevap modu" görünüyordu — boş, anlamsız.
                    let stats = computeHomeStats()
                    if stats.weekCount > 0 {
                        // 32→24: kart kalktığı için breathing room küçülebilir.
                        statsChip.padding(.top, AppSpacing.lg)
                    }
                    historySection.padding(.top, AppSpacing.md)
                }
                Spacer(minLength: AppSpacing.xl)                    // 32
            }
        }
        .sheet(isPresented: $showArchetypeSwitcher) {
            ArchetypeSwitcherSheet(vm: vm)
                .presentationDetents([.large])
                .presentationBackground(AppColor.bg0)
        }
        .sheet(isPresented: $showHowItWorks) {
            HowItWorksView(onClose: { showHowItWorks = false })
                .presentationBackground(AppColor.bg0)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(
                vm: vm,
                onClose: { showProfile = false },
                onHowItWorks: {
                    showProfile = false
                    // Profile sheet kapanırken stack'i kirletmemek için kısa
                    // delay'le HowItWorks aç. Aksi halde iki sheet üst üste gelir.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        showHowItWorks = true
                    }
                },
                onSignOut: {
                    showProfile = false
                    Task {
                        await SubscriptionManager.shared.signOut()
                        try? await AuthService.shared.signOut()
                    }
                },
                onAIConsent: {
                    showProfile = false
                    // Sheet kapanma animasyonu sonrası alert'i tetikle.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        showingAIConsentRevoke = true
                    }
                },
                onRecalibrate: {
                    showProfile = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        showingRecalibrate = true
                    }
                },
                onUpgrade: {
                    // Sheet kapansın, kısa gecikme ile paywall sheet açılsın.
                    // Aynı anda iki sheet sunulamaz.
                    showProfile = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        paywallReason = .userInitiated
                    }
                }
            )
            .presentationBackground(AppColor.bg0)
        }
    }

    private var topBar: some View {
        HStack {
            // Arketip avatarı — tap ile tarz değiştirme sheet'i açılır.
            // Holographic stroke yalnızca burada kalır (calibration reveal'in homepage izi).
            Button { showArchetypeSwitcher = true } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.bg2.opacity(0.7))
                    Circle()
                        .strokeBorder(AppColor.holographic, lineWidth: 1)
                    if let arch = vm.archetype {
                        Image(arch.iconAssetName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(4)
                            .accessibilityHidden(true)
                    } else {
                        Text("✨").font(.system(size: 18))
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: 36, height: 36)
                .frame(width: 44, height: 44)   // hit-target 44, görsel 36
                .contentShape(Rectangle())
            }
            .accessibilityLabel("tarz değiştir, şu an \(archetypeShortLabel)")

            Spacer()
            Logo(size: 26)
            Spacer()

            Button { showProfile = true } label: {
                // person.crop.circle → slider.horizontal.3: avatar zaten
                // "sen" sinyalini taşıyor; sağ ikonun "ayar" anlamı net
                // olsun. Semantic ayrım net + universal settings glyph.
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("ayarlar")
        }
        .padding(.horizontal, 24)
        .padding(.top, 58)
    }

    // MARK: - Primary mode (cevap)

    /// Trafiğin %80'i buraya gidecek — 4-eşit-grid yerine ana CTA olarak öne çıkar.
    /// Holographic stroke sadece bu kartta kalır; secondary'ler düz neutral.
    ///
    /// Hero CTA: lime "başla →" pill bottom-left. Subtitle zaten "üç cevap dön"
    /// diyor — value claim copy'de, ek visual preview gereksiz çıktı (denedik,
    /// kullanıcı feedback "skeleton/design hatası gibi"). Şu an minimal:
    /// icon + title + subtitle + CTA, holographic border ile brand imzası.
    private var primaryMode: some View {
        Button { tryEnterMode(.cevap) } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: Mode.cevap.systemIcon)
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(.white.opacity(0.85))
                        .accessibilityHidden(true)
                    Spacer(minLength: 0)
                    heroStatusPill
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text("cevap")
                        .font(AppFont.display(32, weight: .bold))
                        .tracking(-0.02 * 32)
                        .foregroundColor(.white)
                    Text("ss yükle, üç cevap çıkar.")
                        .font(AppFont.body(13))
                        .foregroundColor(AppColor.text60)
                }

                HStack(spacing: 6) {
                    Text("başla")
                        .font(AppFont.body(12, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppColor.bg0)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(AppColor.lime))
                .padding(.top, 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            // minHeight: Dynamic Type'da subtitle taşmasın diye sabit
            // height bırakıldı. 200 görsel zemin, içerik gerekirse büyür.
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColor.bg1.opacity(0.7))
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(AppColor.holographic, lineWidth: 1)
                        .opacity(0.55)
                }
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .sensoryFeedback(.impact(weight: .light), trigger: vm.stage)
        .accessibilityLabel("cevap modu, ekran görüntüsü ver üç cevap dön, başla")
    }

    /// Hero kartının sağ-üstünde status pill — premium mühür veya free
    /// kalan kullanım. İki amaç tek pill'de: (1) hero üst yarısı boş
    /// görünmesin, (2) free user evden çıkmadan kalan hakkını görsün.
    @ViewBuilder
    private var heroStatusPill: some View {
        if subs.isActive {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .accessibilityHidden(true)
                Text("premium")
                    .font(AppFont.mono(10))
                    .tracking(0.04 * 10)
            }
            .foregroundColor(AppColor.lime)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(AppColor.lime.opacity(0.12))
                    .overlay(Capsule().strokeBorder(AppColor.lime.opacity(0.35), lineWidth: 1))
            )
            .accessibilityLabel("premium aktif")
        } else if !vm.historyLoadedOnce && vm.remainingToday == nil {
            // Cold-launch'ta history + server-truth gelmediyse chip
            // yalan söylemesin (0/3 + 402 senaryosu). Belirsiz state.
            EmptyView()
        } else {
            // Server-truth (vm.remainingToday) önceliklidir; yoksa lokal
            // history'den hesap. remainingToday her başarılı üretim sonrası
            // güncellenir (generate-replies done event).
            let cap = EntitlementGate.freeDailyLimit
            let usedToday: Int = {
                if let remaining = vm.remainingToday {
                    return cap - remaining
                }
                return vm.history.filter { Calendar.current.isDateInToday($0.createdAt) }.count
            }()
            let remaining = max(0, cap - usedToday)
            let isLow = remaining == 0
            HStack(spacing: 4) {
                Image(systemName: isLow ? "lock.fill" : "bolt.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .accessibilityHidden(true)
                Text("\(min(usedToday, cap))/\(cap) bugün")
                    .font(AppFont.mono(10))
                    .tracking(0.04 * 10)
            }
            .foregroundColor(isLow ? AppColor.warning : AppColor.text60)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((isLow ? AppColor.warning : AppColor.text40).opacity(0.10))
                    .overlay(
                        Capsule().strokeBorder(
                            (isLow ? AppColor.warning : AppColor.text20).opacity(0.4),
                            lineWidth: 1
                        )
                    )
            )
            .accessibilityLabel("bugün \(usedToday) cevap üretildi, sınır \(cap)")
        }
    }

    // MARK: - Secondary modes (açılış / tonla / davet)

    /// Kompakt liste — primary cevap kartının altında inline. Aynı affordance
    /// (kart) ama görsel ağırlık çok daha düşük, hiyerarşi net.
    private var secondaryModes: some View {
        VStack(spacing: 8) {
            ForEach(secondaryList, id: \.rawValue) { mode in
                Button { tryEnterMode(mode) } label: {
                    HStack(spacing: 14) {
                        // Restrained strategy: secondary list'te üç mode
                        // ikonu da tek tonda (text60). Cevap (primary)
                        // holographic'i taşıyor; secondary'de renk swatch'ı
                        // hiyerarşi değil gürültü üretiyordu. Glance'la
                        // ayrım ikon karakteri + sıralama + label ile.
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppColor.bg2.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(AppColor.text05, lineWidth: 1)
                                )
                            Image(systemName: mode.systemIcon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(mode.label.trLower)
                                .font(AppFont.body(15, weight: .medium))
                                .foregroundColor(.white)
                            Text(mode.subtitle)
                                .font(AppFont.body(12))
                                .foregroundColor(AppColor.text40)
                        }
                        Spacer()
                        // Mode kilidi kaldırıldı (2026-05-01) — tüm modlar
                        // her tier'a açık. lock.fill render artık gerekmez.
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.text40)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColor.bg1.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(AppColor.text05, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    /// Sıra niyet sırasıyla: yeni eşleşme (açılış) → taslağı tonla → ileri (davet).
    private var secondaryList: [Mode] { [.acilis, .tonla, .davet] }

    /// Mode tıklaması: entitlement gate kontrolü, kilitli ise paywall sheet.
    private func tryEnterMode(_ mode: Mode) {
        if !EntitlementGate.canUseMode(mode, isPremium: subs.isActive) {
            paywallReason = .modeLocked(mode)
            return
        }
        vm.selectMode(mode)
    }

    // MARK: - Stats chip (kişisel veri özeti)

    /// Marka karakterli mini özet — tek blok, üst üste 2 satır.
    /// Üst: bu hafta toplam (display sayı + cevap kelimesi)
    /// Alt: anlamlı yan-bilgi cümlesi ("en çok cevap modu" / "3 gün üst üste").
    /// Hero-metric template (büyük "19 cevap") absolute ban'ı — kaldırıldı.
    /// Yerine: tek satır asistan-sesi gözlem, ortalama bir hairline divider
    /// + italic. "Sayma" değil "fark etme" hissi. Brand "iletişim koçu"
    /// pozisyonuyla uyumlu.
    @ViewBuilder
    private var statsChip: some View {
        let stats = computeHomeStats()
        let line = statsObservationLine(stats: stats)
        if let line {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppColor.text05)
                    .frame(height: 1)
                    .accessibilityHidden(true)
                HStack(spacing: 8) {
                    if stats.streakDays >= 3 {
                        Circle()
                            .fill(AppColor.lime)
                            .frame(width: 5, height: 5)
                            .accessibilityHidden(true)
                    }
                    Text(line)
                        .font(AppFont.body(12))
                        .italic()
                        .foregroundColor(AppColor.text60)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 14)
            }
            .padding(.horizontal, AppSpacing.lg)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(line)
        }
    }

    /// Stats'tan asistan-sesi tek cümlelik gözlem üret. Sayı ön planda
    /// değil; davranış öne çıkar.
    private func statsObservationLine(stats: HomeStats) -> String? {
        guard stats.weekCount > 0 else { return nil }
        if stats.streakDays >= 3 {
            // En güçlü sinyal — streak'i öne çıkar.
            return "\(stats.streakDays) gün üst üste denedin. devam."
        }
        // 2+ cevap varsa secondaryLine zaten "en çok X modu" diyor;
        // onu sayıyla beraber tek doğal cümlede topla.
        if let secondary = stats.secondaryLine {
            // "en çok cevap modu" → "cevap ağırlıklı." (kısa, brand-voice)
            let cleaned = secondary
                .replacingOccurrences(of: "en çok ", with: "")
                .replacingOccurrences(of: " modu", with: " ağırlıklı")
            return "bu hafta \(stats.weekCount) cevap. \(cleaned)."
        }
        // Tek cevap — özet değil, davet.
        return stats.weekCount == 1 ? "ilk cevabını verdin." : "bu hafta \(stats.weekCount) cevap."
    }

    /// History boş iken minimal hint — marka sesinin imzasıyla.
    /// mono-10 caps label + lowercase asistan-voice satır (period bitir).
    /// Generic "empty state" olmasın; "yeni kullanıcının ilk hissi" olsun.
    private var emptyHistoryHint: some View {
        VStack(spacing: 10) {
            Text("henüz boş")
                .font(AppFont.mono(10))
                .tracking(0.06 * 10)
                .foregroundColor(AppColor.text40)
            Text("ilk ss'i ver, başlayalım.")
                .font(AppFont.body(13))
                .italic()
                .foregroundColor(AppColor.text60)

            // First-session asistanı: 14s loop animasyon, "nasıl çalışıyor"
            // sorusunu soran kullanıcı için. Replay anytime — ProfileView'dan da.
            Button {
                showHowItWorks = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 12))
                    Text("nasıl çalışıyor")
                        .font(AppFont.mono(11))
                        .tracking(0.04 * 11)
                }
                .foregroundColor(AppColor.text60)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().strokeBorder(AppColor.text10, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .accessibilityHint("14 saniyelik animasyonu açar")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - History (kompakt 2-up grid + "tümü" CTA)

    /// Eskiden 8 kart dikey yığılırdı, ana ekranı kocaman yapıyordu.
    /// Artık 2 kart yan yana özet + "tümü" link → ProfileView'in tam history'sine.
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("son")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)
                Spacer()
                if vm.history.count > 2 {
                    Button {
                        showProfile = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("tümü")
                                .font(AppFont.mono(11))
                                .tracking(0.04 * 11)
                                .foregroundColor(AppColor.text60)
                            Text("(\(vm.history.count))")
                                .font(AppFont.mono(10))
                                .foregroundColor(AppColor.text40)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppColor.text40)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("tüm konuşmalar, \(vm.history.count) kayıt")
                }
            }
            .padding(.horizontal, 24)

            HStack(alignment: .top, spacing: 10) {
                ForEach(vm.history.prefix(2)) { item in
                    historyTile(item)
                }
                // Tek kayıt varsa sağdaki slot'u boş Spacer ile dengele,
                // tek kart ekran ortasında değil sola tutsun.
                if vm.history.count == 1 {
                    Color.clear.frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    /// Kompakt yatay tile — kare yakını, tek satır mode + 2 satır snippet.
    /// Phase 5'e kadar replay yok; bu yüzden Button değil static card.
    /// Önceden Button + haptic-only idi (yalan affordance), commit c3b7656
    /// "kill dead-tap" direktifi gereği static'e çevrildi.
    private func historyTile(_ item: ConversationHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: item.mode.systemIcon)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColor.text60)
                    .accessibilityHidden(true)
                Text(item.mode.label.trLower)
                    .font(AppFont.body(12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer(minLength: 0)
                Text(item.relativeTime)
                    .font(AppFont.mono(9))
                    .tracking(0.04 * 9)
                    .foregroundColor(AppColor.text40)
            }
            Text(item.snippet)
                .font(AppFont.body(11))
                .foregroundColor(AppColor.text60)
                .lineSpacing(11 * 0.35)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.mode.label.trLower), \(item.relativeTime), \(item.snippet)")
    }

    // MARK: - Stats helpers

    private struct HomeStats {
        let weekCount: Int
        /// 3+ olunca lime streak noktası görünür.
        let streakDays: Int
        /// "en çok cevap modu" / "3 gün üst üste" / "günde 2 cevap" gibi.
        /// Anlamsız (tek veri / boş) durumlarda nil — UI satırı gizler.
        let secondaryLine: String?
    }

    /// vm.history üzerinden son 7 günün özetini çıkar.
    /// Secondary line öncelikli sıralama:
    ///   1. streak ≥ 3 → "{n} gün üst üste" (en güçlü engagement sinyali)
    ///   2. mode çeşitliliği varsa → "en çok {mode} modu"
    ///   3. yoksa nil
    private func computeHomeStats() -> HomeStats {
        let cal = Calendar.current
        let now = Date()
        let weekAgo = now.addingTimeInterval(-7 * 86400)
        let weekItems = vm.history.filter { $0.createdAt >= weekAgo }
        let count = weekItems.count

        // Streak — bugünden geriye, ardışık günler.
        let activeDays: Set<DateComponents> = Set(vm.history.map {
            cal.dateComponents([.year, .month, .day], from: $0.createdAt)
        })
        var streak = 0
        var cursor = now
        while true {
            let comps = cal.dateComponents([.year, .month, .day], from: cursor)
            if activeDays.contains(comps) {
                streak += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
        }

        // Mode dağılımı
        var modeCounts: [Mode: Int] = [:]
        for it in weekItems { modeCounts[it.mode, default: 0] += 1 }
        let topMode = modeCounts.max { $0.value < $1.value }?.key

        // Secondary line seçimi (priority order)
        let secondary: String?
        if streak >= 3 {
            secondary = "\(streak) gün üst üste"
        } else if count >= 2, let top = topMode {
            secondary = "en çok \(top.label.trLower) modu"
        } else {
            secondary = nil
        }

        return HomeStats(
            weekCount: count,
            streakDays: streak,
            secondaryLine: secondary
        )
    }

    // MARK: - Computed

    private var archetypeEmoji: String {
        guard let archetype = vm.archetype else { return "✨" }
        return String(archetype.label.first ?? "✨")
    }

    private var archetypeShortLabel: String {
        guard let archetype = vm.archetype else { return "" }
        let parts = archetype.label.split(separator: " ", maxSplits: 1)
        return (parts.last.map(String.init) ?? "").trLower
    }
}

#Preview {
    HomeView()
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}

