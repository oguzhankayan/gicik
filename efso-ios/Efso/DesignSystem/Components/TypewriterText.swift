import SwiftUI

/// Karakter karakter beliren metin. Loading skeleton'unun yerine geçer:
/// asistan sesi *kendisi* yükleme deneyimi olur.
///
/// Mekanik: `text` setlendiği an `revealed` 0'dan total karakter sayısına
/// linear bir Task ile ilerler (~22ms/char insan okuma hızında). `text`
/// değişirse reset olur ve yeniden başlar.
///
/// Caret: `showCaret` true ise yazma sürerken *ve* yazma bittikten sonra
/// (parent'ın belirlediği koşula kadar) blink eder. Parent typewriter
/// bittiğinde + content geldiğinde caret'i kapatır.
struct TypewriterText: View {
    let text: String
    let font: Font
    let color: Color
    let charDelayMs: UInt64
    var showCaret: Bool = true
    /// Yazma tamamlandığında parent'a haber verir (parent caret'i kapatabilsin
    /// veya sıradaki animasyonu tetikleyebilsin diye).
    var onComplete: (() -> Void)? = nil

    @State private var revealed: Int = 0
    @State private var caretOn: Bool = true
    @State private var revealTask: Task<Void, Never>? = nil

    init(
        text: String,
        font: Font,
        color: Color = .white.opacity(0.85),
        charDelayMs: UInt64 = 22,
        showCaret: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.charDelayMs = charDelayMs
        self.showCaret = showCaret
        self.onComplete = onComplete
    }

    var body: some View {
        // String.Index aritmetiği için prefix kullanalım — emoji/grapheme safe.
        let visible = String(text.prefix(revealed))
        let isDone = revealed >= text.count

        (
            Text(visible)
                .font(font)
                .foregroundColor(color)
            +
            Text(showCaret && (isDone ? caretOn : true) ? "▎" : " ")
                .font(font)
                .foregroundColor(AppColor.lime)
        )
        .lineSpacing(6)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear { startReveal() }
        .onChange(of: text) { _, _ in startReveal() }
        .onChange(of: showCaret) { _, newValue in
            if !newValue { caretOn = false }
        }
        .task(id: "caret-\(text.hashValue)") {
            // Caret blink — yazma bittikten sonra da görünür kalsın istiyoruz
            // (parent showCaret'i false yapana kadar).
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(530))
                if Task.isCancelled { break }
                caretOn.toggle()
            }
        }
    }

    private func startReveal() {
        revealTask?.cancel()
        revealed = 0
        guard !text.isEmpty else {
            onComplete?()
            return
        }
        revealTask = Task { @MainActor in
            for i in 1...text.count {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .milliseconds(charDelayMs))
                if Task.isCancelled { return }
                revealed = i
            }
            onComplete?()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        TypewriterText(
            text: "üç gün cevap yok, sonra 'selam'. yazmamış sayılır.",
            font: AppFont.body(18).italic()
        )
        TypewriterText(
            text: "ekran açık. dört mesaj. üçü onun.",
            font: AppFont.body(18).italic(),
            charDelayMs: 30
        )
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
