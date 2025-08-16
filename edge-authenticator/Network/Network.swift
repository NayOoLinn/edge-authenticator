import Foundation
import RxSwift

class Network {

    static let shared = Network()
    private let urlSession: URLSession
    private var environment: NetworkEnvironment = .uat
    private var tasks: [String: URLSessionDataTask] = [:]

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        urlSession = URLSession(configuration: config)
    }

    func configure(environment: NetworkEnvironment) {
        self.environment = environment
    }

    func request<E: Endpoint>(
        _ endpoint: E,
        parameters: E.Request?
    ) -> Single<E.Response> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(NetworkError.default))
                return Disposables.create()
            }

            let urlString = self.environment.fullPath(endpoint.path)
            var url: URL?

            switch endpoint.encoding {
            case .query:
                var urlComponents = URLComponents(string: urlString)
                urlComponents?.queryItems = parameters?.toDictionary().map {
                    URLQueryItem(name: $0.key, value: $0.value)
                }
                url = urlComponents?.url

            case .json:
                url = URL(string: urlString)
            }

            guard let finalURL = url else {
                single(.failure(NetworkError.default))
                return Disposables.create()
            }

            var urlRequest = URLRequest(url: finalURL)
            urlRequest.httpMethod = endpoint.method.value

            if endpoint.encoding == .json {
                urlRequest.httpBody = try? JSONEncoder().encode(parameters)
            }

            endpoint.headers?.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            }

            switch endpoint.authType {
            case .basic:
                urlRequest.setValue("Basic", forHTTPHeaderField: "Authorization")
            case .bearer:
                urlRequest.setValue("Bearer \(Environment.githubPat)", forHTTPHeaderField: "Authorization")
            default:
                break
            }

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = self.urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
                self?.tasks[endpoint.path] = nil

                if let error = error {
                    single(.failure(NetworkError.custom(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    single(.failure(NetworkError.default))
                    return
                }

                guard let data = data else {
                    single(.failure(NetworkError.default))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(E.Response.self, from: data)
                    single(.success(decoded))
                } catch {
                    single(.failure(NetworkError.custom(error.localizedDescription)))
                }
            }

            self.tasks[endpoint.path] = task
            task.resume()

            return Disposables.create {
                task.cancel()
                self.tasks[endpoint.path] = nil
            }
        }
    }

    func cancelRequest(for path: String) {
        tasks[path]?.cancel()
        tasks[path] = nil
    }

    func cancelAllRequests() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
