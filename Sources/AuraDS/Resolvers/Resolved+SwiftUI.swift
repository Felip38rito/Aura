import SwiftUI

// MARK: - CGColor → Color

extension CGColor {
    /// Converts to a SwiftUI `Color`.
    public var auraColor: Color {
        Color(cgColor: self)
    }
}

// MARK: - AuraResolvedFont → Font

extension AuraFontTextStyle {
    /// Maps to the corresponding SwiftUI `Font.TextStyle`.
    var swiftUITextStyle: Font.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .footnote: .footnote
        case .caption1: .caption
        }
    }
}

extension AuraResolvedFont {
    /// Converts to a SwiftUI `Font`.
    public var auraFont: Font {
        if let textStyle {
            // Dynamic Type aware: scales with the user's accessibility preference.
            return Font.system(textStyle.swiftUITextStyle).weight(weight.swiftUIWeight)
        }
        if family == ".SFUI" {
            return Font.system(size: size, weight: weight.swiftUIWeight)
        }
        return Font.custom(family, size: size).weight(weight.swiftUIWeight)
    }
}

extension AuraFontWeight {
    /// Maps to the corresponding SwiftUI `Font.Weight`.
    var swiftUIWeight: Font.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}
