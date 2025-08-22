import Foundation

enum SecurityKey {

    static let version: Int = 1
    
    enum Key {
        static let baseUrl = "BASE_URL"
        static let securityKey = "SECURITY_KEY"
        static let clientId = "CLIENT_ID"
        static let clientSecret = "CLIENT_SECRET"
        static let publicKey = "PUBLIC_KEY"
    }

    private static let infoDictionay: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found.")
        }
        return dict
    }()

    static let baseUrl: String = {
        guard let pat = SecurityKey.infoDictionay[Key.baseUrl] as? String else {
            fatalError("BASE_URL not set in info.plist")
        }
        return pat
    }()

    static let secretKey: String = {
        guard let pat = SecurityKey.infoDictionay[Key.securityKey] as? String else {
            fatalError("SECURITY_KEY not set in info.plist")
        }
        return pat
    }()
    
    static let clientId: String = {
        guard let pat = SecurityKey.infoDictionay[Key.clientId] as? String else {
            fatalError("CLIENT_ID not set in info.plist")
        }
        return pat
    }()
    
    static let clientSecret: String = {
        guard let pat = SecurityKey.infoDictionay[Key.clientSecret] as? String else {
            fatalError("CLIENT_SECRET not set in info.plist")
        }
        return pat
    }()
    
    static let publicKey: String = {
        guard let pat = SecurityKey.infoDictionay[Key.publicKey] as? String else {
            fatalError("PUBLIC_KEY not set in info.plist")
        }
        return pat
    }()
    
    static let aesKeys: (key: String, iv: String)? = {
        let keys = secretKey.components(separatedBy: "Dkt!x")
        if keys.count < 2 {
            return nil
        }
        return (key: keys[0], iv: keys[1])
    }()
}
