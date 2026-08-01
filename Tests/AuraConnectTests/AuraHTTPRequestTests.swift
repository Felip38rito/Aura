import Testing
import Foundation
@testable import AuraConnect

@Suite("AuraHTTPRequest Tests")
struct AuraHTTPRequestTests {
    @Test func testInit() {
        let url = URL(string: "https://aura.ai")!
        let headers = ["Content-Type": "application/json"]
        let body = "hello".data(using: .utf8)

        let request = AuraHTTPRequest(
            method: .post,
            url: url,
            headers: headers,
            body: body
        )

        #expect(request.method == .post)
        #expect(request.url == url)
        #expect(request.headers == headers)
        #expect(request.body == body)
    }
}
