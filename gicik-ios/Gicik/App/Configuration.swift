import Foundation

/// Environment configuration. Reads from Info.plist (which xcconfig populates).
/// xcconfig dosyaları repo'da değil — `.xcconfig.template` ile çoğalt, gerçek key'ler local.
enum Configuration {
    static let supabaseURL: URL = {
        guard let s = infoString("SUPABASE_URL"), let url = URL(string: s) else {
            fatalError("SUPABASE_URL missing in Info.plist (set via xcconfig)")
        }
        return url
    }()

    static let supabaseAnonKey: String = {
        guard let s = infoString("SUPABASE_ANON_KEY"), !s.isEmpty else {
            fatalError("SUPABASE_ANON_KEY missing in Info.plist")
        }
        return s
    }()

    static let revenueCatAPIKey: String = infoString("REVENUECAT_API_KEY") ?? ""
    static let posthogAPIKey: String = infoString("POSTHOG_API_KEY") ?? ""
    static let posthogHost: String = infoString("POSTHOG_HOST") ?? "https://eu.posthog.com"
    static let mixpanelToken: String = infoString("MIXPANEL_TOKEN") ?? ""
    static let sentryDSN: String = infoString("SENTRY_DSN") ?? ""

    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "to.tikla.gicik"
    }

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    private static func infoString(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}
