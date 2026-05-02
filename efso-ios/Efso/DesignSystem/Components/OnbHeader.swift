import SwiftUI

/// Refined onboarding header — back arrow + holographic progress bar + step counter.
/// Eski TopBar (progress dots) ile birlikte yaşar; yeni ekranlar bunu kullanır.
struct OnbHeader: View {
    let step: Int
    let total: Int
    var showBack: Bool = true
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 14) {
            Button(action: { onBack?() }) {
                Text("← geri")
                    .font(AppFont.mono(12))
                    .tracking(0.10 * 12)
                    .foregroundColor(AppColor.text60)
            }
            .opacity(showBack ? 1 : 0)
            .disabled(!showBack)
            .accessibilityLabel("geri")

            // progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.bg2)
                        .frame(height: 2)
                    Capsule()
                        .fill(AppColor.holographic)
                        .frame(width: max(0, geo.size.width * progress), height: 2)
                }
            }
            .frame(height: 2)

            Text(counterLabel)
                .font(AppFont.mono(11))
                .tracking(0.14 * 11)
                .foregroundColor(AppColor.text40)
                .frame(width: 44, alignment: .trailing)
                .accessibilityLabel("\(step) / \(total)")
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(step) / CGFloat(total)
    }

    private var counterLabel: String {
        let s = String(format: "%02d", step)
        let t = String(format: "%02d", total)
        return "\(s)/\(t)"
    }
}
