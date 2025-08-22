import Foundation
import Security

public protocol KeychainKey {
    var key: String { get }
}

@propertyWrapper
public struct KeychainContext {
    private let storageKey: KeychainKey
    private let defaultValue: String?
    private let service: String = (Bundle.main.bundleIdentifier ?? "com.edge-authenticator") + ".realm"

    public init(storageKey: KeychainKey, defaultValue: String?) {
        self.storageKey = storageKey
        self.defaultValue = defaultValue
    }

    public var wrappedValue: String? {
        get {
            if let existingItem = storedItem as? [String: Any],
               let data = existingItem[kSecValueData as String] as? Data,
               let value = String(data: data, encoding: .utf8) {
                return value
            } else {
                return nil
            }
        }
        set {
            guard let data = newValue?.data(using: .utf8) else {
                return
            }

            if storedItem != nil {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: storageKey.key
                ]
                let attributes: [String: Any] = [
                    kSecValueData as String: data,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                ]

                let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
                if status == noErr {
                    print("Data update in keychain successfully.")
                } else {
                    print("Data update in keychain failed.", status)
                }
            } else {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: service,
                    kSecAttrAccount as String: storageKey.key,
                    kSecValueData as String: data,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                ]

                let status = SecItemAdd(query as CFDictionary, nil)
                if status == noErr {
                    print("Data store in keychain successfully.")
                } else {
                    print("Data store in keychain failed.", status)
                }
            }
        }
    }

    public var storedItem: CFTypeRef? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: storageKey.key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == noErr {
            return item
        } else {
            return nil
        }
    }
}
