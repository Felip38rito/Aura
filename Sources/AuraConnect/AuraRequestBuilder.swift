import Foundation

public struct AuraRequestBuilder: Sendable {
    private var method: AuraHTTPMethod?
    private var url: URL?
    private var baseURL: String?
    private var path: String?
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

    public func with(endpoint: String) throws -> AuraRequestBuilder {
        guard let url = URL(string: endpoint) else {
            throw AuraRequestBuilderError.invalidEndpoint(endpoint)
        }
        var copy = self
        copy.url = url
        return copy
    }

    public func with(baseURL: String) throws -> AuraRequestBuilder {
        guard URL(string: baseURL) != nil else {
            throw AuraRequestBuilderError.invalidEndpoint(baseURL)
        }
        var copy = self
        copy.baseURL = baseURL
        return copy
    }

    public func with(path: String) -> AuraRequestBuilder {
        var copy = self
        copy.path = path
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

        let resolvedURL: URL
        if let url = url {
            resolvedURL = url
        } else if let baseURL = baseURL, let base = URL(string: baseURL) {
            if let path = path {
                resolvedURL = base.appendingPathComponent(path)
            } else {
                resolvedURL = base
            }
        } else {
            throw AuraRequestBuilderError.missingURL
        }

        return AuraHTTPRequest(method: method, url: resolvedURL, headers: headers, body: body)
    }

    public enum AuraRequestBuilderError: Error, Sendable {
        case missingMethod
        case missingURL
        case invalidEndpoint(String)
    }
}
