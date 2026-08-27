import Testing
@testable import AuraConnect

@Suite("AuraHTTPMethod")
struct AuraHTTPMethodTests {

    @Test("raw values match HTTP standard methods")
    func rawValues() {
        #expect(AuraHTTPMethod.get.rawValue == "GET")
        #expect(AuraHTTPMethod.post.rawValue == "POST")
        #expect(AuraHTTPMethod.put.rawValue == "PUT")
        #expect(AuraHTTPMethod.patch.rawValue == "PATCH")
        #expect(AuraHTTPMethod.delete.rawValue == "DELETE")
        #expect(AuraHTTPMethod.head.rawValue == "HEAD")
        #expect(AuraHTTPMethod.options.rawValue == "OPTIONS")
    }

    @Test("initializes from raw value")
    func initFromRawValue() {
        #expect(AuraHTTPMethod(rawValue: "GET") == .get)
        #expect(AuraHTTPMethod(rawValue: "POST") == .post)
        #expect(AuraHTTPMethod(rawValue: "PUT") == .put)
        #expect(AuraHTTPMethod(rawValue: "PATCH") == .patch)
        #expect(AuraHTTPMethod(rawValue: "DELETE") == .delete)
        #expect(AuraHTTPMethod(rawValue: "HEAD") == .head)
        #expect(AuraHTTPMethod(rawValue: "OPTIONS") == .options)
    }

    @Test("returns nil for unknown raw value")
    func unknownRawValue() {
        #expect(AuraHTTPMethod(rawValue: "TRACE") == nil)
        #expect(AuraHTTPMethod(rawValue: "get") == nil)
    }
}
