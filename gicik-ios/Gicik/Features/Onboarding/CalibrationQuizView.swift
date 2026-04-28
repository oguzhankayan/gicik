import SwiftUI

/// Quiz router — 6 cell tipi (single, binary, likert, slider, image_binary, free_text).
/// Multi_select_with_priority quiz.jsx'te yok ama backend'de var; basitçe single olarak tut, ileride geliştir.
struct CalibrationQuizView: View {
    @Bindable var vm: OnboardingViewModel
    @State private var selectedValues: Set<String> = []
    @State private var likertValue: Int = 3
    @State private var sliderValue: Double = 0.5
    @State private var freeText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                active: 1,
                total: 8,
                showClose: true,
                onBack: { vm.goToPreviousQuestion() }
            )

            if let q = vm.currentQuestion {
                content(for: q)
                    .id(q.id)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(AppAnimation.standard, value: vm.quizIndex)
        .onChange(of: vm.quizIndex) { _, _ in resetCellState() }
        .onAppear { resetCellState() }
    }

    @ViewBuilder
    private func content(for q: CalibrationQuestion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(String(format: "%02d", vm.quizIndex + 1)) / \(String(format: "%02d", vm.totalQuestions))")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.lime)

                Text(q.title)
                    .font(AppFont.display(26, weight: .bold))
                    .tracking(-0.02 * 26)
                    .foregroundColor(.white)
                    .lineSpacing(26 * 0.10)

                if let sub = q.subtitle, !sub.isEmpty {
                    Text(sub)
                        .font(AppFont.body(14))
                        .foregroundColor(AppColor.text60)
                        .padding(.top, -2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            // Cell content
            cell(for: q)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer()

            VStack(spacing: 14) {
                if let footer = q.footerLink {
                    Button {
                        if footer == "atla" || q.optional == true {
                            vm.skipCurrentQuestion()
                        }
                    } label: {
                        Text(footer)
                            .font(AppFont.body(13))
                            .foregroundColor(AppColor.text40)
                            .underline()
                    }
                }

                PrimaryButton("devam", isEnabled: canContinue(for: q)) {
                    saveAnswerAndContinue(for: q)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Cell rendering

    @ViewBuilder
    private func cell(for q: CalibrationQuestion) -> some View {
        switch q.type {
        case .singleSelect:
            singleSelectCell(options: q.options ?? [])
        case .binary, .imageBinary:
            binaryCell(options: q.options ?? [], stacked: q.type == .imageBinary)
        case .multiSelect, .multiSelectWithPriority:
            multiSelectCell(options: q.options ?? [])
        case .likert:
            likertCell(min: q.scaleMin ?? 1, max: q.scaleMax ?? 5, labels: q.scaleLabels ?? [])
        case .slider:
            sliderCell(minLabel: q.minLabel ?? "", maxLabel: q.maxLabel ?? "")
        case .freeText:
            freeTextCell(maxLength: q.maxLength ?? 500)
        }
    }

    private func singleSelectCell(options: [CalibrationOption]) -> some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.text) { opt in
                Button { selectedValues = [opt.text] } label: {
                    HStack {
                        Text(opt.text)
                            .font(AppFont.body(15))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 56)
                    .background(rowBackground(selected: selectedValues.contains(opt.text), radius: 14))
                }
                .sensoryFeedback(.selection, trigger: selectedValues)
            }
        }
    }

    private func binaryCell(options: [CalibrationOption], stacked: Bool) -> some View {
        let cardHeight: CGFloat = stacked ? 130 : 200

        let layout: AnyView = stacked
            ? AnyView(VStack(spacing: 12) {
                ForEach(options, id: \.text) { opt in
                    binaryCard(opt, cardHeight: cardHeight, stacked: true)
                }
            })
            : AnyView(LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                          GridItem(.flexible(), spacing: 12)],
                                spacing: 12) {
                ForEach(options, id: \.text) { opt in
                    binaryCard(opt, cardHeight: cardHeight, stacked: false)
                }
            })

        return layout
    }

    private func binaryCard(_ opt: CalibrationOption, cardHeight: CGFloat, stacked: Bool) -> some View {
        let key = opt.id ?? opt.text
        let isSelected = selectedValues.contains(key)
        return Button { selectedValues = [key] } label: {
            ZStack(alignment: stacked ? .leading : .topLeading) {
                rowBackground(selected: isSelected, radius: 18)
                    .frame(height: cardHeight)

                if stacked {
                    HStack(spacing: 16) {
                        Capsule()
                            .fill(isSelected ? AnyShapeStyle(AppColor.holographic) : AnyShapeStyle(AppColor.lime.opacity(0.6)))
                            .frame(width: 3)
                            .padding(.vertical, 18)
                        Text(opt.text)
                            .font(AppFont.body(18, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
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
                    .padding(.leading, 16)
                    .padding(.trailing, 20)
                } else {
                    VStack(alignment: .leading) {
                        if let e = opt.emoji {
                            Text(e).font(.system(size: 28))
                        }
                        Spacer()
                        Text(opt.text)
                            .font(AppFont.body(17, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(17 * 0.30)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(18)
                }
            }
            .frame(height: cardHeight)
        }
        .sensoryFeedback(.selection, trigger: selectedValues)
    }

    private func multiSelectCell(options: [CalibrationOption]) -> some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.text) { opt in
                Button {
                    if selectedValues.contains(opt.text) {
                        selectedValues.remove(opt.text)
                    } else {
                        selectedValues.insert(opt.text)
                    }
                } label: {
                    HStack {
                        Text(opt.text)
                            .font(AppFont.body(15))
                            .foregroundColor(.white)
                        Spacer()
                        if selectedValues.contains(opt.text) {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColor.lime)
                        }
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 56)
                    .background(rowBackground(selected: selectedValues.contains(opt.text), radius: 14))
                }
            }
        }
    }

    private func likertCell(min: Int, max: Int, labels: [String]) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(min...max, id: \.self) { n in
                    Button { likertValue = n } label: {
                        Circle()
                            .fill(likertValue == n
                                  ? AnyShapeStyle(AppColor.holographic)
                                  : AnyShapeStyle(Color.white.opacity(0.12)))
                            .frame(width: likertValue == n ? 28 : 18,
                                   height: likertValue == n ? 28 : 18)
                            .shadow(color: likertValue == n ? Color(hex: 0xFF0080, alpha: 0.4) : .clear, radius: 8)
                            .frame(maxWidth: .infinity)
                    }
                    .sensoryFeedback(.selection, trigger: likertValue)
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 8)

            HStack {
                if labels.count >= 1 { Text(labels[0]).foregroundColor(AppColor.text40) }
                Spacer()
                if labels.count >= 2 { Text(labels[1]).foregroundColor(AppColor.text40) }
                Spacer()
                if labels.count >= 3 { Text(labels[2]).foregroundColor(AppColor.text40) }
            }
            .font(AppFont.body(13))
            .padding(.horizontal, 4)
        }
    }

    private func sliderCell(minLabel: String, maxLabel: String) -> some View {
        VStack(spacing: 24) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 4)

                GeometryReader { geo in
                    Capsule()
                        .fill(AppColor.holographic)
                        .frame(width: geo.size.width * sliderValue, height: 4)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .shadow(color: Color(hex: 0xFF0080, alpha: 0.5), radius: 8)
                        .position(x: geo.size.width * sliderValue, y: 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    sliderValue = max(0, min(1, value.location.x / geo.size.width))
                                }
                        )
                }
                .frame(height: 28)
            }
            .frame(height: 28)
            .padding(.top, 30)

            HStack {
                Text(minLabel).foregroundColor(AppColor.text40)
                Spacer()
                Text(maxLabel).foregroundColor(AppColor.text40)
            }
            .font(AppFont.body(13))
        }
    }

    private func freeTextCell(maxLength: Int) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if freeText.isEmpty {
                    Text("son flört ettiğin uzun mesajdan bir parça…")
                        .font(AppFont.body(16))
                        .italic()
                        .foregroundColor(AppColor.text30)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                TextEditor(text: $freeText)
                    .font(AppFont.body(16))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .frame(minHeight: 160)
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.bg1.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppColor.text10, lineWidth: 1)
                    )
            )

            Text("\(freeText.count) / \(maxLength) KARAKTER")
                .font(AppFont.mono(11))
                .foregroundColor(AppColor.text40)
        }
    }

    // MARK: - Background helper

    private func rowBackground(selected: Bool, radius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(selected ? AppColor.bgGlass : AppColor.bg1.opacity(0.55))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(
                    selected ? AnyShapeStyle(AppColor.holographic) : AnyShapeStyle(AppColor.text08),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Save + advance

    private func canContinue(for q: CalibrationQuestion) -> Bool {
        if q.optional == true { return true }
        switch q.type {
        case .singleSelect, .binary, .imageBinary, .multiSelect, .multiSelectWithPriority:
            return !selectedValues.isEmpty
        case .likert, .slider:
            return true
        case .freeText:
            return true
        }
    }

    private func saveAnswerAndContinue(for q: CalibrationQuestion) {
        let answer: CalibrationAnswer
        switch q.type {
        case .singleSelect, .binary, .imageBinary, .multiSelect, .multiSelectWithPriority:
            answer = CalibrationAnswer(questionId: q.id, selected: Array(selectedValues), freeText: nil)
        case .likert:
            answer = CalibrationAnswer(questionId: q.id, selected: [String(likertValue)], freeText: nil)
        case .slider:
            answer = CalibrationAnswer(questionId: q.id, selected: [String(format: "%.2f", sliderValue)], freeText: nil)
        case .freeText:
            answer = CalibrationAnswer(questionId: q.id, selected: [], freeText: freeText.isEmpty ? nil : freeText)
        }
        vm.recordAnswer(answer)
        vm.nextQuestion()
    }

    private func resetCellState() {
        selectedValues = []
        likertValue = 3
        sliderValue = 0.5
        freeText = ""

        // Eğer bu soruya zaten cevap verilmişse restore et
        if let q = vm.currentQuestion, let prev = vm.quizAnswers[q.id] {
            switch q.type {
            case .singleSelect, .binary, .imageBinary, .multiSelect, .multiSelectWithPriority:
                selectedValues = Set(prev.selected)
            case .likert:
                if let v = prev.selected.first, let n = Int(v) { likertValue = n }
            case .slider:
                if let v = prev.selected.first, let f = Double(v) { sliderValue = f }
            case .freeText:
                freeText = prev.freeText ?? ""
            }
        }
    }
}

#Preview {
    CalibrationQuizView(vm: OnboardingViewModel())
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
