import SwiftUI
import UserNotifications

/// Notification permission — envelope hero + "izin ver" / "şimdi değil"
/// design-source/parts/onboard2.jsx → NotificationPermission
struct NotificationPermissionView: View {
    @Bindable var vm: OnboardingViewModel
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 6, total: 8, showBack: false)

            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: 0xFF0080, alpha: 0.5), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 24)
                    .scaleEffect(isPulsing ? 1.06 : 1.0)
                    .opacity(isPulsing ? 1.0 : 0.65)

                envelope
                    .frame(width: 120, height: 90)
            }

            Text("gıcık sana\nhaber versin")
                .font(AppFont.display(28, weight: .bold))
                .tracking(-0.02 * 28)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(28 * 0.05)
                .padding(.top, 36)

            Text("yeni mod geldiğinde, prompt güncellendiğinde,\nya da tarzına bir şey eklediğimizde.\nseyrek. sıkıcı değil.")
                .font(AppFont.body(15))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .lineSpacing(15 * 0.45)
                .padding(.horizontal, 28)
                .padding(.top, 14)

            Spacer()

            VStack(spacing: 14) {
                PrimaryButton("izin ver") {
                    Task { await requestPermission() }
                }
                .padding(.horizontal, 24)

                Button("şimdi değil") {
                    vm.notificationGranted = false
                    vm.advance()
                }
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text40)
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(AppAnimation.pulseGlow) {
                isPulsing = true
            }
        }
    }

    private var envelope: some View {
        // Simple envelope SVG-like
        Image(systemName: "envelope")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.white.opacity(0.8))
            .symbolRenderingMode(.monochrome)
    }

    @MainActor
    private func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            vm.notificationGranted = granted
            vm.advance()
        } catch {
            vm.notificationGranted = false
            vm.advance()
        }
    }
}

#Preview {
    NotificationPermissionView(vm: OnboardingViewModel())
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
