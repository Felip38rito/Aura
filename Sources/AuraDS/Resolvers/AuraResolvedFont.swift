import Foundation

/// A platform-agnostic resolved font description.
///
/// Each platform converts this to its own type:
/// - SwiftUI: `Font.custom(family, size: size).weight(weight)` or
///            `Font.system(textStyle)` when `textStyle` is set.
/// - UIKit:  `UIFont(name: family, size: size)` adjusted for weight
///
/// `textStyle` is an optional SF text-style mapping. When set, the platform
/// converts to a Dynamic Type text style so text scales with the user's
/// accessibility preference. `family`/`size` remain the fallback path for
/// custom fonts.
public struct AuraResolvedFont: Sendable, Equatable {
    public var family: String
    public var size: CGFloat
    public var weight: AuraFontWeight
    public var textStyle: AuraFontTextStyle?

    public init(
        family: String,
        size: CGFloat,
        weight: AuraFontWeight,
        textStyle: AuraFontTextStyle? = nil
    ) {
        self.family = family
        self.size = size
        self.weight = weight
        self.textStyle = textStyle
    }

    /// Creates a system font with the given size and weight.
    public static func system(size: CGFloat, weight: AuraFontWeight) -> AuraResolvedFont {
        AuraResolvedFont(family: ".SFUI", size: size, weight: weight)
    }

    /// Creates a system font backed by an SF text style (Dynamic Type aware).
    public static func system(textStyle: AuraFontTextStyle, weight: AuraFontWeight? = nil) -> AuraResolvedFont {
        AuraResolvedFont(
            family: ".SFUI",
            size: textStyle.defaultSize,
            weight: weight ?? textStyle.defaultWeight,
            textStyle: textStyle
        )
    }
}

/// The SF text styles used by the default Aura font resolver to enable
/// Dynamic Type. Platform-agnostic; each platform maps to its native
/// text-style type (SwiftUI `Font.TextStyle`, UIKit `UIFont.TextStyle`).
public enum AuraFontTextStyle: String, Sendable, Equatable {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case body
    case footnote
    case caption1

    /// The system point size for the style at the default content size.
    public var defaultSize: CGFloat {
        switch self {
        case .largeTitle: 34
        case .title1: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .subheadline: 15
        case .body: 17
        case .footnote: 13
        case .caption1: 12
        }
    }

    /// The system default weight for the style.
    public var defaultWeight: AuraFontWeight {
        switch self {
        case .largeTitle, .title1, .title2, .title3,
             .subheadline, .body, .footnote, .caption1: .regular
        case .headline: .semibold
        }
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
