import SwiftUI

enum AppAnimation {
    /// Default spring — `.spring(response: 0.4, dampingFraction: 0.7)` (master prompt §4)
    static let standard = Animation.spring(response: 0.4, dampingFraction: 0.7)

    /// Ease-out-quart curve (tokens.css `ease-out-quart`)
    static let easeOutQuart = Animation.timingCurve(0.165, 0.84, 0.44, 1, duration: 0.4)

    /// Slow spin — orbital rings, 20s linear infinite
    static let spinSlow = Animation.linear(duration: 20).repeatForever(autoreverses: false)

    /// Pulse glow — 2.6s ease-in-out infinite (calibration intro center dot)
    static let pulseGlow = Animation.easeInOut(duration: 2.6).repeatForever()

    /// Shimmer skeleton — 1.6s linear infinite
    static let shimmer = Animation.linear(duration: 1.6).repeatForever(autoreverses: false)
}
