import Foundation

public final class AuraURLSessionConnector: @unchecked Sendable, AuraConnector {
    public enum AuraHTTPError: Error, Sendable {
        case invalidResponse
    }

    private let session: URLSession
    private let middlewaresLock = NSLock()
    private var middlewares: [AuraConnectorMiddleware]

    public init(
        session: URLSession = .shared,
        middlewares: [AuraConnectorMiddleware] = []
    ) {
        self.session = session
        self.middlewares = middlewares
    }

    public func register(_ middleware: AuraConnectorMiddleware) {
        middlewaresLock.lock()
        middlewares.append(middleware)
        middlewaresLock.unlock()
    }

    /// A snapshot of the current middleware chain, taken under the lock so
    /// concurrent `register(_:)` calls never race with iteration.
    private func snapshotMiddlewares() -> [AuraConnectorMiddleware] {
        middlewaresLock.lock()
        defer { middlewaresLock.unlock() }
        return middlewares
    }

    public func request(_ request: AuraHTTPRequest) async throws -> AuraHTTPResponse {
        let middlewares = snapshotMiddlewares()
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
            headers: Self.stringHeaders(from: httpResponse.allHeaderFields),
            body: data
        )

        for middleware in middlewares.reversed() {
            currentResponse = try await middleware.after(response: currentResponse)
        }

        return currentResponse
    }

    public func download(_ request: AuraHTTPRequest) async throws -> (URL, AuraHTTPResponse) {
        let middlewares = snapshotMiddlewares()
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
            headers: Self.stringHeaders(from: httpResponse.allHeaderFields),
            body: try Data(contentsOf: localURL)
        )

        for middleware in middlewares.reversed() {
            currentResponse = try await middleware.after(response: currentResponse)
        }

        return (localURL, currentResponse)
    }

    /// Converts `URLSession`'s `[AnyHashable: Any]` header dictionary into a
    /// `[String: String]` dictionary, preserving only string values instead of
    /// silently dropping all headers when the cast fails.
    private static func stringHeaders(from allHeaderFields: [AnyHashable: Any]) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in allHeaderFields {
            if let key = key as? String, let value = value as? String {
                headers[key] = value
            }
        }
        return headers
    }

    private func buildURLRequest(from request: AuraHTTPRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        return urlRequest
    }
}
