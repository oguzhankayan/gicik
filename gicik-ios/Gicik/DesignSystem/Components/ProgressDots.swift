import SwiftUI

/// Top bar progress indicator. Active dot 16x6, inactive 6x6.
struct ProgressDots: View {
    let total: Int
    let active: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == active ? Color.white : AppColor.text20)
                    .frame(width: index == active ? 16 : 6, height: 6)
                    .animation(AppAnimation.standard, value: active)
            }
        }
    }
}
