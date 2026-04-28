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
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(ArchetypePrimary.allCases, id: \.self) { arch in
                        archetypeCard(arch)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColor.text40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Text("ŞU ANKİ TARZIN")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)

            HStack(spacing: 10) {
                Text(currentEmoji)
                    .font(.system(size: 36))
                Text(currentLabelOnly)
                    .font(AppFont.display(28, weight: .bold))
                    .tracking(-0.02 * 28)
                    .foregroundColor(.white)
            }

            Text("aşağıdaki tarzlardan istediğini seçebilirsin.")
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func archetypeCard(_ arch: ArchetypePrimary) -> some View {
        let isSelected = selected == arch
        return Button {
            withAnimation(AppAnimation.standard) {
                selected = arch
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Text(emojiOf(arch))
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text(labelOnlyOf(arch))
                        .font(AppFont.display(18, weight: .bold))
                        .tracking(-0.02 * 18)
                        .foregroundColor(.white)
                    Text(shortDescription(arch))
                        .font(AppFont.body(13))
                        .foregroundColor(AppColor.text60)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(13 * 0.30)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                if isSelected {
                    Circle()
                        .fill(AppColor.lime)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColor.bg0)
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isSelected ? AppColor.bgGlass : AppColor.bg1.opacity(0.55))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(AppColor.holographic) : AnyShapeStyle(AppColor.text08),
                            lineWidth: 1
                        )
                }
            )
        }
        .sensoryFeedback(.selection, trigger: selected)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            if let error {
                Text(error)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.danger)
                    .multilineTextAlignment(.center)
            }
            PrimaryButton("kaydet", isEnabled: selected != vm.archetype && !saving) {
                Task { await save() }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 32)
    }

    // MARK: - Save

    private func save() async {
        saving = true
        defer { saving = false }
        error = nil

        // Local update — opportunistic, UX rollback if backend fails
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
            // Rollback
            vm.archetype = prev
            self.error = "kaydedilemedi: \(error.localizedDescription)"
        }
    }

    // MARK: - Display helpers

    private var currentEmoji: String { emojiOf(vm.archetype ?? .dryroaster) }
    private var currentLabelOnly: String { labelOnlyOf(vm.archetype ?? .dryroaster) }

    private func emojiOf(_ a: ArchetypePrimary) -> String {
        // Master labels start with emoji + space + name, e.g. "🥀 GICIK"
        String(a.label.first ?? "✨")
    }

    private func labelOnlyOf(_ a: ArchetypePrimary) -> String {
        // Strip emoji + space prefix
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
