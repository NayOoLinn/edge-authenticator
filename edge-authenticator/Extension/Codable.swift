import Foundation

extension Encodable {

    func toDictionary() -> [String: String] {
        guard let data = try? JSONEncoder().encode(self),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }

        var dict: [String: String] = [:]
        json.forEach { dict[$0.key] = "\($0.value)" }
        return dict
    }
}
