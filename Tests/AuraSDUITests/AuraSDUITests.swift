import Testing
@testable import AuraSDUI
import AuraDS

@Test func moduleExportsVersion() async throws {
    #expect(AuraSDUI.version == "0.1.0")
}

@Test func dependsOnAuraDS() async throws {
    #expect(AuraSDUI.designSystemVersion() == AuraDS.version)
}
