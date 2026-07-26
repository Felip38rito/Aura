import AuraDS

/// Aura Server-Driven UI — domain layer that transforms payloads into view contracts.
public struct AuraSDUI {
    /// Current version of the Aura SDUI module.
    public static let version = "0.1.0"

    /// Verifies that AuraSDUI can reach its dependency, AuraDS.
    public static func designSystemVersion() -> String {
        AuraDS.version
    }
}
