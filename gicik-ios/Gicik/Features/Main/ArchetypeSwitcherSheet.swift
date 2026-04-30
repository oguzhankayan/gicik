import SwiftUI

/// Kullanıcının arketipini manuel değiştirmesi için sheet.
/// HomeView sol-üst avatar tıklamasıyla açılır.
struct ArchetypeSwitcherSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selected: ArchetypePrimary
    @State private var saving = false
    @State private var error: String?

    init(vm: HomeViewModel) {
        self._vm = Bindable(vm)
        _selected = State(initialValue: vm.archetype ?? .dryroaster)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 18)
                .background(
                    LinearGradient(
                        colors: [AppColor.bg0, AppColor.bg0, AppColor.bg0.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                )
                .zIndex(1)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(ArchetypePrimary.allCases, id: \.self) { arch in
                        archetypeCard(arch)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 20)
            }

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
    }

    // MARK: - Top bar (X)

    private var topBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.text40)
                    .padding(10)
            }
        }
        .padding(.top, 14)
        .padding(.trailing, 12)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ŞU ANKİ TARZIN")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)

            HStack(spacing: 12) {
                Image((vm.archetype ?? .dryroaster).iconAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                Text(currentLabelOnly)
                    .font(AppFont.display(28, weight: .bold))
                    .tracking(-0.02 * 28)
                    .foregroundColor(.white)
                Spacer(minLength: 0)
            }

            Text("aşağıdaki tarzlardan istediğini seç. değiştirmek istemezsen olduğu gibi kalır.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Card

    private func archetypeCard(_ arch: ArchetypePrimary) -> some View {
        let isSelected = selected == arch
        return Button {
            withAnimation(AppAnimation.standard) {
                selected = arch
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Image(arch.iconAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 3) {
                    Text(labelOnlyOf(arch))
                        .font(AppFont.display(17, weight: .bold))
                        .tracking(-0.02 * 17)
                        .foregroundColor(.white)
                    Text(shortDescription(arch))
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(12 * 0.30)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                // Sabit slot — seçili/seçili-değil arası genişlik kayması olmasın.
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(AppColor.lime)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColor.bg0)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? AppColor.bgGlass : AppColor.bg1.opacity(0.5))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isSelected
                                ? AnyShapeStyle(AppColor.holographic.opacity(0.65))
                                : AnyShapeStyle(AppColor.text08),
                            lineWidth: 1
                        )
                }
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
    }

    // MARK: - Footer (save)

    private var footer: some View {
        VStack(spacing: 10) {
            if let error {
                Text(error)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.danger)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            PrimaryButton("kaydet", isEnabled: selected != vm.archetype && !saving) {
                Task { await save() }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                colors: [Color.clear, AppColor.bg0.opacity(0.85), AppColor.bg0],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Save

    private func save() async {
        saving = true
        defer { saving = false }
        error = nil

        let prev = vm.archetype
        vm.archetype = selected

        do {
            try await SupabaseService.shared.client
                .from("profiles")
                .update(["archetype_primary": selected.rawValue])
                .eq("id", value: AuthService.shared.userID?.uuidString ?? "")
                .execute()
            dismiss()
        } catch {
            vm.archetype = prev
            self.error = "kaydedilemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Display helpers

    private var currentEmoji: String { emojiOf(vm.archetype ?? .dryroaster) }
    private var currentLabelOnly: String { labelOnlyOf(vm.archetype ?? .dryroaster) }

    private func emojiOf(_ a: ArchetypePrimary) -> String {
        String(a.label.first ?? "✨")
    }

    private func labelOnlyOf(_ a: ArchetypePrimary) -> String {
        let parts = a.label.split(separator: " ", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : a.label
    }

    private func shortDescription(_ a: ArchetypePrimary) -> String {
        switch a {
        case .dryroaster:          "kuru, kestirip atan. klişe sevmez."
        case .observer:            "önce izler, sonra konuşur. az ama net."
        case .softie_with_edges:   "sıcak yaklaşır ama sınır bilir."
        case .chaos_agent:         "risk, enerji, sıkıcılığı affetmez."
        case .strategist:          "3 hamle önden düşünür. duygu kontrol altında."
        case .romantic_pessimist:  "umut ile ironi karışımı. dilini kullanır."
        }
    }
}

extension ArchetypePrimary: CaseIterable {
    public static var allCases: [ArchetypePrimary] {
        [.dryroaster, .observer, .softie_with_edges, .chaos_agent, .strategist, .romantic_pessimist]
    }
}
