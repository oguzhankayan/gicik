import SwiftUI
import UserNotifications

/// Notification permission — cinematic 3D bell + shake.
/// Rizz playbook: tek hareketli element, drama, kısa copy.
struct NotificationPermissionView: View {
    @Bindable var vm: OnboardingViewModel

    @State private var bellPulse = false
    @State private var shake: CGFloat = 0
    @State private var badgeIn = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(active: 7, total: 12, showBack: false)

            Spacer()

            ZStack {
                // glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.pink.opacity(0.55), AppColor.purple.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .blur(radius: 40)
                    .scaleEffect(bellPulse ? 1.08 : 0.92)

                // 3D bell — symbol katmanları ile fake depth
                ZStack {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 110, weight: .black))
                        .foregroundStyle(AppColor.purple.opacity(0.55))
                        .blur(radius: 18)
                        .offset(y: 12)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 96, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.16))
                        .offset(y: 6)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 92, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(color: AppColor.pink.opacity(0.7), radius: 18)
                }
                .rotationEffect(.degrees(shake))
                .scaleEffect(bellPulse ? 1.0 : 0.96)

                // unread badge
                Circle()
                    .fill(AppColor.pink)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Text("1")
                            .font(AppFont.body(13, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: AppColor.pink.opacity(0.7), radius: 12)
                    .offset(x: 38, y: -42)
                    .scaleEffect(badgeIn ? 1 : 0)
                    .opacity(badgeIn ? 1 : 0)
            }
            .frame(width: 240, height: 240)

            Text("haber\nverelim mi?")
                .font(AppFont.display(30, weight: .bold))
                .tracking(-0.02 * 30)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(30 * 0.05)
                .padding(.top, 32)

            Text("yeni mod, taze ton, tarzına eklenen şey.\nseyrek. sıkıcı değil.")
                .font(AppFont.body(15))
                .foregroundColor(AppColor.text60)
                .multilineTextAlignment(.center)
                .lineSpacing(15 * 0.4)
                .padding(.horizontal, 32)
                .padding(.top, 12)

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
        .task {
            await runIntro()
        }
    }

    private func runIntro() async {
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            bellPulse = true
        }
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
            badgeIn = true
        }
        try? await Task.sleep(for: .milliseconds(150))
        // shake sequence
        for delta in [-12.0, 10.0, -8.0, 6.0, -4.0, 0.0] {
            withAnimation(.spring(response: 0.18, dampingFraction: 0.4)) {
                shake = delta
            }
            try? await Task.sleep(for: .milliseconds(90))
        }
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
