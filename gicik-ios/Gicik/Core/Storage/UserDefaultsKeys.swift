import Foundation

/// Type-safe UserDefaults keys.
enum UDKey: String {
    case onboardingCompleted = "gicik.onboarding.completed"
    case lastActiveDate = "gicik.lastActiveDate"
    case currentArchetype = "gicik.archetype.primary"
}

extension UserDefaults {
    func bool(_ key: UDKey) -> Bool { bool(forKey: key.rawValue) }
    func string(_ key: UDKey) -> String? { string(forKey: key.rawValue) }
    func date(_ key: UDKey) -> Date? { object(forKey: key.rawValue) as? Date }
    func set(_ value: Any?, _ key: UDKey) { set(value, forKey: key.rawValue) }
}
