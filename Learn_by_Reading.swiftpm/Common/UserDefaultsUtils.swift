import Foundation

struct UserDefaultsUtils {
    private static let onboardingKey = "lbr.app.onboarding"
    private static let helpKey = "lbr.app.help"
    
    static var hideOnboarding: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: onboardingKey)
        }
    }
    
    static var hideHelp: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: helpKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: helpKey)
        }
    }
}
