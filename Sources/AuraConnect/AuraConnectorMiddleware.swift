import Foundation

public protocol AuraConnectorMiddleware: Sendable {
    func before(request: HTTPRequest) async throws -> HTTPRequest
    func after(response: HTTPResponse) async throws -> HTTPResponse
}
