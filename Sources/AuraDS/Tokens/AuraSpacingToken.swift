import Foundation

/// Semantic spacing tokens for the Aura Design System.
///
/// These describe the **density role**, not a fixed pixel value.
/// The actual `CGFloat` is resolved by `AuraSpacingResolver`.
public enum AuraSpacingToken: String, Decodable, CaseIterable, Sendable {
    case xs = "spacing.xs"
    case sm = "spacing.sm"
    case md = "spacing.md"
    case lg = "spacing.lg"
    case xl = "spacing.xl"
    case xxl = "spacing.xxl"
}
