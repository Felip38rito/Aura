import Testing
import Foundation
@testable import AuraConnect

@Suite("HTTPResponse Tests")
struct HTTPResponseTests {
    @Test func testDecodeValidJSON() throws {
        let json = #"{"id": 1, "name": "Aura"}"#
        let data = json.data(using: .utf8)!
        let response = HTTPResponse(statusCode: 200, body: data)

        let user = try response.decode(MockUser.self)
        #expect(user == MockUser(id: 1, name: "Aura"))
    }

    @Test func testDecodeInvalidJSON() {
        let json = #"{"id": "invalid"}"#
        let data = json.data(using: .utf8)!
        let response = HTTPResponse(statusCode: 200, body: data)

        #expect(throws: (any Error).self) {
            try response.decode(MockUser.self)
        }
    }
}

struct MockUser: Codable, Equatable {
    let id: Int
    let name: String
}
