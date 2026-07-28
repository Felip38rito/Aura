import SwiftUI

// MARK: - CGColor → Color

extension CGColor {
    /// Converts to a SwiftUI `Color`.
    public var auraColor: Color {
        Color(cgColor: self)
    }
}

// MARK: - AuraResolvedFont → Font

extension AuraResolvedFont {
    /// Converts to a SwiftUI `Font`.
    public var auraFont: Font {
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
