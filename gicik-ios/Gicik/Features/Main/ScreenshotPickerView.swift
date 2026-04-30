import SwiftUI
import PhotosUI
import UIKit

/// Screenshot picker — 3 state: empty, uploading (shimmer overlay),
/// done (full-fit preview + holographic border + checkmark + tone selector).
///
/// Empty-state redesign (2026-04-29):
/// - Top bar: 44pt back chevron + centered mode label + daily-limit chip
/// - Hero: PhotoKit smartAlbumScreenshots'tan **son 6 ekran görüntüsü** strip.
///   İzin akışı opt-in: kullanıcı "izin ver" chip'ine tıklamadıkça photos
///   library'ye dokunmuyoruz. Privacy-respectful.
/// - Primary CTA: bottom'da büyük PhotosPicker button (iOS konvansiyonu)
/// - Secondary: panoda image varsa "panodan yapıştır" chip
/// - Educational ghost: alt yarıda örnek konuşma preview'i, kullanıcıya
///   "ne tür ss istiyoruz"u görsel olarak öğretir + ölü alanı doldurur.
/// - Footer: clean privacy line, false-affordance ⓘ ikonu kaldırıldı.
struct ScreenshotPickerView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    @State private var recents = RecentScreenshotsLoader()
    @State private var clipboardHasImage: Bool = false
    @State private var extraContextOpen: Bool = false
    @FocusState private var extraContextFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    contentArea
                        .padding(.top, 24)
                    privacyHint
                        .padding(.top, 18)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("bitti") { extraContextFocused = false }
            }
        }
        .onAppear {
            recents.bootstrap()
            refreshClipboard()
        }
        // Foreground'a dönünce panoyu tekrar kontrol et — kullanıcı arada
        // başka uygulamadan ss kopyalamış olabilir.
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )) { _ in
            refreshClipboard()
        }
    }

    // MARK: - TopBar

    /// Geri + mode label + daily-limit chip. 44pt min-tap, iOS HIG.
    private var topBar: some View {
        HStack(spacing: 12) {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("geri")

            Spacer(minLength: 0)

            Text("\(mode.label.trLower) modu")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))

            Spacer(minLength: 0)

            dailyLimitChip
                .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    /// "bugün X/3" — free tier transparency. Free olmayanlarda gizlenir.
    /// Phase 2 — frontend history-based count; Phase 4'te SubscriptionManager
    /// entitlement check'i ile birlikte premium'da gizlenecek.
    private var dailyLimitChip: some View {
        let usedToday = vm.history.filter {
            Calendar.current.isDateInToday($0.createdAt)
        }.count
        let cap = 3
        let display = "bugün \(min(usedToday, cap))/\(cap)"
        return Text(display)
            .font(AppFont.mono(10))
            .tracking(0.04 * 10)
            .foregroundColor(usedToday >= cap ? AppColor.warning : AppColor.text60)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(AppColor.bg1.opacity(0.6)))
            .overlay(Capsule().strokeBorder(AppColor.text05, lineWidth: 1))
            .accessibilityLabel("bugün \(usedToday) cevap üretildi, sınır \(cap)")
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mode.pickerHeadline)
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
                .lineSpacing(22 * 0.08)
                .fixedSize(horizontal: false, vertical: true)

            Text(mode.pickerSubline)
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .lineSpacing(14 * 0.40)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content router

    @ViewBuilder
    private var contentArea: some View {
        switch vm.pickerState {
        case .empty:
            emptyState
        case .uploading:
            uploadingState
        case .done(let data):
            doneState(thumbnail: data)
        }
    }

    // MARK: - EMPTY (the redesigned hero)

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 22) {
            recentsBlock
            actionsBlock
            samplePreview
        }
    }

    // ───── Recents strip ─────

    @ViewBuilder
    private var recentsBlock: some View {
        switch recents.state {
        case .idle, .loading:
            recentsSkeleton
        case .needsPermission:
            permissionPrompt
        case .ready(let items):
            recentsStrip(items: items)
        case .denied:
            // Daha önce dismiss yerine EmptyView idi; kullanıcı'nın
            // recovery yolu yoktu. Şimdi iOS Ayarlar'a deeplink veriyoruz.
            deniedPermissionRecovery
        case .empty:
            // Photos library boş — strip gizlenir, CTA + sample yeter.
            EmptyView()
        }
    }

    /// PhotoKit izni reddedildiğinde kullanıcıya iOS Ayarlar'a hızlı yol.
    /// "fotoğraflardan seç" CTA'sı zaten ayrı affordance, bu sadece son
    /// ss'leri göstermek için izin tekrar açma yolunu sunar.
    private var deniedPermissionRecovery: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "lock.open")
                        .font(.system(size: 16))
                        .foregroundColor(AppColor.text60)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("fotoğraf erişimi kapalı")
                            .font(AppFont.body(14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Text("son ss'lerini görmek için iOS ayarlardan aç.")
                            .font(AppFont.body(11))
                            .foregroundColor(AppColor.text40)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.text40)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColor.bg1.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppColor.text10, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("ayarlar'a git, fotoğraf erişimini aç")
        }
    }

    private var sectionLabel: some View {
        Text("son ekran görüntülerin")
            .font(AppFont.mono(11))
            .tracking(0.04 * 11)
            .foregroundColor(AppColor.text40)
    }

    private var recentsSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.bg1)
                            .frame(width: 88, height: 124)
                    }
                }
            }
        }
    }

    private var permissionPrompt: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel
            Button {
                recents.requestPermission()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AppColor.lime)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("son ss'lerini buraya getir")
                            .font(AppFont.body(14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Text("tek tıkla seçim. izin ver yeter.")
                            .font(AppFont.body(12))
                            .foregroundColor(AppColor.text40)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColor.text40)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColor.bg1.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppColor.lime.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func recentsStrip(items: [RecentScreenshotsLoader.Item]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items) { item in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            Task {
                                if let data = await recents.loadFullData(for: item.asset) {
                                    vm.acceptScreenshotData(data)
                                }
                            }
                        } label: {
                            // scaledToFill + frame yalnızca clipShape kullanırsa
                            // hit-test asıl (taşan) image boyutunu görüyor; her
                            // thumbnail kendi sağındaki komşunun hit alanını
                            // ezerek sadece en sağdakini tappable bırakıyordu.
                            // Fix: önce frame içine sığacak şekilde clipped(),
                            // sonra contentShape ile hit alanını 88×124'e
                            // sabitle.
                            Image(uiImage: item.thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 124)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(AppColor.text10, lineWidth: 1)
                                )
                                .accessibilityLabel("son ekran görüntüsü, seçmek için tıkla")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()
        }
    }

    // ───── Actions ─────

    private var actionsBlock: some View {
        VStack(spacing: 10) {
            primaryPickerButton
            if clipboardHasImage {
                pasteChip
                    .transition(.opacity)
            }
            manualEntryChip
        }
    }

    /// "elle yaz" — ekran görüntüsü atmadan konuşmayı/profili elle kurma.
    /// Mode'a göre ManualChatComposerView veya ManualProfileEntryView'e geçer.
    /// Picker stage korunur; vm.isManualMode true olunca HomeView routes.
    private var manualEntryChip: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            vm.isManualMode = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColor.lime)
                    .accessibilityHidden(true)
                Text(mode == .acilis ? "elle yaz · profili sen tarif et" : "elle yaz · konuşmayı sen kur")
                    .font(AppFont.body(14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.text40)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColor.lime.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode == .acilis
            ? "elle profil yaz, ekran görüntüsüz"
            : "elle konuşma yaz, ekran görüntüsüz")
    }

    /// iOS-native PhotosPicker, primary CTA olarak. Dashed kutu yerine
    /// glass card + photo iconography. Asistan sesinde lowercase label.
    private var primaryPickerButton: some View {
        PhotosPicker(
            selection: $vm.pickedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                Text("fotoğraflardan seç")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .fill(AppColor.bg2)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                            .strokeBorder(AppColor.pink.opacity(0.35), lineWidth: 1.2)
                    )
                    .shadow(color: AppColor.purpleGlow, radius: 22, x: 0, y: 6)
            )
        }
        .accessibilityLabel("fotoğraflardan ekran görüntüsü seç")
    }

    /// Panoda image varsa görünür. Tap → image data → uploading flow.
    private var pasteChip: some View {
        Button {
            handlePaste()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColor.lime)
                Text("panodan yapıştır")
                    .font(AppFont.body(14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColor.text10, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func refreshClipboard() {
        let pb = UIPasteboard.general
        // `hasImages` izinsiz çağrılabilir (iOS 16+ paste banner UI'sı çıkar);
        // strict permission istemek gereksiz.
        clipboardHasImage = pb.hasImages
    }

    private func handlePaste() {
        guard let img = UIPasteboard.general.image,
              let data = img.jpegData(compressionQuality: 0.92)
        else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        vm.acceptScreenshotData(data)
    }

    // ───── Sample preview (educational ghost) ─────

    /// "iyi bir ekran görüntüsü böyle" — küçük, ghosted preview.
    /// Mode'a göre içerik değişir: cevap/davet chat bubble; açılış profil
    /// kartı (avatar + handle + bio satırları). Tonla'da gizlenir.
    /// Decorative — tıklanmaz.
    @ViewBuilder
    private var samplePreview: some View {
        switch mode {
        case .tonla:
            EmptyView()
        case .cevap, .davet:
            sampleChatPreview
        case .acilis:
            sampleProfilePreview
        }
    }

    private var sampleChatPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            sampleHeader
            VStack(spacing: 6) {
                sampleBubble(text: "akşam ne yapıyon", side: .leading)
                sampleBubble(text: "henüz bilmiyom", side: .trailing)
                sampleBubble(text: "ben de", side: .leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(samplePreviewBg)
            .opacity(0.65)
            .accessibilityHidden(true)
        }
    }

    /// Açılış için: avatar + handle + 2 satır bio. Platform-agnostik;
    /// instagram/twitter/tinder hepsi bu shape'e oturur.
    private var sampleProfilePreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            sampleHeader
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(AppColor.bg2.opacity(0.7))
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("@kullanıcı_adı")
                        .font(AppFont.body(12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.78))
                    Text("istanbul · kahve, kitap, biraz huy")
                        .font(AppFont.body(11))
                        .foregroundColor(AppColor.text60)
                    Text("son post: \"kediyle anlaşamadık.\"")
                        .font(AppFont.body(11))
                        .italic()
                        .foregroundColor(AppColor.text40)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(samplePreviewBg)
            .opacity(0.7)
            .accessibilityHidden(true)
        }
    }

    private var sampleHeader: some View {
        HStack(spacing: 6) {
            Text("iyi bir ss böyle görünür")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
            Image(systemName: "arrow.down")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColor.text40)
            Spacer(minLength: 0)
        }
    }

    private var samplePreviewBg: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(AppColor.bg1.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(AppColor.text05, lineWidth: 1)
            )
    }

    private enum BubbleSide { case leading, trailing }

    private func sampleBubble(text: String, side: BubbleSide) -> some View {
        HStack {
            if side == .trailing { Spacer(minLength: 36) }
            Text(text)
                .font(AppFont.body(11))
                .foregroundColor(.white.opacity(0.72))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(side == .trailing
                              ? AppColor.pink.opacity(0.25)
                              : AppColor.bg2.opacity(0.7))
                )
            if side == .leading { Spacer(minLength: 36) }
        }
    }

    // MARK: - UPLOADING / DONE (mevcut yapı korundu, küçük rötuş)

    private var uploadingState: some View {
        VStack(spacing: 18) {
            if let data = vm.pickedScreenshot, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColor.text10, lineWidth: 1)
                    )
                    .opacity(0.75)
                    .accessibilityLabel("yüklenen ekran görüntüsü")
            }

            HStack(spacing: 10) {
                ProgressView()
                    .tint(AppColor.lime)
                    .scaleEffect(0.9)
                Text("yorumlanıyor")
                    .font(AppFont.body(14, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("ekran görüntüsü yorumlanıyor")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func doneState(thumbnail data: Data) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text(archetypeEmoji)
                    .font(.system(size: 16))
                Text("\(archetypeShortLabel) tarzında")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text60)
                Spacer()
            }

            ZStack(alignment: .topTrailing) {
                if let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
                Circle()
                    .fill(AppColor.lime)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColor.bg0)
                    )
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppColor.lime, lineWidth: 1.5)
            )

            extraContextDisclosure
            toneSelector
        }
    }

    // ───── Ek bağlam (kapanabilir disclosure) ─────

    /// "bilmem gereken bir şey?" — kullanıcı screenshot'ın anlamadığı bağlamı
    /// LLM'e taşır ("bu eski sevgilim", "iş partneri", vs). Default kapalı,
    /// not yazıldıkça kalpça lime nokta ile dolu olduğu sinyali verilir.
    private var extraContextDisclosure: some View {
        VStack(alignment: .leading, spacing: extraContextOpen ? 12 : 0) {
            Button {
                withAnimation(AppAnimation.standard) {
                    extraContextOpen.toggle()
                }
                if extraContextOpen {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        extraContextFocused = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.text60)
                    Text("bilmem gereken bir şey?")
                        .font(AppFont.body(13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    if !vm.extraContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Circle()
                            .fill(AppColor.lime)
                            .frame(width: 5, height: 5)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: extraContextOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColor.text40)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if extraContextOpen {
                ZStack(alignment: .topLeading) {
                    if vm.extraContext.isEmpty {
                        Text("örn: bu kişi eski sevgilim. iki yıl önce ayrıldık. son üç haftadır tekrar yazıyor.")
                            .font(AppFont.body(13))
                            .italic()
                            .foregroundColor(AppColor.text30)
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                    }
                    TextEditor(text: $vm.extraContext)
                        .focused($extraContextFocused)
                        .font(AppFont.body(13))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .frame(minHeight: 92)
                        .onChange(of: vm.extraContext) { _, new in
                            if new.count > 500 {
                                vm.extraContext = String(new.prefix(500))
                            }
                        }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColor.bg1.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(AppColor.text10, lineWidth: 1)
                        )
                )
                HStack {
                    Spacer()
                    Text("\(vm.extraContext.count) / 500")
                        .font(AppFont.mono(10))
                        .foregroundColor(AppColor.text40)
                }
            }
        }
    }

    /// Ton seçimi opsiyonel. Default ("üç farklı") seçili gelir → backend
    /// mode'a özgü 3 tonu kullanır. Tek bir tona basılırsa 3 reply de o tonda
    /// (farklı açılarla) üretilir.
    private var toneSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("ton")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)
                Spacer()
                Text(vm.selectedTone == nil
                     ? "üç farklı ton önerisi"
                     : "tek tonda üç açı")
                    .font(AppFont.body(11))
                    .foregroundColor(AppColor.text40)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Chip(
                        label: "üç farklı",
                        isSelected: vm.selectedTone == nil
                    ) {
                        vm.selectedTone = nil
                    }
                    ForEach(Tone.allCases) { tone in
                        Chip(
                            label: tone.label.trLower,
                            isSelected: vm.selectedTone == tone,
                            emoji: tone.emoji
                        ) {
                            vm.selectedTone = tone
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Privacy hint (cleaned up)

    /// Sade tek satır. Eski ⓘ ikonu false-affordance'tı (tap action yoktu),
    /// kaldırıldı. Marka sesinde net, kısa.
    private var privacyHint: some View {
        Text("ekran görüntüsünü 24 saat sonra siliyoruz. kim olduğun gizli.")
            .font(AppFont.body(12))
            .foregroundColor(AppColor.text40)
            .lineSpacing(12 * 0.40)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        switch vm.pickerState {
        case .done:
            HStack(spacing: 10) {
                SecondaryButton(title: "değiştir") {
                    vm.resetPicker()
                }
                PrimaryButton("devam") {
                    vm.proceedToGeneration()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        case .empty, .uploading:
            EmptyView()
        }
    }

    // MARK: - Computed

    private var archetypeEmoji: String {
        guard let a = vm.archetype else { return "✨" }
        return String(a.label.first ?? "✨")
    }

    private var archetypeShortLabel: String {
        guard let a = vm.archetype else { return "" }
        let parts = a.label.split(separator: " ", maxSplits: 1)
        return (parts.last.map(String.init) ?? "").trLower
    }
}
