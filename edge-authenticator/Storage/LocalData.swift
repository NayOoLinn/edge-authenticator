import Foundation
// MARK: - StorageKeys
public enum StorageKeys: String, StorageKey {
    case sampleData = "SAMPLE_DATA"

    public var key: String { rawValue }
}

public struct LocalData {
    
    @UserContext(storageKey: StorageKeys.sampleData, defaultValue: nil)
    public static var sampleData: String?

    public static func clearCurrentSession() {
        sampleData = nil
    }
}
