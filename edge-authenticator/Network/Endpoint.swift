import RxSwift

protocol Endpoint {
    associatedtype Request: Codable
    associatedtype Response: Codable
    var path: String { get set }
    var method: RequestMethod { get set }
    var encoding: RequestEncoding { get set }
    var headers: [String: String]? { get set }
    var authType: AuthType? { get set }
    func mock(_ type: MockAPI) -> Single<Response>
}

extension Endpoint {
    func mock(_ type: MockAPI) -> Single<Response> {
        guard let result = type.data(type: Response.self) else {
            return .never()
        }
        return .just(result).delay(.microseconds(500), scheduler: MainScheduler.instance)
    }
}

enum RequestMethod: String {
    case get, post, update, delete, put

    var value: String { self.rawValue.uppercased() }
}

enum RequestEncoding {
    case query
    case json
}

enum AuthType {
    case basic
    case bearer
}
