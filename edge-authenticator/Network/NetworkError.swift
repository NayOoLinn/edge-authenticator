import Foundation

enum NetworkError: Error {
    case `default`
    case custom(String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .default:
            return "Something went wrong.\nPlease try again later."
        case .custom(let message):
            return message
        }
    }
}
