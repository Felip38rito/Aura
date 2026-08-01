import Foundation

public protocol AuraConnectorMiddleware: Sendable {
    func before(request: AuraHTTPRequest) async throws -> AuraHTTPRequest
    func after(response: AuraHTTPResponse) async throws -> AuraHTTPResponse
}
