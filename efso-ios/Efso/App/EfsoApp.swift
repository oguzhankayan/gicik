import SwiftUI
import Sentry

@main
struct EfsoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        bootstrapSentry()
        bootstrapAnalytics()
        bootstrapRevenueCat()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(AppColor.pink)
        }
    }

    // MARK: - Bootstrap

    private func bootstrapSentry() {
        guard !Configuration.sentryDSN.isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = Configuration.sentryDSN
            options.debug = Configuration.isDebug
            options.tracesSampleRate = Configuration.isDebug ? 1.0 : 0.2
            options.environment = Configuration.isDebug ? "development" : "production"
            options.releaseName = "efso@\(Configuration.appVersion)+\(Configuration.buildNumber)"
            // PII KVKK gereği default kapalı; e-mail/IP otomatik attach yok.
            options.sendDefaultPii = false
            // Server error body'leri ham olarak APIError.server(message:)'e
            // düşüyor; breadcrumb leak olmasın diye 500 char'la kırp.
            options.beforeSend = { event in
                if let msg = event.message?.formatted, msg.count > 500 {
                    event.message = SentryMessage(formatted: String(msg.prefix(500)) + "…[trunc]")
                }
                // breadcrumb data'da uzun string varsa truncate
                event.breadcrumbs = event.breadcrumbs?.map { crumb in
                    if let data = crumb.data {
                        crumb.data = data.mapValues { value in
                            if let s = value as? String, s.count > 200 {
                                return String(s.prefix(200)) + "…[trunc]"
                            }
                            return value
                        }
                    }
                    return crumb
                }
                return event
            }
        }
    }

    @MainActor
    private func bootstrapAnalytics() {
        AnalyticsService.shared.bootstrap()
    }

    @MainActor
    private func bootstrapRevenueCat() {
        SubscriptionManager.shared.bootstrap()
    }
}
