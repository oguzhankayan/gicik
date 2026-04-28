import SwiftUI

/// Tone selector — 5 tone cards, archetype-based default highlight.
/// design-source/parts/main.jsx → ToneSelector
struct ToneSelectorView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode
    @State private var selected: Tone? = nil

    private var defaultTone: Tone { Tone.recommended(for: vm.archetype) }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
            ObservationCard(text: observationText)
                .padding(.horizontal, 24)
                .padding(.top, 18)
            toneList
                .padding(.top, 18)
            Spacer()
            PrimaryButton("üret", isEnabled: selected != nil) {
                guard let s = selected else { return }
                vm.selectTone(s)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { if selected == nil { selected = defaultTone } }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button { vm.stage = .picker(mode); vm.pickerState = .done(thumbnail: vm.pickedScreenshot ?? Data()) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            Text("\(mode.label.lowercased()) › ton seç")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text40)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("NE TONDA\nKONUŞACAĞIZ?")
                .font(AppFont.display(24, weight: .bold))
                .tracking(-0.02 * 24)
                .foregroundColor(.white)
                .lineSpacing(24 * 0.05)
            Spacer()
            // Mini screenshot thumbnail
            screenshotThumb
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var screenshotThumb: some View {
        ZStack {
            if case .tone(_, let data) = vm.stage, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 80)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColor.bg1)
            }
        }
        .frame(width: 60, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(AppColor.text10, lineWidth: 1)
        )
    }

    private var observationText: String {
        // Phase 2.4'te backend Stage 1 parse_result'tan gelir.
        "konuşmaya bakınca sıcak çıkan bir hat var. flörtöz işler ama esprili daha güvenli."
    }

    private var toneList: some View {
        VStack(spacing: 10) {
            ForEach(Tone.allCases) { tone in
                toneCard(tone)
            }
        }
        .padding(.horizontal, 24)
    }

    private func toneCard(_ tone: Tone) -> some View {
        let isSelected = selected == tone
        let isRecommended = tone == defaultTone

        return Button {
            selected = tone
        } label: {
            HStack(spacing: 14) {
                // Lime stripe (only when selected)
                if isSelected {
                    Capsule()
                        .fill(AppColor.lime)
                        .frame(width: 3)
                        .padding(.vertical, 14)
                }

                Text(tone.emoji).font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text(tone.label)
                        .font(AppFont.display(16, weight: .bold))
                        .tracking(-0.02 * 16)
                        .foregroundColor(.white)
                    Text(tone.description)
                        .font(AppFont.body(12))
                        .foregroundColor(AppColor.text60)
                }
                Spacer()
                if isRecommended {
                    Text("ÖNERİLEN")
                        .font(AppFont.mono(10))
                        .tracking(0.04 * 10)
                        .foregroundColor(AppColor.lime)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .overlay(
                            Capsule().strokeBorder(AppColor.lime.opacity(0.4), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 72)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? AppColor.bgGlass : AppColor.bg1.opacity(0.55))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(AppColor.holographic) : AnyShapeStyle(AppColor.text08),
                            lineWidth: 1
                        )
                }
            )
        }
        .sensoryFeedback(.selection, trigger: selected)
    }
}
