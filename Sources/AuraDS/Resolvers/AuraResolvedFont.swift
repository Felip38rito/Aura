import Foundation

/// A platform-agnostic resolved font description.
///
/// Each platform converts this to its own type:
/// - SwiftUI: `Font.custom(family, size: size).weight(weight)`
/// - UIKit:  `UIFont(name: family, size: size)` adjusted for weight
public struct AuraResolvedFont: Sendable, Equatable {
    public var family: String
    public var size: CGFloat
    public var weight: AuraFontWeight

    public init(family: String, size: CGFloat, weight: AuraFontWeight) {
        self.family = family
        self.size = size
        self.weight = weight
    }

    /// Creates a system font with the given size and weight.
    public static func system(size: CGFloat, weight: AuraFontWeight) -> AuraResolvedFont {
        AuraResolvedFont(family: ".SFUI", size: size, weight: weight)
    }
}

public enum AuraFontWeight: String, Sendable, Equatable {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
}
