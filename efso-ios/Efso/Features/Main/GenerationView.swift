import SwiftUI
import UIKit

/// Refined-y2k generation loading — chrome chrome ring + italic "düşünüyor." +
/// 5-line process checklist. Streaming arrived → asistan observation pull-quote +
/// reply stack. Failure → italic "tutmadı" + retry.
struct GenerationView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    @State private var firstReplyHapticFired = false
    @State private var typewriterDone = false

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if vm.generationPhase == .failed {
                failureBlock
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
            } else if vm.streamingObservation.isEmpty {
                parsingActivity
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            } else {
                streamingContent
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppAnimation.standard, value: vm.streamingObservation.isEmpty)
        .animation(AppAnimation.standard, value: vm.streamingReplies.count)
        .sensoryFeedback(.impact(weight: .medium), trigger: firstReplyHapticFired)
        .onChange(of: vm.streamingReplies.count) { _, newCount in
            if newCount == 1 && !firstReplyHapticFired {
                firstReplyHapticFired = true
            }
        }
        .onChange(of: vm.generationPhase) { _, phase in
            if phase == .parsing {
                firstReplyHapticFired = false
                typewriterDone = false
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Text("× iptal")
                    .font(AppFont.mono(12))
                    .tracking(0.10 * 12)
                    .foregroundColor(AppColor.text60)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("iptal")
            Spacer()
            EfsoTag("\(mode.label.trLower) · \(toneLabel)", color: AppColor.text40)
            Spacer()
            Color.clear.frame(width: 60, height: 44)
        }
        .padding(.top, 4)
    }

    private var toneLabel: String { vm.selectedTone?.label.trLower ?? "üç ton" }

    // MARK: - Parsing activity

    private var parsingActivity: some View {
        VStack(spacing: 0) {
            Spacer()
            chromeRing
                .frame(width: 110, height: 110)
            Text("düşünüyor.")
                .font(AppFont.displayItalic(28, weight: .regular))
                .tracking(-0.025 * 28)
                .foregroundColor(AppColor.ink)
                .padding(.top, 32)
            Text("~3 saniye")
                .font(AppFont.mono(11))
                .tracking(0.14 * 11)
                .foregroundColor(AppColor.text60)
                .padding(.top, 4)
            Spacer()
            checklist
                .padding(.bottom, 20)
        }
    }

    private var chromeRing: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSinceReferenceDate
            let angle = (elapsed.truncatingRemainder(dividingBy: 2.0) / 2.0) * 360
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppColor.holographic, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(angle))
                Text("e")
                    .font(AppFont.displayItalic(36))
                    .foregroundColor(AppColor.ink)
            }
        }
    }

    private struct Step { let label: String; let done: Bool; let active: Bool }

    private var steps: [Step] {
        let p = vm.generationPhase
        let isTextOnly = mode == .tonla
        return [
            Step(label: isTextOnly ? "metin analiz ediliyor" : "görsel okunuyor", done: p != .parsing, active: false),
            Step(label: "bağlam çıkarılıyor", done: p != .parsing, active: false),
            Step(label: "arketip eşleniyor", done: p == .streaming || p == .finishing, active: false),
            Step(label: "üç ton hazırlanıyor", done: p == .finishing, active: p == .streaming),
            Step(label: "ince ayar", done: false, active: p == .finishing),
        ]
    }

    private var checklist: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { idx, s in
                HStack(spacing: 12) {
                    Circle()
                        .fill(s.done ? AppColor.accent : (s.active ? AppColor.pop : AppColor.bg2))
                        .frame(width: 8, height: 8)
                        .shadow(color: s.active ? AppColor.pop.opacity(0.6) : .clear, radius: 6)
                    Text(s.label)
                        .font(AppFont.body(13.5))
                        .foregroundColor(s.done ? AppColor.text40 : (s.active ? AppColor.ink : AppColor.text40))
                        .strikethrough(s.done, color: AppColor.text20)
                    Spacer()
                    if s.done {
                        Text("✓").font(AppFont.mono(12)).foregroundColor(AppColor.accent)
                    }
                }
                .padding(.vertical, 10)
                .accessibilityValue(s.done ? "tamamlandı" : (s.active ? "devam ediyor" : "bekliyor"))
                .overlay(alignment: .bottom) {
                    if idx < steps.count - 1 {
                        Rectangle().fill(AppColor.text10).frame(height: 1)
                    }
                }
            }
        }
    }

    // MARK: - Streaming content

    private var streamingContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                AssistantObservationCard(text: vm.streamingObservation, fontSize: 18)
                replyStack
            }
            .padding(.bottom, 24)
        }
    }

    private var replyStack: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { idx in
                if let r = vm.streamingReplies[idx] {
                    ReplyCard(
                        toneAngle: r.toneLabel,
                        text: r.text,
                        isPrimary: idx == 0,
                        isCopied: false,
                        onCopy: {
                            UIPasteboard.general.string = r.text
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }

    // MARK: - Failure

    private var failureBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            EfsoTag("tutmadı", color: AppColor.danger, dot: true, dotColor: AppColor.danger)
            Text(vm.lastError.map { humanize($0) } ?? "bağlantı sorunu. tekrar dener misin")
                .font(AppFont.displayItalic(20, weight: .regular))
                .foregroundColor(AppColor.ink)
                .lineSpacing(20 * 0.30)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button { vm.regenerate() } label: {
                    Text("yeniden dene")
                        .font(AppFont.mono(12))
                        .tracking(0.10 * 12)
                        .foregroundColor(AppColor.bg0)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(AppColor.ink))
                }
                Button { vm.backToHome() } label: {
                    Text("vazgeç")
                        .font(AppFont.mono(12))
                        .tracking(0.10 * 12)
                        .foregroundColor(AppColor.text60)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.bg1)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColor.text10, lineWidth: 1)
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
        return "üretim tutmadı. \n\n[debug] \(raw)"
        #else
        return "üretim tutmadı. tekrar dener misin"
        #endif
    }
}
