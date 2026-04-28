import SwiftUI

/// Main shell — top archetype banner, 5 mode grid, recent history scroll.
/// design-source/parts/main.jsx → Home
struct HomeView: View {
    @State private var vm = HomeViewModel()
    @State private var showProfile = false
    @State private var showArchetypeSwitcher = false

    var body: some View {
        ZStack {
            switch vm.stage {
            case .home:
                homeContent
            case .picker(let mode):
                ScreenshotPickerView(vm: vm, mode: mode)
            case .generation(let mode, _):
                GenerationView(vm: vm, mode: mode)
            case .result(let result):
                ResultView(vm: vm, result: result)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppAnimation.standard, value: stageKey)
    }

    private var stageKey: String {
        switch vm.stage {
        case .home: "home"
        case .picker(let m): "picker-\(m.rawValue)"
        case .generation(let m, _): "gen-\(m.rawValue)"
        case .result: "result"
        }
    }

    // MARK: - Home content

    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBar
                modesHeader.padding(.top, 28)
                modesGrid.padding(.top, 8)
                historySection.padding(.top, 24)
                Spacer(minLength: 40)
            }
        }
        .sheet(isPresented: $showArchetypeSwitcher) {
            ArchetypeSwitcherSheet(vm: vm)
                .presentationDetents([.large])
                .presentationBackground(AppColor.bg0)
        }
    }

    private var topBar: some View {
        HStack {
            // Archetype avatar — tap opens switcher sheet
            Button { showArchetypeSwitcher = true } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.bg2.opacity(0.7))
                    Circle()
                        .strokeBorder(AppColor.holographic, lineWidth: 1)
                    Text(archetypeEmoji)
                        .font(.system(size: 18))
                }
                .frame(width: 36, height: 36)
            }
            Spacer()
            Logo(size: 26)
            Spacer()
            Button { showProfile = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(AppColor.text60)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 58)
    }

    private var archetypeBanner: some View {
        HStack {
            Text("\(archetypeEmoji) gıcık seni \(archetypeShortLabel) olarak biliyor")
                .font(AppFont.body(14))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColor.text40)
        }
        .padding(.horizontal, 18)
        .frame(height: 46)
        .background(
            ZStack {
                Capsule().fill(AppColor.bg1.opacity(0.6))
                Capsule().strokeBorder(AppColor.holographic, lineWidth: 1).opacity(0.7)
            }
        )
        .padding(.horizontal, 24)
    }

    private var modesHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MODLAR")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)
            Text("BUGÜN NE DENEYECEKSİN?")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var modesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)],
                  spacing: 10) {
            ForEach(Mode.allCases) { mode in
                modeCard(mode: mode, locked: false)
                    .onTapGesture { vm.selectMode(mode) }
            }
            // Locked "yakında" placeholder
            modeCardPlaceholder
        }
        .padding(.horizontal, 24)
    }

    private func modeCard(mode: Mode, locked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: mode.systemIcon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.label)
                    .font(AppFont.display(18, weight: .bold))
                    .tracking(-0.02 * 18)
                    .foregroundColor(.white)
                Text(mode.subtitle)
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text60)
            }
        }
        .padding(16)
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.bg1.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(AppColor.text08, lineWidth: 1)
                )
        )
        .opacity(locked ? 0.45 : 1)
        .sensoryFeedback(.impact(weight: .light), trigger: vm.stage)
    }

    private var modeCardPlaceholder: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "lock")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("YAKINDA")
                    .font(AppFont.display(18, weight: .bold))
                    .tracking(-0.02 * 18)
                    .foregroundColor(.white)
                Text("yeni mod")
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text60)
            }
        }
        .padding(16)
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColor.bg1.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .strokeBorder(AppColor.text08, lineWidth: 1)
                )
        )
        .opacity(0.45)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SON KULLANIM")
                .font(AppFont.mono(11))
                .tracking(0.04 * 11)
                .foregroundColor(AppColor.lime)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if vm.history.isEmpty {
                        Text("ilk kullanımdan sonra burada görünecek.")
                            .font(AppFont.body(13))
                            .italic()
                            .foregroundColor(AppColor.text40)
                            .padding(12)
                    } else {
                        ForEach(vm.history) { item in
                            historyCard(item)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func historyCard(_ item: ConversationHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(item.platform.uppercased()) · \(item.relativeTime)")
                .font(AppFont.mono(10))
                .foregroundColor(AppColor.text40)
            Text(item.mode.rawValue.uppercased())
                .font(AppFont.display(13, weight: .bold))
                .tracking(-0.02 * 13)
                .foregroundColor(.white)
                .padding(.top, 4)
            Text(item.snippet)
                .font(AppFont.body(11))
                .foregroundColor(AppColor.text60)
                .lineSpacing(11 * 0.30)
                .lineLimit(3)
        }
        .padding(12)
        .frame(width: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
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
        return (parts.last.map(String.init) ?? "").lowercased()
    }
}

#Preview {
    HomeView()
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
