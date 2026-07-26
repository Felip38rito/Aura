import Testing
@testable import AuraDS

@Test func moduleExportsVersion() async throws {
    #expect(AuraDS.version == "0.1.0")
}

@Test func helloReturnsExpectedGreeting() async throws {
    #expect(AuraDS.hello() == "Hello, AuraDS!")
}
