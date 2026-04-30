import SwiftUI

/// Tonla modu — kullanıcı taslağını yapıştırır + ton seçer + üret.
/// SS yok; sadece text input. Ton zorunlu (üç farklı ton chip'i yok).
struct TonlaDraftView: View {
    @Bindable var vm: HomeViewModel

    @FocusState private var draftFocused: Bool
    @FocusState private var contextFocused: Bool
    @State private var showContextField = false

    private var canSubmit: Bool {
        !vm.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && vm.selectedTone != nil
    }

    /// Disable iken sebep göster — kullanıcı neden basamadığını okur.
    /// Manual composer'larla aynı pattern.
    private var submitHint: String? {
        let draftEmpty = vm.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if draftEmpty && vm.selectedTone == nil { return "taslağı yaz, ton seç" }
        if draftEmpty { return "taslağı yaz" }
        if vm.selectedTone == nil { return "ton seç" }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    draftInput
                    contextSection
                    toneSelector
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
                Button("bitti") {
                    draftFocused = false
                    contextFocused = false
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
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("geri")
            Spacer(minLength: 0)
            Text("tonla modu")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer(minLength: 0)
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("yazdığını ver, tonlayalım")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
                .lineSpacing(22 * 0.08)
                .fixedSize(horizontal: false, vertical: true)

            Text("niyetin aynı kalır, sadece ses değişir.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Draft input

    private var draftInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("taslak")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)

            ZStack(alignment: .topLeading) {
                if vm.draftText.isEmpty {
                    Text("yazdığını buraya yapıştır")
                        .font(AppFont.body(15))
                        .foregroundColor(AppColor.text40)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                TextEditor(text: $vm.draftText)
                    .font(AppFont.body(15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 140)
                    .focused($draftFocused)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                draftFocused ? AppColor.text20 : AppColor.text08,
                                lineWidth: 1
                            )
                    )
            )

            HStack {
                Spacer()
                Text("\(vm.draftText.count) / 1500")
                    .font(AppFont.mono(10))
                    .foregroundColor(AppColor.text40)
            }
        }
    }

    // MARK: - Context (optional)

    @ViewBuilder
    private var contextSection: some View {
        if showContextField {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("karşı tarafın son mesajı")
                        .font(AppFont.mono(11))
                        .tracking(0.04 * 11)
                        .foregroundColor(AppColor.text40)
                    Spacer()
                    Button {
                        vm.contextText = ""
                        showContextField = false
                    } label: {
                        Text("kaldır")
                            .font(AppFont.body(11))
                            .foregroundColor(AppColor.text40)
                    }
                }

                ZStack(alignment: .topLeading) {
                    if vm.contextText.isEmpty {
                        Text("karşı tarafın son mesajı — dil eşleşsin diye")
                            .font(AppFont.body(14))
                            .foregroundColor(AppColor.text40)
                            .padding(.horizontal, 14)
                            .padding(.top, 12)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $vm.contextText)
                        .focused($contextFocused)
                        .font(AppFont.body(14))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(minHeight: 70)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColor.bg1.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(AppColor.text05, lineWidth: 1)
                        )
                )
            }
        } else {
            Button { showContextField = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                    Text("karşı tarafın son mesajını ekle")
                        .font(AppFont.body(13))
                }
                .foregroundColor(AppColor.text60)
            }
        }
    }

    // MARK: - Tone selector (zorunlu)

    private var toneSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("ton")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text40)
                Spacer()
                Text(vm.selectedTone == nil
                     ? "ton seç, üç açı çıkar"
                     : "üç açı, aynı tonda")
                    .font(AppFont.body(11))
                    .foregroundColor(vm.selectedTone == nil ? AppColor.pink : AppColor.text40)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
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

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 8) {
            if let err = vm.lastError {
                Text(err)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            } else if let hint = submitHint {
                Text(hint)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            PrimaryButton("tonla", isEnabled: canSubmit) {
                draftFocused = false
                contextFocused = false
                vm.proceedToTonlaGeneration()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
