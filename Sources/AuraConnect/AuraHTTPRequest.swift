import Foundation

public struct AuraHTTPRequest: Sendable {
    public let method: AuraHTTPMethod
    public let url: URL
    public let headers: [String: String]
    public let body: Data?

    public init(
        method: AuraHTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}
