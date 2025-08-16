import RxSwift

struct UserListEndpoint: Endpoint {

    static let service = UserListEndpoint()
    var path: String = "users"
    var method: RequestMethod = .get
    var encoding: RequestEncoding = .query
    var headers: [String : String]? = ["Accept": "application/vnd.github+json"]
    var authType: AuthType? = .bearer

    struct Request: Codable {
        let lastId: Int
        let itemCount: Int // maximum 100 items

        enum CodingKeys: String, CodingKey {
            case lastId = "since"
            case itemCount = "per_page"
        }
    }

    typealias Response = [UserData]

    func call(parameters: Request, inTesting: Bool) -> Single<Response> {
        inTesting ? mock(.userList) : Network.shared.request(self, parameters: parameters)
    }
}
