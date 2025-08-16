import Foundation

public enum MockAPI {

    case userList

    var jsonName: String {
        switch self {
        case .userList: return "userlist"
        }
    }

    public func mock() -> Data? {
        guard let url = Bundle.main.url(forResource: self.jsonName, withExtension: "json") else {
            print("Mock Json Not Found:", self.jsonName)
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print(error)
            return nil
        }
    }

    func data<T: Decodable>(type: T.Type) -> T? {
        guard let mockData = self.mock() else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(type.self, from: mockData)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}
