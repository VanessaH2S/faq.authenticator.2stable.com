import Foundation

struct LocaleValidator {
    private static let validLocaleIdentifiers: Set<String> = {
        /// Make sure locales are in the correct format as per [RFC 5646](https://datatracker.ietf.org/doc/html/rfc5646)
        var correctedLocaleIdentifiers = Locale.availableIdentifiers.map { $0.replacingOccurrences(of: "_", with: "-") }

        /// Append missing locales not by default included
        correctedLocaleIdentifiers.append(contentsOf: [
            "zh-CN",
            "zh-HK",
            "zh-TW"
        ])

        return Set(correctedLocaleIdentifiers)
    }()

    /// Checks if given locale is present in Locale.availableIdentifiers
    private static func validate(locale: String) -> Bool {
        return LocaleValidator.validLocaleIdentifiers.contains(locale)
    }
    
    static func parse(_ string: String) throws -> Locale {
        guard Self.validate(locale: string) else {
            throw "Invalid locale \(string)"
        }
        
        return Locale(identifier: string)
    }
}
