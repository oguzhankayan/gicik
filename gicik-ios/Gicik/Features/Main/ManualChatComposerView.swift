import SwiftUI

/// Manuel chat composer — kullanıcı ekran görüntüsü atmadan konuşmayı
/// elle kurar. Cevap ve davet modları için. Açılış için
/// ManualProfileEntryView kullanılır.
///
/// UX:
/// - üst: geri + "elle yaz" + "kim" alanı (karşı tarafın adı, opsiyonel)
/// - orta: alternating bubble listesi (sol = onun, sağ = senin)
/// - sağa kayar bubble silinir (swipe action)
/// - "+ onun mesajı" / "+ senin mesajın" toggle butonu — son bubble'a
///   göre uygun olanı vurgular
/// - alt: tone seçici + "üret" CTA
///
/// Validasyon kuralı: en az 1 mesaj + son mesaj `.other` olmalı.
struct ManualChatComposerView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    @FocusState private var focusedMessageID: UUID?
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        nameField
                            .padding(.top, 16)
                        emptyOrMessages
                            .padding(.top, 18)
                        addButtons
                            .padding(.top, 14)
                        toneSelector
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: vm.manualMessages.count) { _, _ in
                    guard let last = vm.manualMessages.last else { return }
                    // Insertion animation (~0.34s) bitsin sonra scroll —
                    // bubble belirme + scroll-to aynı anda çakışmasın.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.85)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("bitti") {
                    focusedMessageID = nil
                    nameFocused = false
                }
            }
        }
    }

    // MARK: - TopBar
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
            Text("elle yaz · \(mode.label.trLower)")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer(minLength: 0)
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }

    // MARK: - Name field
    private var nameField: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 16))
                .foregroundColor(AppColor.text40)
                .accessibilityHidden(true)
            TextField("karşı tarafın adı (opsiyonel)", text: $vm.manualOtherName)
                .focused($nameFocused)
                .font(AppFont.body(14))
                .foregroundColor(.white)
                .submitLabel(.done)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppColor.text08, lineWidth: 1)
                )
        )
    }

    // MARK: - Empty / messages
    /// Önceden empty/messages arası VStack yapı değişimiydi → snap yapıyordu.
    /// Şimdi tek container, içeride conditional görünüm + her bubble'da
    /// asymmetric transition.
    private var emptyOrMessages: some View {
        VStack(spacing: 8) {
            if vm.manualMessages.isEmpty {
                emptyHint
                    .transition(.opacity)
            } else {
                ForEach($vm.manualMessages) { $msg in
                    messageBubble(msg: $msg)
                        .id(msg.id)
                        .transition(.asymmetric(
                            insertion: .opacity
                                .combined(with: .move(edge: .bottom))
                                .combined(with: .scale(scale: 0.96, anchor: .bottom)),
                            removal: .opacity.combined(with: .scale(scale: 0.92))
                        ))
                }
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: vm.manualMessages.count)
    }

    private var emptyHint: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("konuşmayı kur")
                .font(AppFont.display(20, weight: .bold))
                .tracking(-0.02 * 20)
                .foregroundColor(.white)
            Text("önce karşı taraftan başlayalım. son mesaj onun olsun ki sen cevap üretebilelim.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }

    private func messageBubble(msg: Binding<HomeViewModel.ManualMessage>) -> some View {
        let isOther = msg.wrappedValue.sender == .other
        let voLabel = isOther
            ? "karşı tarafın mesajı: \(msg.wrappedValue.text.isEmpty ? "boş" : msg.wrappedValue.text)"
            : "senin cevabın: \(msg.wrappedValue.text.isEmpty ? "boş" : msg.wrappedValue.text)"
        return HStack {
            if !isOther { Spacer(minLength: 36) }
            ZStack(alignment: .topLeading) {
                if msg.wrappedValue.text.isEmpty {
                    Text(isOther ? "onun mesajı" : "senin cevabın")
                        .font(AppFont.body(14))
                        .foregroundColor(AppColor.text30)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .allowsHitTesting(false)
                }
                TextField("", text: msg.text, axis: .vertical)
                    .focused($focusedMessageID, equals: msg.wrappedValue.id)
                    .font(AppFont.body(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    // lineLimit(1...6) her karakterde parent VStack reflow
                    // tetikliyordu. axis:.vertical zaten doğal şekilde
                    // büyür; cap kaldırıldı, akıcılaşıyor.
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isOther
                          ? AppColor.bg1.opacity(0.7)
                          : AppColor.pink.opacity(0.22))
            )
            .overlay(alignment: .topTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    let id = msg.wrappedValue.id
                    // Focus önce kalksın — kaybolurken keyboard takılı
                    // kalmasın. Sonra remove animation çalışır.
                    if focusedMessageID == id { focusedMessageID = nil }
                    vm.manualMessages.removeAll { $0.id == id }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColor.text40)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityHidden(true)
                }
                .accessibilityLabel("mesajı sil")
            }
            if isOther { Spacer(minLength: 36) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(voLabel)
    }

    // MARK: - Add buttons
    private var addButtons: some View {
        HStack(spacing: 10) {
            addButton(label: "+ onun mesajı", sender: .other,
                      tint: AppColor.text60, suggested: nextSuggested == .other)
            addButton(label: "+ senin cevabın", sender: .user,
                      tint: AppColor.pink, suggested: nextSuggested == .user)
        }
    }

    private func addButton(
        label: String,
        sender: HomeViewModel.ManualSender,
        tint: Color,
        suggested: Bool
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            let new = HomeViewModel.ManualMessage(sender: sender)
            // Append'i .animation modifier'ı zaten yakalar; ek
            // withAnimation sarmasına gerek yok. Focus'u animation
            // bittikten sonra ver — keyboard pop-up + transition collide
            // etmesin.
            vm.manualMessages.append(new)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                focusedMessageID = new.id
            }
        } label: {
            Text(label)
                .font(AppFont.body(13, weight: .medium))
                .foregroundColor(suggested ? .white : AppColor.text60)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(suggested ? tint.opacity(0.18) : AppColor.bg1.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    suggested ? tint.opacity(0.6) : AppColor.text08,
                                    lineWidth: suggested ? 1.2 : 1
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    /// Bir sonraki için önerilen sender — son mesajın tersi.
    /// Boşsa "other" (konuşma karşı taraftan başlar).
    private var nextSuggested: HomeViewModel.ManualSender {
        guard let last = vm.manualMessages.last else { return .other }
        return last.sender == .other ? .user : .other
    }

    // MARK: - Tone selector
    private var toneSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("ton")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)
                Spacer()
                Text(vm.selectedTone == nil ? "üç farklı ton önerisi" : "tek tonda üç açı")
                    .font(AppFont.body(11))
                    .foregroundColor(AppColor.text40)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Chip(label: "üç farklı", isSelected: vm.selectedTone == nil) {
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

    // MARK: - Footer
    /// Submit kapısı + neden disabled olduğunu yazan inline hint.
    /// Kullanıcı "üret"in pasif olduğu anda **neden** olduğunu görmeli.
    private var submitGate: (canSubmit: Bool, hint: String?) {
        let nonEmpty = vm.manualMessages.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if nonEmpty.isEmpty {
            return (false, "en az bir mesaj gir")
        }
        if nonEmpty.last?.sender != .other {
            return (false, "son mesaj karşı taraftan olmalı, sen cevap yazacaksın")
        }
        return (true, nil)
    }

    @ViewBuilder
    private var footer: some View {
        let gate = submitGate
        VStack(spacing: 8) {
            if let err = vm.lastError {
                Text(err)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            } else if let hint = gate.hint {
                Text(hint)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            HStack(spacing: 10) {
                SecondaryButton(title: "temizle") {
                    vm.manualMessages = []
                    vm.manualOtherName = ""
                    vm.lastError = nil
                }
                PrimaryButton("üret", isEnabled: gate.canSubmit) {
                    vm.lastError = nil
                    vm.proceedToManualGeneration()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
