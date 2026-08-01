import Foundation

public final class AuraURLSessionConnector: @unchecked Sendable, AuraConnector {
    public enum AuraHTTPError: Error, Sendable {
        case invalidResponse
        case networkError(Error)
    }

    private let session: URLSession
    private var middlewares: [AuraConnectorMiddleware]

    public init(
        session: URLSession = .shared,
        middlewares: [AuraConnectorMiddleware] = []
    ) {
        self.session = session
        self.middlewares = middlewares
    }

    public func register(_ middleware: AuraConnectorMiddleware) {
        middlewares.append(middleware)
    }

    public func request(_ request: AuraHTTPRequest) async throws -> AuraHTTPResponse {
        var currentRequest = request
        for middleware in middlewares {
            currentRequest = try await middleware.before(request: currentRequest)
        }

        let urlRequest = try buildURLRequest(from: currentRequest)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuraHTTPError.invalidResponse
        }

        var currentResponse = AuraHTTPResponse(
            statusCode: httpResponse.statusCode,
            headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
            body: data
        )

        for middleware in middlewares.reversed() {
            currentResponse = try await middleware.after(response: currentResponse)
        }

        return currentResponse
    }

    public func download(_ request: AuraHTTPRequest) async throws -> (URL, AuraHTTPResponse) {
        var currentRequest = request
        for middleware in middlewares {
            currentRequest = try await middleware.before(request: currentRequest)
        }

        let urlRequest = try buildURLRequest(from: currentRequest)
        let (localURL, response) = try await session.download(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuraHTTPError.invalidResponse
        }

        var currentResponse = AuraHTTPResponse(
            statusCode: httpResponse.statusCode,
            headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
            body: try Data(contentsOf: localURL)
        )

        for middleware in middlewares.reversed() {
            currentResponse = try await middleware.after(response: currentResponse)
        }

        return (localURL, currentResponse)
    }

    private func buildURLRequest(from request: AuraHTTPRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        return urlRequest
    }
}
