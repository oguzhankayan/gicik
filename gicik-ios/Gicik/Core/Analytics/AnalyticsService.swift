import Foundation
import PostHog
import Mixpanel

/// Tek noktadan event log + identify. PostHog (feature flags + funnel) +
/// Mixpanel (event log).
///
/// API key'ler boşsa SDK'lar HİÇ init edilmez — boş init PostHog/Mixpanel
/// tarafında batch retry'ları başlatıyor ve simulator'da launch hang'ine
/// sebep olabiliyor.
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    private var posthogReady = false
    private var mixpanelReady = false

    func bootstrap() {
        // PostHog — sadece key varsa
        let phKey = Configuration.posthogAPIKey
        if !phKey.isEmpty {
            let phConfig = PostHogConfig(apiKey: phKey, host: Configuration.posthogHost)
            phConfig.captureScreenViews = false
            PostHogSDK.shared.setup(phConfig)
            posthogReady = true
        }

        // Mixpanel — sadece token varsa
        let mpToken = Configuration.mixpanelToken
        if !mpToken.isEmpty {
            Mixpanel.initialize(token: mpToken, trackAutomaticEvents: false)
            mixpanelReady = true
        }
    }

    func identify(userID: UUID, archetype: String? = nil) {
        var props: [String: Any] = ["app_version": Configuration.appVersion]
        if let archetype { props["archetype"] = archetype }

        if posthogReady {
            PostHogSDK.shared.identify(userID.uuidString, userProperties: props)
        }
        if mixpanelReady {
            Mixpanel.mainInstance().identify(distinctId: userID.uuidString)
            Mixpanel.mainInstance().people.set(properties: props.mapValues { $0 as? MixpanelType ?? "" })
        }
    }

    func track(_ event: AnalyticsEvent, properties: [String: Any] = [:]) {
        if posthogReady {
            PostHogSDK.shared.capture(event.rawValue, properties: properties)
        }
        if mixpanelReady {
            let mpProps = properties.compactMapValues { $0 as? MixpanelType }
            Mixpanel.mainInstance().track(event: event.rawValue, properties: mpProps)
        }
    }

    func reset() {
        if posthogReady { PostHogSDK.shared.reset() }
        if mixpanelReady { Mixpanel.mainInstance().reset() }
    }
}
