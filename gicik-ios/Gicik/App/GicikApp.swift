import SwiftUI
import Sentry

@main
struct GicikApp: App {
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
            options.releaseName = "gicik@\(Configuration.appVersion)+\(Configuration.buildNumber)"
        }
    }

    private func bootstrapAnalytics() {
        AnalyticsService.shared.bootstrap()
    }

    private func bootstrapRevenueCat() {
        // RevenueCat init Phase 4'te eklenir.
        // Purchases.configure(withAPIKey: Configuration.revenueCatAPIKey)
    }
}
