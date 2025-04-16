import Translation

class TranslationHelper {
    let source: Locale.Language = Locale.Language(identifier: "zh-cn")
    let target: Locale.Language = Locale.Language(identifier: "en-us")
    
    init() {
        
    }
    
    func translationIsSupported(from source: Locale.Language, to target: Locale.Language) async -> Bool {
        let availability = LanguageAvailability()
        let status = await availability.status(from: source, to: target)
        switch status {
            case .installed, .supported:
                return true
            case .unsupported:
                return false
            default:
                return false
        }
    }
}
