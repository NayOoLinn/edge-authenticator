import Foundation

enum Environment {

    enum Key {
        static let baseUrl = "BASE_URL"
        static let githubPat = "GITHUB_PAT"
    }

    private static let infoDictionay: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found.")
        }
        return dict
    }()

    static let baseUrl: String = {
        guard let pat = Environment.infoDictionay[Key.baseUrl] as? String else {
            fatalError("BASE_URL not set in info.plist")
        }
        return pat
    }()

    static let githubPat: String = {
        guard let pat = Environment.infoDictionay[Key.githubPat] as? String else {
            fatalError("GITHUB_PAT not set in info.plist")
        }
        return pat
    }()
}
