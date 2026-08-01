import Foundation

public struct AuraRequestBuilder: Sendable {
    private var method: AuraHTTPMethod?
    private var url: URL?
    private var headers: [String: String] = [:]
    private var body: Data?

    public init() {}

    public func with(method: AuraHTTPMethod) -> AuraRequestBuilder {
        var copy = self
        copy.method = method
        return copy
    }

    public func with(url: URL) -> AuraRequestBuilder {
        var copy = self
        copy.url = url
        return copy
    }

    public func with(path: String, baseUrl: URL) -> AuraRequestBuilder {
        var copy = self
        copy.url = baseUrl.appendingPathComponent(path)
        return copy
    }

    public func with(header key: String, value: String) -> AuraRequestBuilder {
        var copy = self
        copy.headers[key] = value
        return copy
    }

    public func with(headers: [String: String]) -> AuraRequestBuilder {
        var copy = self
        copy.headers.merge(headers) { (_, new) in new }
        return copy
    }

    public func with(body: Data) -> AuraRequestBuilder {
        var copy = self
        copy.body = body
        return copy
    }

    public func with<T: Encodable>(body: T, using encoder: JSONEncoder = JSONEncoder()) throws -> AuraRequestBuilder {
        var copy = self
        copy.body = try encoder.encode(body)
        return copy
    }

    public func build() throws -> AuraHTTPRequest {
        guard let method = method else {
            throw AuraRequestBuilderError.missingMethod
        }
        guard let url = url else {
            throw AuraRequestBuilderError.missingURL
        }

        return AuraHTTPRequest(method: method, url: url, headers: headers, body: body)
    }

    public enum AuraRequestBuilderError: Error, Sendable {
        case missingMethod
        case missingURL
    }
}
