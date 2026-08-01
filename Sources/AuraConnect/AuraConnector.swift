import Foundation

public protocol AuraConnector: Sendable {
    func request(_ request: HTTPRequest) async throws -> HTTPResponse
    func download(_ request: HTTPRequest) async throws -> (URL, HTTPResponse)
}
