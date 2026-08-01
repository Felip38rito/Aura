import Testing
import Foundation
@testable import AuraConnect

// MARK: - Mock URLProtocol

private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Middleware Mocks

private struct AddHeaderMiddleware: AuraConnectorMiddleware {
    let key: String
    let value: String

    func before(request: HTTPRequest) async throws -> HTTPRequest {
        var copy = request
        var headers = copy.headers
        headers[key] = value
        copy = HTTPRequest(method: copy.method, url: copy.url, headers: headers, body: copy.body)
        return copy
    }

    func after(response: HTTPResponse) async throws -> HTTPResponse { response }
}

private struct StatusMiddleware: AuraConnectorMiddleware {
    let newStatus: Int

    func before(request: HTTPRequest) async throws -> HTTPRequest { request }

    func after(response: HTTPResponse) async throws -> HTTPResponse {
        HTTPResponse(statusCode: newStatus, headers: response.headers, body: response.body)
    }
}

// MARK: - Tests

@Suite(.serialized)
struct AuraURLSessionConnectorTests {

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    @Test func testRequestSuccess() async throws {
        let expectedData = #"{"ok": true}"#.data(using: .utf8)!
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://aura.ai")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, expectedData)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let connector = AuraURLSessionConnector(session: makeSession())
        let request = HTTPRequest(method: .get, url: URL(string: "https://aura.ai")!)

        let response = try await connector.request(request)

        #expect(response.statusCode == 200)
        #expect(response.body == expectedData)
    }

    @Test func testRequestNetworkError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let connector = AuraURLSessionConnector(session: makeSession())
        let request = HTTPRequest(method: .get, url: URL(string: "https://aura.ai")!)

        await #expect(throws: URLError.self) {
            try await connector.request(request)
        }
    }

    @Test func testMiddlewareBeforeModifiesRequest() async throws {
        let expectedData = Data()
        MockURLProtocol.requestHandler = { urlRequest in
            let response = HTTPURLResponse(
                url: URL(string: "https://aura.ai")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            #expect(urlRequest.value(forHTTPHeaderField: "X-Custom") == "value")
            return (response, expectedData)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let middleware = AddHeaderMiddleware(key: "X-Custom", value: "value")
        let connector = AuraURLSessionConnector(
            session: makeSession(),
            middlewares: [middleware]
        )
        let request = HTTPRequest(method: .get, url: URL(string: "https://aura.ai")!)

        let response = try await connector.request(request)
        #expect(response.statusCode == 200)
    }

    @Test func testMiddlewareAfterModifiesResponse() async throws {
        let expectedData = #"{"ok": true}"#.data(using: .utf8)!
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://aura.ai")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, expectedData)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let middleware = StatusMiddleware(newStatus: 418)
        let connector = AuraURLSessionConnector(
            session: makeSession(),
            middlewares: [middleware]
        )
        let request = HTTPRequest(method: .get, url: URL(string: "https://aura.ai")!)

        let response = try await connector.request(request)

        #expect(response.statusCode == 418)
        #expect(response.body == expectedData)
    }

    @Test func testMiddlewareChainExecutesInOrder() async throws {
        let expectedData = Data()
        MockURLProtocol.requestHandler = { urlRequest in
            let response = HTTPURLResponse(
                url: URL(string: "https://aura.ai")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            #expect(urlRequest.value(forHTTPHeaderField: "X-A") == "a")
            #expect(urlRequest.value(forHTTPHeaderField: "X-B") == "b")
            return (response, expectedData)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let m1 = AddHeaderMiddleware(key: "X-A", value: "a")
        let m2 = AddHeaderMiddleware(key: "X-B", value: "b")
        let connector = AuraURLSessionConnector(
            session: makeSession(),
            middlewares: [m1, m2]
        )
        let request = HTTPRequest(method: .get, url: URL(string: "https://aura.ai")!)

        let response = try await connector.request(request)
        #expect(response.statusCode == 200)
    }
}
