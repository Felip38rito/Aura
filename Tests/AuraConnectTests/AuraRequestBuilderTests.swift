import Testing
import Foundation
@testable import AuraConnect

@Suite("AuraRequestBuilder Tests")
struct AuraRequestBuilderTests {
    @Test func testFullConstruction() throws {
        let url = URL(string: "https://aura.ai")!
        let body = MockBody(key: "test", value: 123)

        let request = try AuraRequestBuilder()
            .with(method: .post)
            .with(url: url)
            .with(header: "X-Request-ID", value: "123")
            .with(body: body)
            .build()

        #expect(request.method == .post)
        #expect(request.url == url)
        #expect(request.headers["X-Request-ID"] == "123")
        #expect(request.body != nil)
    }

    @Test func testChainedWith() throws {
        let url = URL(string: "https://aura.ai")!
        let builder = AuraRequestBuilder()
            .with(method: .get)
            .with(url: url)

        let request = try builder.build()
        #expect(request.method == .get)
        #expect(request.url == url)
    }

    @Test func testBuildWithValidURL() throws {
        let url = URL(string: "https://aura.ai")!
        let request = try AuraRequestBuilder()
            .with(method: .get)
            .with(url: url)
            .build()

        #expect(request.url == url)
    }

    @Test func testBuildWithEncodableBody() throws {
        let url = URL(string: "https://aura.ai")!
        let body = MockBody(key: "test", value: 123)
        let request = try AuraRequestBuilder()
            .with(method: .post)
            .with(url: url)
            .with(body: body)
            .build()

        let decodedBody = try JSONDecoder().decode(MockBody.self, from: request.body!)
        #expect(decodedBody == body)
    }

    @Test func testMissingMethodThrows() {
        let url = URL(string: "https://aura.ai")!
        let builder = AuraRequestBuilder().with(url: url)
        #expect(throws: AuraRequestBuilder.AuraRequestBuilderError.self) {
            try builder.build()
        }
    }

    @Test func testMissingURLThrows() {
        let builder = AuraRequestBuilder().with(method: .get)
        #expect(throws: AuraRequestBuilder.AuraRequestBuilderError.self) {
            try builder.build()
        }
    }
}

struct MockBody: Codable, Equatable {
    let key: String
    let value: Int
}
