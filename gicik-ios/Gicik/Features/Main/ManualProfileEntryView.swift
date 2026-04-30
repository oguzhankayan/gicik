import SwiftUI

/// Manuel profil girişi — açılış modu için. Kullanıcı ss yerine
/// karşı tarafın profilini elle yazar: handle, bio, post'lar, foto
/// açıklamaları. En az bir alan dolu olmalı.
struct ManualProfileEntryView: View {
    @Bindable var vm: HomeViewModel

    @FocusState private var focused: Field?
    private enum Field: Hashable { case handle, bio, post(Int), photo(Int) }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    handleField
                    bioField
                    postsSection
                    photoSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
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
                Button("bitti") { focused = nil }
            }
        }
    }

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
            Text("elle yaz · açılış")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer(minLength: 0)
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profili tarif et")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
            Text("ne kadar verirsen o kadar isabetli açılış üretiriz. en az bir alan yeter.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var handleField: some View {
        labeledTextField(
            label: "kullanıcı adı",
            placeholder: "@elif",
            text: $vm.manualHandle,
            field: .handle
        )
    }

    private var bioField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BIO")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
            ZStack(alignment: .topLeading) {
                if vm.manualBio.isEmpty {
                    Text("profilde yazan açıklama. (opsiyonel ama en zenginidir)")
                        .font(AppFont.body(14))
                        .foregroundColor(AppColor.text30)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $vm.manualBio)
                    .focused($focused, equals: .bio)
                    .font(AppFont.body(14))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 90)
            }
            .background(roundedFieldBg)
        }
    }

    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(title: "POST / TWEET", count: vm.manualPosts.count, max: 5) {
                vm.manualPosts.append("")
                let i = vm.manualPosts.count - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    focused = .post(i)
                }
            }
            ForEach(vm.manualPosts.indices, id: \.self) { i in
                indexedRow(
                    binding: $vm.manualPosts[i],
                    placeholder: "son post / tweet'lerinden biri",
                    field: .post(i)
                ) {
                    vm.manualPosts.remove(at: i)
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(title: "FOTO AÇIKLAMASI", count: vm.manualPhotoDescriptions.count, max: 5) {
                vm.manualPhotoDescriptions.append("")
                let i = vm.manualPhotoDescriptions.count - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    focused = .photo(i)
                }
            }
            ForEach(vm.manualPhotoDescriptions.indices, id: \.self) { i in
                indexedRow(
                    binding: $vm.manualPhotoDescriptions[i],
                    placeholder: "fotoğrafta ne var (kahve, kedi, dağ, vb.)",
                    field: .photo(i)
                ) {
                    vm.manualPhotoDescriptions.remove(at: i)
                }
            }
        }
    }

    // MARK: - Helpers

    private func labeledTextField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
            TextField(placeholder, text: text)
                .focused($focused, equals: field)
                .font(AppFont.body(14))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(roundedFieldBg)
        }
    }

    private func sectionHeader(title: String, count: Int, max: Int, onAdd: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.text40)
            Spacer()
            if count < max {
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .accessibilityHidden(true)
                        Text("ekle")
                            .font(AppFont.body(11, weight: .medium))
                    }
                    .foregroundColor(AppColor.lime)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(minHeight: 36)
                    .background(
                        Capsule().fill(AppColor.lime.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(title.lowercased()) ekle")
            }
        }
    }

    private func indexedRow(
        binding: Binding<String>,
        placeholder: String,
        field: Field,
        onDelete: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                if binding.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(AppFont.body(13))
                        .foregroundColor(AppColor.text30)
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                        .allowsHitTesting(false)
                }
                TextField("", text: binding, axis: .vertical)
                    .focused($focused, equals: field)
                    .font(AppFont.body(13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .lineLimit(1...4)
            }
            .frame(maxWidth: .infinity)
            .background(roundedFieldBg)

            Button(action: onDelete) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 18))
                    .foregroundColor(AppColor.text40)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("sil")
        }
    }

    private var roundedFieldBg: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(AppColor.bg1.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(AppColor.text08, lineWidth: 1)
            )
    }

    private var canSubmit: Bool {
        let trim: (String) -> String = { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return !trim(vm.manualBio).isEmpty
            || !trim(vm.manualHandle).isEmpty
            || vm.manualPosts.contains { !trim($0).isEmpty }
            || vm.manualPhotoDescriptions.contains { !trim($0).isEmpty }
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 8) {
            if let err = vm.lastError {
                Text(err)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.warning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            } else if !canSubmit {
                Text("en az bir alan doldur (bio, handle, post veya foto)")
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            HStack(spacing: 10) {
                SecondaryButton(title: "temizle") {
                    vm.manualBio = ""
                    vm.manualHandle = ""
                    vm.manualPosts = []
                    vm.manualPhotoDescriptions = []
                    vm.lastError = nil
                }
                PrimaryButton("üret", isEnabled: canSubmit) {
                    vm.lastError = nil
                    vm.proceedToManualGeneration()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
