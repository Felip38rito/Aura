import Foundation

public protocol AuraConnector: Sendable {
    func request(_ request: AuraHTTPRequest) async throws -> AuraHTTPResponse
    func download(_ request: AuraHTTPRequest) async throws -> (URL, AuraHTTPResponse)
}
