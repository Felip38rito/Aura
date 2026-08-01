import Foundation

public struct AuraHTTPResponse: Sendable {
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data

    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data = Data()
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    public func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: body)
    }
}
