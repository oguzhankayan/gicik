import UIKit
import UserNotifications

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Push notification token (Phase 7'de Supabase'a yazılır)
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        // TODO: send to backend (Phase 7)
        _ = token
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Sentry log
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground'da bildirim göster
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handler([.banner, .sound, .badge])
    }
}
