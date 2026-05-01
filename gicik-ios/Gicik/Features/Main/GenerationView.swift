import SwiftUI
import UIKit

/// Streaming generation UI — parsing activity + typewriter observation + replies stack.
///
/// Iterasyon (2026-04-30): caret-only parsing fazı 7-8s boş ekran sayılıyordu.
/// Çözüm: parsing fazında kullanıcının yüklediği ss merkezde gösterilir +
/// üzerinden lime scan line aşağı süzülür + altında dönen kuru gözlemler
/// ("ekrana bakıyorum" → "sayıyorum" → "düşünüyorum") typewriter ile yazılır.
/// Backend `observation` SSE event'i gelir gelmez ss küçülür kaybolur,
/// asıl gözlem typewriter'a geçer, reply'lar altında stack'lenir.
struct GenerationView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    @State private var firstReplyHapticFired = false
    @State private var typewriterDone = false

    // Parsing fazı dönen lokal gözlemler — backend `observation` event'i
    // gelmeden önceki 7-8s'lik aralığı dolduruyor. L0 kontratı:
    //   - lowercase, period, ironik mesafeli, klişe yok.
    //   - gözlem yap beyan et geç, açıklama yapma.
    // Sequence gözlemci tavrını yansıtıyor: "ekran açık" varlık beyanı,
    // "kim son yazmış" ilk merak, "boşluk neyi söylüyor" sessizliği okumak,
    // "söylenmemişe bakıyorum" Efso'ın signature move'u (L0: "insanlar
    // duyduklarını değil görmedikleri şeyi öğrenmek ister").
    // 4 × 2.4s = 9.6s tek cycle, parsing süresine birebir denk.
    @State private var parsingQuipIndex = 0
    private let parsingQuipsScreenshot: [String] = [
        "ekran açık.",
        "kim son yazmış.",
        "boşluk neyi söylüyor.",
        "söylenmemişe bakıyorum.",
    ]
    /// Manuel akışta ss yok; "ekran açık" gibi cümleler yalan olur.
    private let parsingQuipsManual: [String] = [
        "yazdıklarını okuyorum.",
        "tonu yakaladım.",
        "araları nasıl, ona bakıyorum.",
        "uygun cevap kuruyorum.",
    ]
    /// Tonla'da ss veya konuşma yok; kullanıcının taslağı var.
    /// "ekran açık" / "kim son yazmış" iki tarafı da yalan.
    private let parsingQuipsTonla: [String] = [
        "taslağı okudum.",
        "tonu deniyorum.",
        "üç açı kuruyorum.",
        "fazlalığı kesiyorum.",
    ]
    private var parsingQuips: [String] {
        if mode == .tonla { return parsingQuipsTonla }
        return vm.isManualMode ? parsingQuipsManual : parsingQuipsScreenshot
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header

            if vm.generationPhase == .failed {
                failureBlock
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
            } else {
                stageBody
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppAnimation.standard, value: vm.streamingObservation.isEmpty)
        .animation(AppAnimation.standard, value: vm.generationPhase)
        .animation(AppAnimation.standard, value: vm.streamingReplies.count)
        .onChange(of: vm.streamingReplies.count) { _, newCount in
            if newCount == 1 && !firstReplyHapticFired {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                firstReplyHapticFired = true
            }
        }
        .onChange(of: vm.generationPhase) { _, phase in
            if phase == .parsing {
                firstReplyHapticFired = false
                typewriterDone = false
                parsingQuipIndex = 0
            }
        }
        // Parsing fazında kuru gözlemler arasında dönüş — TypewriterText quip
        // değişince reset olup yeniden yazıyor.
        .task(id: vm.generationPhase) {
            guard vm.generationPhase == .parsing else { return }
            while !Task.isCancelled, vm.generationPhase == .parsing {
                try? await Task.sleep(nanoseconds: 2_400_000_000)
                if Task.isCancelled || vm.generationPhase != .parsing { break }
                parsingQuipIndex = (parsingQuipIndex + 1) % parsingQuips.count
            }
        }
    }

    // MARK: - Stage body router

    @ViewBuilder
    private var stageBody: some View {
        if vm.streamingObservation.isEmpty {
            // Parsing — ss + scan + rotating quip.
            parsingActivity
        } else {
            // Observation arrived — typewriter the real text, replies below.
            VStack(alignment: .leading, spacing: 18) {
                TypewriterText(
                    text: vm.streamingObservation.trLower,
                    font: AppFont.body(18, weight: .regular).italic(),
                    color: .white.opacity(0.88),
                    charDelayMs: 22,
                    showCaret: !typewriterDone || vm.streamingReplies.isEmpty,
                    onComplete: { typewriterDone = true }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("gözlem: \(vm.streamingObservation)")

                replyStack
            }
        }
    }

    // MARK: - Parsing activity (the new heart of the wait)

    @ViewBuilder
    private var parsingActivity: some View {
        VStack(spacing: 22) {
            if let data = vm.pickedScreenshot, let img = UIImage(data: data) {
                ScanningScreenshot(image: img)
                    .frame(maxWidth: 220)
                    .frame(maxWidth: .infinity)
            } else if mode == .tonla {
                // Tonla'da ss veya konuşma yok; kullanıcının taslağı var.
                // Onu ghost-card olarak göster ki kullanıcı "neyin
                // tonlandığını" görsün.
                tonlaParsingPreview
                    .frame(maxWidth: .infinity)
            } else if vm.isManualMode {
                // Manuel akışta ss yok; boş alanı kullanıcının kendi
                // yazdıklarının özetiyle doldur. Kafası net olsun:
                // "neyi okuyor" sorusunun cevabı.
                manualParsingPreview
                    .frame(maxWidth: .infinity)
            }

            // Dönen kuru gözlemler. ID quipIndex'e bağlı — değişince reset olup
            // yeniden yazıyor (TypewriterText.onChange(of: text)).
            TypewriterText(
                text: parsingQuips[parsingQuipIndex],
                font: AppFont.body(16, weight: .regular).italic(),
                color: .white.opacity(0.7),
                charDelayMs: 28,
                showCaret: true
            )
            .id("parsing-\(parsingQuipIndex)")
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .accessibilityLabel(parsingQuips[parsingQuipIndex])
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }

    /// Manuel akışta parsing fazında: kullanıcının girdiği konuşma özeti
    /// (cevap/davet) veya profil özeti (açılış). 3-4 satır, küçük punto,
    /// kart şeklinde — hangi veriyle çalıştığımızı net gösterir.
    @ViewBuilder
    private var manualParsingPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !vm.manualMessages.isEmpty {
                let last3 = Array(vm.manualMessages.suffix(3))
                ForEach(Array(last3.enumerated()), id: \.element.id) { _, msg in
                    HStack {
                        if msg.sender == .user { Spacer(minLength: 24) }
                        Text(msg.text)
                            .font(AppFont.body(12))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(msg.sender == .user
                                          ? AppColor.pink.opacity(0.22)
                                          : AppColor.bg2.opacity(0.7))
                            )
                        if msg.sender == .other { Spacer(minLength: 24) }
                    }
                }
            } else if !vm.manualBio.isEmpty || !vm.manualHandle.isEmpty
                        || !vm.manualPosts.isEmpty || !vm.manualPhotoDescriptions.isEmpty {
                if !vm.manualHandle.isEmpty {
                    Text(vm.manualHandle)
                        .font(AppFont.mono(12))
                        .foregroundColor(.white.opacity(0.85))
                }
                if !vm.manualBio.isEmpty {
                    Text(vm.manualBio)
                        .font(AppFont.body(12))
                        .italic()
                        .foregroundColor(AppColor.text60)
                        .lineLimit(3)
                }
                if let firstPost = vm.manualPosts.first(where: {
                    !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }) {
                    Text("\"\(firstPost)\"")
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                        .lineLimit(2)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: 320, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
        .opacity(0.85)
        .accessibilityHidden(true)
    }

    /// Tonla parsing fazı: kullanıcının taslağı + (varsa) karşı tarafın
    /// son mesajı, ghost-card olarak. Hangi metnin tonlandığı netleşir.
    @ViewBuilder
    private var tonlaParsingPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !vm.contextText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Karşı tarafın mesajı — sol bubble.
                HStack {
                    Text(vm.contextText)
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                        .lineLimit(3)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColor.bg2.opacity(0.7))
                        )
                    Spacer(minLength: 24)
                }
            }
            // Kullanıcının taslağı — sağ bubble, pink accent.
            HStack {
                Spacer(minLength: 24)
                Text(vm.draftText)
                    .font(AppFont.body(13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.pink.opacity(0.22))
                    )
            }
            // Selected tone hint — neye çevirdiğimizi söyle.
            if let tone = vm.selectedTone {
                HStack(spacing: 6) {
                    Spacer()
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.text40)
                        .accessibilityHidden(true)
                    Text(tone.label.trLower)
                        .font(AppFont.mono(10))
                        .tracking(0.04 * 10)
                        .foregroundColor(AppColor.text60)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: 340, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
        .opacity(0.9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "taslak: \(vm.draftText)" +
            (vm.contextText.isEmpty ? "" : ". bağlam: \(vm.contextText)") +
            (vm.selectedTone.map { ". hedef ton: \($0.label)" } ?? "")
        )
    }

    // MARK: - Reply stack

    private var replyStack: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { idx in
                if let r = vm.streamingReplies[idx] {
                    ReplyCard(
                        toneAngle: "\(String(format: "%02d", idx + 1)) — \(r.toneLabel)",
                        text: r.text,
                        onCopy: {
                            UIPasteboard.general.string = r.text
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("geri")

            Spacer()

            // Ss merkeze geldiğinde top-right thumbnail mükerrer olur — gizle.
            if vm.generationPhase != .idle && !vm.streamingObservation.isEmpty {
                contextEcho
                    .transition(.opacity)
            } else if vm.generationPhase != .idle {
                // Parsing fazında sadece tone chip görünür; ss merkezde zaten.
                if let tone = vm.selectedTone {
                    toneChip(tone)
                        .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private func toneChip(_ tone: Tone) -> some View {
        Text(tone.label.trLower)
            .font(AppFont.mono(10))
            .tracking(0.04 * 10)
            .foregroundColor(AppColor.text60)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(AppColor.bg1.opacity(0.6)))
            .overlay(Capsule().strokeBorder(AppColor.text05, lineWidth: 1))
            .padding(.trailing, 6)
    }

    @ViewBuilder
    private var contextEcho: some View {
        HStack(spacing: 10) {
            if let tone = vm.selectedTone { toneChip(tone) }

            if let data = vm.pickedScreenshot,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(AppColor.text05, lineWidth: 1)
                    )
                    .accessibilityLabel("yüklenen ekran görüntüsü")
            }
        }
        .padding(.trailing, 6)
    }

    // MARK: - Header

    private var headerLine: String {
        switch vm.generationPhase {
        case .idle, .parsing:
            if mode == .tonla { return "taslağı tonluyor" }
            return vm.isManualMode ? "okudum" : "ekranı okuyor"
        case .streaming:
            return mode == .tonla ? "tonluyor" : "yazıyor"
        case .finishing: return "bitiriyor"
        case .failed: return "tutmadı"
        }
    }

    private var phaseHint: String? {
        switch vm.generationPhase {
        case .parsing:
            if mode == .tonla { return "adım 1/2 — taslak işleniyor" }
            return vm.isManualMode
                ? "adım 1/2 — yazdıkların işleniyor"
                : "adım 1/2 — ekran okunuyor"
        case .streaming: return "adım 2/2 — üç açı yazılıyor"
        case .finishing: return "adım 2/2 — son rötuş"
        case .idle, .failed: return nil
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(mode.label) MODU")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text60)
            Text(headerLine)
                .font(AppFont.display(28, weight: .bold))
                .tracking(-0.02 * 28)
                .foregroundColor(.white)
                .contentTransition(.opacity)
            if let hint = phaseHint {
                Text(hint)
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text60)
                    .transition(.opacity)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Failure block

    private var failureBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColor.lime)
                    .padding(.top, 3)
                Text(vm.lastError.map { humanize($0) } ?? "bağlantı sorunu. tekrar dener misin")
                    .font(AppFont.body(15))
                    .italic()
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(15 * 0.45)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Button { vm.regenerate() } label: {
                    Text("yeniden dene")
                        .font(AppFont.mono(12))
                        .tracking(0.04 * 12)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(AppColor.bg1))
                        .overlay(Capsule().strokeBorder(AppColor.lime.opacity(0.5), lineWidth: 1))
                }

                Button { vm.backToHome() } label: {
                    Text("vazgeç")
                        .font(AppFont.mono(12))
                        .tracking(0.04 * 12)
                        .foregroundColor(AppColor.text60)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }

    private func humanize(_ raw: String) -> String {
        let lower = raw.trLower
        if lower.contains("timeout") || lower.contains("timed out") {
            return "bağlantı yavaş. bir daha dener misin"
        }
        if lower.contains("offline") || lower.contains("network") || lower.contains("connection") {
            return "internet kayıp. açınca dön"
        }
        if lower.contains("free_tier") || lower.contains("402") {
            return "günlük hak doldu. yarın yine"
        }
        #if DEBUG
        // Debug build: raw error'u olduğu gibi göster ki sorunu teşhis edebilelim.
        // Release build'de generic fallback döner.
        return "üretim tutmadı. \n\n[debug] \(raw)"
        #else
        return "üretim tutmadı. tekrar dener misin"
        #endif
    }
}

/// Parsing fazı için kullanıcının ss'i + üzerinden geçen lime scan line.
/// "okuduğum şey bu" affordance'ı + aktif görsel.
///
/// Scan mekanik:
///   - `TimelineView(.animation)` display link tabanlı; parent re-render
///     olsa bile zamanı kaybetmiyor (önceki `withAnimation(.repeatForever)`
///     denemesinde view recompose'da animation cancel oluyordu).
///   - Progress = (elapsed % cycle) / cycle, [0..1] aralığında lineer döner.
///   - Offset = progress * (h + lineHeight) - lineHeight; her iki uçta
///     görünmez olduğu için cycle wrap fark edilmiyor.
private struct ScanningScreenshot: View {
    let image: UIImage
    private let lineHeight: CGFloat = 36
    private let radius: CGFloat = 14
    private let cycle: TimeInterval = 2.0

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSinceReferenceDate
            let progress = CGFloat(elapsed.truncatingRemainder(dividingBy: cycle) / cycle)

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 280)
                .opacity(0.92)
                .overlay {
                    GeometryReader { geo in
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: AppColor.lime.opacity(0.5), location: 0.5),
                                .init(color: .clear, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: lineHeight)
                        .offset(y: progress * (geo.size.height + lineHeight) - lineHeight)
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(AppColor.lime.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: AppColor.purpleGlow, radius: 24, x: 0, y: 8)
                .accessibilityLabel("yüklediğin ekran görüntüsü okunuyor")
        }
    }
}
