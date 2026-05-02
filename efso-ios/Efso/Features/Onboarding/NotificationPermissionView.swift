import SwiftUI
import UserNotifications

/// Full-bleed bildirim izin ekranı — ValueIntroView ile aynı layout/tipografi sistemi.
/// Hero görsel arka planda, üstte copy bloğu, altta tek primary CTA.
struct NotificationPermissionView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: AppSpacing.lg) {
                copyBlock
                HoloPrimaryButton(title: "izin ver") {
                    Task { await requestPermission() }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                backgroundImage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [AppColor.bg0.opacity(0.88), AppColor.bg0.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 260)
                .frame(maxHeight: .infinity, alignment: .top)

                LinearGradient(
                    colors: [.clear, AppColor.bg0.opacity(0.55), AppColor.bg0.opacity(0.97)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea()
        )
    }

    private var copyBlock: some View {
        Text("bildirimlere izin ver")
            .font(AppFont.displayItalic(38, weight: .regular))
            .tracking(-0.03 * 38)
            .foregroundColor(AppColor.ink)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, AppSpacing.lg)
    }

    private var backgroundImage: some View {
        Image("notification-bg")
            .resizable()
            .scaledToFill()
    }

    @MainActor
    private func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            vm.notificationGranted = granted
        } catch {
            vm.notificationGranted = false
        }
        vm.advance()
    }
}

#Preview {
    NotificationPermissionView(vm: OnboardingViewModel())
        .preferredColorScheme(.dark)
}
