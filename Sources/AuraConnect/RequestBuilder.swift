import Foundation

public struct RequestBuilder: Sendable {
    private var method: HTTPMethod?
    private var url: URL?
    private var headers: [String: String] = [:]
    private var body: Data?

    public init() {}

    public func with(method: HTTPMethod) -> RequestBuilder {
        var copy = self
        copy.method = method
        return copy
    }

    public func with(url: URL) -> RequestBuilder {
        var copy = self
        copy.url = url
        return copy
    }

    public func with(path: String, baseUrl: URL) -> RequestBuilder {
        var copy = self
        copy.url = baseUrl.appendingPathComponent(path)
        return copy
    }

    public func with(header key: String, value: String) -> RequestBuilder {
        var copy = self
        copy.headers[key] = value
        return copy
    }

    public func with(headers: [String: String]) -> RequestBuilder {
        var copy = self
        copy.headers.merge(headers) { (_, new) in new }
        return copy
    }

    public func with(body: Data) -> RequestBuilder {
        var copy = self
        copy.body = body
        return copy
    }

    public func with<T: Encodable>(body: T, using encoder: JSONEncoder = JSONEncoder()) throws -> RequestBuilder {
        var copy = self
        copy.body = try encoder.encode(body)
        return copy
    }

    public func build() throws -> HTTPRequest {
        guard let method = method else {
            throw RequestBuilderError.missingMethod
        }
        guard let url = url else {
            throw RequestBuilderError.missingURL
        }

        return HTTPRequest(method: method, url: url, headers: headers, body: body)
    }

    public enum RequestBuilderError: Error, Sendable {
        case missingMethod
        case missingURL
    }
}
