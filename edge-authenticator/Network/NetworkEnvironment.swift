struct URLEnvironment {
    let baseUrl: String
    let version: String
    var fullURL: String {
        "\(baseUrl)/\(version)"
    }
}

enum NetworkEnvironment {
    case uat
    case production

    var urlEnvironment: URLEnvironment {
        switch self {
        case .uat:
            return URLEnvironment(baseUrl: KeychainData.baseUrl?.decryptWithAES() ?? "", version: "v1")
        case .production:
            return URLEnvironment(baseUrl: KeychainData.baseUrl?.decryptWithAES() ?? "", version: "v1")
        }
    }

    func fullPath(_ path: String) -> String {
        // NOT use fullURL for assignment
        "\(urlEnvironment.baseUrl)/\(path)"
    }
}
