import SwiftUI

/// Kullanıcının "bize biraz kendinden bahset" cevabını görüntüler ve günceller.
/// profiles.voice_sample kolonuna yazılır; LLM her üretimde L4 prompt'una
/// <user_voice> block olarak inject eder.
///
/// Onboarding'de bir kez sorulur (atlanabilir). Buradan istenildiğinde
/// güncellenebilir; etki anında, sonraki üretimden itibaren.
struct VoiceSampleEditorView: View {
    let onClose: () -> Void

    @State private var sample: String = ""
    @State private var initialSample: String = ""
    @State private var loading: Bool = true
    @State private var saving: Bool = false
    @State private var error: String?
    @FocusState private var focused: Bool

    private let maxLength: Int = 500

    var body: some View {
        ZStack(alignment: .top) {
            CosmicBackground()
            VStack(spacing: 0) {
                topBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        editor
                            .padding(.top, 8)
                        if let error {
                            Text(error)
                                .font(AppFont.body(12))
                                .foregroundColor(AppColor.danger)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
                .scrollDismissesKeyboard(.interactively)
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await load() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("bitti") { focused = false }
            }
        }
    }

    // MARK: - Sections

    private var topBar: some View {
        HStack {
            Button { onClose() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            Spacer()
            Text("kendi sesin")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("kendinden bahset")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
            Text("nasıl yazdığını öğrenelim. cevaplar senin sesine yakın çıksın. istediğin zaman güncelle.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var editor: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if sample.isEmpty && !loading {
                    Text("ne yapıyorsun, neden buradasın, ne tarz mesajlar atıyorsun. ne hissediyorsan yaz.")
                        .font(AppFont.body(15))
                        .italic()
                        .foregroundColor(AppColor.text30)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                TextEditor(text: $sample)
                    .focused($focused)
                    .font(AppFont.body(15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .frame(minHeight: 200)
                    .disabled(loading)
                    .opacity(loading ? 0.4 : 1)
                    .onChange(of: sample) { _, new in
                        if new.count > maxLength {
                            sample = String(new.prefix(maxLength))
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

            HStack(spacing: 8) {
                Spacer()
                Text("\(sample.count) / \(maxLength)")
                    .font(AppFont.mono(11))
                    .foregroundColor(AppColor.text40)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle().fill(AppColor.text05).frame(height: 1)
            HStack(spacing: 10) {
                if isDirty {
                    Button {
                        sample = initialSample
                    } label: {
                        Text("vazgeç")
                            .font(AppFont.body(14, weight: .medium))
                            .foregroundColor(AppColor.text60)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
                Spacer()
                Button {
                    Task { await save() }
                } label: {
                    Text(saving ? "kaydediliyor" : "kaydet")
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundColor(isDirty ? AppColor.bg0 : AppColor.text40)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(isDirty ? AppColor.lime : AppColor.bg1.opacity(0.5))
                        )
                }
                .disabled(!isDirty || saving)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
    }

    // MARK: - State

    private var isDirty: Bool {
        sample.trimmingCharacters(in: .whitespacesAndNewlines)
            != initialSample.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Backend

    private struct ProfileRow: Decodable {
        let voice_sample: String?
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            let userId = try await SupabaseService.shared.auth.session.user.id
            let response: [ProfileRow] = try await SupabaseService.shared
                .from("profiles")
                .select("voice_sample")
                .eq("id", value: userId)
                .limit(1)
                .execute()
                .value
            let current = response.first?.voice_sample ?? ""
            sample = current
            initialSample = current
        } catch {
            self.error = "yüklenemedi: \(error.localizedDescription)"
        }
    }

    private func save() async {
        saving = true
        defer { saving = false }
        let trimmed = sample.trimmingCharacters(in: .whitespacesAndNewlines)
        let value: String? = trimmed.isEmpty ? nil : trimmed
        struct UpdatePayload: Encodable { let voice_sample: String? }
        do {
            let userId = try await SupabaseService.shared.auth.session.user.id
            try await SupabaseService.shared
                .from("profiles")
                .update(UpdatePayload(voice_sample: value))
                .eq("id", value: userId)
                .execute()
            initialSample = sample
            error = nil
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            self.error = "kaydedilemedi: \(error.localizedDescription)"
        }
    }
}
