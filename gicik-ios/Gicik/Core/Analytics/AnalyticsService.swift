import Foundation
import PostHog
import Mixpanel

/// Tek noktadan event log + identify. PostHog (feature flags + funnel) +
/// Mixpanel (event log).
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func bootstrap() {
        // PostHog
        let phConfig = PostHogConfig(apiKey: Configuration.posthogAPIKey, host: Configuration.posthogHost)
        phConfig.captureScreenViews = false
        PostHogSDK.shared.setup(phConfig)

        // Mixpanel
        if !Configuration.mixpanelToken.isEmpty {
            Mixpanel.initialize(token: Configuration.mixpanelToken, trackAutomaticEvents: false)
        }
    }

    func identify(userID: UUID, archetype: String? = nil) {
        var props: [String: Any] = ["app_version": Configuration.appVersion]
        if let archetype { props["archetype"] = archetype }

        PostHogSDK.shared.identify(userID.uuidString, userProperties: props)
        Mixpanel.mainInstance().identify(distinctId: userID.uuidString)
        Mixpanel.mainInstance().people.set(properties: props.mapValues { $0 as? MixpanelType ?? "" })
    }

    func track(_ event: AnalyticsEvent, properties: [String: Any] = [:]) {
        PostHogSDK.shared.capture(event.rawValue, properties: properties)
        let mpProps = properties.compactMapValues { $0 as? MixpanelType }
        Mixpanel.mainInstance().track(event: event.rawValue, properties: mpProps)
    }

    func reset() {
        PostHogSDK.shared.reset()
        Mixpanel.mainInstance().reset()
    }
}
