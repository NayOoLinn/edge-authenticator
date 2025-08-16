import Foundation

public protocol StorageKey {
    var key: String { get }
}

@propertyWrapper
public struct UserContext<T: Codable> {
    private let storageKey: StorageKey
    private let defaultValue: T?

    public init(storageKey: StorageKey, defaultValue: T?) {
        self.storageKey = storageKey
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T? {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: storageKey.key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)

            // Set value to UserDefaults
            UserDefaults.standard.set(data, forKey: storageKey.key)
            UserDefaults.standard.synchronize()
        }
    }
}
