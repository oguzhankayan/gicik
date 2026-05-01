import Foundation

/// PostHog event isimleri — single source of truth.
/// Ekleme yaparken: snake_case, "kategori_action" formatı.
enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case demographicCompleted = "demographic_completed"
    case calibrationStarted = "calibration_started"
    case calibrationCompleted = "calibration_completed"
    case demoUploadShown = "demo_upload_shown"
    case notificationPermissionAsked = "notification_permission_asked"
    case notificationPermissionGranted = "notification_permission_granted"
    case aiConsentGiven = "ai_consent_given"

    // Paywall
    case paywallView = "paywall_view"
    case paywallPurchaseClicked = "paywall_purchase_clicked"
    case paywallPurchased = "paywall_purchased"
    case paywallDismissed = "paywall_dismissed"
    case paywallRestored = "paywall_restored"

    // Generation
    case modeSelected = "mode_selected"
    case screenshotPicked = "screenshot_picked"
    case toneSelected = "tone_selected"
    case generationStarted = "generation_started"
    case generationCompleted = "generation_completed"
    case generationFailed = "generation_failed"
    case replyCopied = "reply_copied"
    case feedbackPositive = "feedback_positive"
    case feedbackNegative = "feedback_negative"
    case regenerateClicked = "regenerate_clicked"

    // Free tier
    case softPaywallTriggered = "soft_paywall_triggered"

    // Errors
    case injectionDetected = "injection_detected"
    case rateLimited = "rate_limited"
}
