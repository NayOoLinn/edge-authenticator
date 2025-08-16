import Foundation
import Security

public enum KeychainKeys: String, KeychainKey {
    case realmEncryptKey = "REALM_ENCRYPT_KEY"
    public var key: String { rawValue }
}

public struct KeychainData {
    @KeychainContext(storageKey: KeychainKeys.realmEncryptKey, defaultValue: nil)
    private static var realmEncryptKeyString: String?

    /// Access Realm encryption key as Data (64 bytes)
    public static var realmEncryptKey: Data {
        get {
            // Try to decode existing key
            if let base64 = realmEncryptKeyString,
               let data = Data(base64Encoded: base64),
               data.count == 64 {
                return data
            }

            // Otherwise generate a new 64-byte key
            var key = Data(count: 64)
            let result = key.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
            }
            guard result == errSecSuccess else {
                fatalError("❌ Failed to generate random Realm encryption key")
            }

            // Save to Keychain as Base64 string
            realmEncryptKeyString = key.base64EncodedString()
            return key
        }
        set {
            realmEncryptKeyString = newValue.base64EncodedString()
        }
    }

    /// Clear all stored values (for example on logout/reset)
    public static func clearAll() {
        realmEncryptKeyString = nil
    }
}
