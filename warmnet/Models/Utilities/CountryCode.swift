import Foundation

struct CountryCode: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    
    var displayName: String {
        "\(flag) \(code)"
    }
    
    var fullDisplayName: String {
        "\(flag) \(name) (\(code))"
    }
    
    static let all: [CountryCode] = [
        CountryCode(code: "+1", name: "United States", flag: "🇺🇸"),
        CountryCode(code: "+1", name: "Canada", flag: "🇨🇦"),
        CountryCode(code: "+44", name: "United Kingdom", flag: "🇬🇧"),
        CountryCode(code: "+91", name: "India", flag: "🇮🇳"),
        CountryCode(code: "+86", name: "China", flag: "🇨🇳"),
        CountryCode(code: "+81", name: "Japan", flag: "🇯🇵"),
        CountryCode(code: "+49", name: "Germany", flag: "🇩🇪"),
        CountryCode(code: "+33", name: "France", flag: "🇫🇷"),
        CountryCode(code: "+39", name: "Italy", flag: "🇮🇹"),
        CountryCode(code: "+34", name: "Spain", flag: "🇪🇸"),
        CountryCode(code: "+55", name: "Brazil", flag: "🇧🇷"),
        CountryCode(code: "+52", name: "Mexico", flag: "🇲🇽"),
        CountryCode(code: "+61", name: "Australia", flag: "🇦🇺"),
        CountryCode(code: "+82", name: "South Korea", flag: "🇰🇷"),
        CountryCode(code: "+65", name: "Singapore", flag: "🇸🇬"),
        CountryCode(code: "+971", name: "UAE", flag: "🇦🇪"),
        CountryCode(code: "+966", name: "Saudi Arabia", flag: "🇸🇦"),
        CountryCode(code: "+27", name: "South Africa", flag: "🇿🇦"),
        CountryCode(code: "+7", name: "Russia", flag: "🇷🇺"),
        CountryCode(code: "+31", name: "Netherlands", flag: "🇳🇱"),
        CountryCode(code: "+46", name: "Sweden", flag: "🇸🇪"),
        CountryCode(code: "+47", name: "Norway", flag: "🇳🇴"),
        CountryCode(code: "+41", name: "Switzerland", flag: "🇨🇭"),
        CountryCode(code: "+48", name: "Poland", flag: "🇵🇱"),
        CountryCode(code: "+90", name: "Turkey", flag: "🇹🇷")
    ]
}

