import SwiftUI

/// Resolves `AuraColorToken` into a SwiftUI `Color`.
///
/// Create a custom resolver to support different palettes (light/dark, brand, etc.):
/// ```swift
/// let customResolver = AuraColorResolver { token in
///     switch token {
///     case .textPrimary: Color("BrandTextPrimary")
///     default: AuraColorResolver.default.resolve(token)
///     }
/// }
/// ```
public struct AuraColorResolver: Sendable {
    public let resolve: @Sendable (AuraColorToken) -> Color

    public init(resolve: @escaping @Sendable (AuraColorToken) -> Color) {
        self.resolve = resolve
    }

    public static let `default` = AuraColorResolver { token in
        switch token {
        // Text
        case .textPrimary: Color.primary
        case .textSecondary: Color.secondary
        case .textTertiary: Color.gray
        case .textDanger: Color.red
        case .textSuccess: Color.green
        case .textWarning: Color.orange
        case .textInfo: Color.blue
        case .textDisabled: Color.gray.opacity(0.5)
        case .textOnPrimary: Color.white
        case .textOnDark: Color.white

        // Control
        case .controlPrimary: Color.blue
        case .controlPrimaryPressed: Color.blue.opacity(0.8)
        case .controlSecondary: Color.gray.opacity(0.2)
        case .controlDanger: Color.red
        case .controlSuccess: Color.green
        case .controlGhost: Color.clear

        // Surface
        case .surfacePrimary: AuraColorResolver._surfacePrimary()
        case .surfaceSecondary: AuraColorResolver._surfaceSecondary()
        case .surfaceTertiary: AuraColorResolver._surfaceTertiary()
        case .backgroundPrimary: AuraColorResolver._backgroundPrimary()
        case .backgroundSecondary: AuraColorResolver._backgroundSecondary()

        // Border
        case .borderPrimary: Color.gray.opacity(0.3)
        case .borderSecondary: Color.gray.opacity(0.15)
        case .borderDanger: Color.red.opacity(0.5)

        // Neutral
        case .neutralWhite: Color.white
        case .neutralBlack: Color.black
        case .neutralClear: Color.clear
        }
    }

    // MARK: - Platform-specific Colors

    private static func _surfacePrimary() -> Color { Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1) }
    private static func _surfaceSecondary() -> Color { Color(.sRGB, red: 0.95, green: 0.95, blue: 0.97, opacity: 1) }
    private static func _surfaceTertiary() -> Color { Color(.sRGB, red: 0.92, green: 0.92, blue: 0.95, opacity: 1) }
    private static func _backgroundPrimary() -> Color { Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1) }
    private static func _backgroundSecondary() -> Color { Color(.sRGB, red: 0.95, green: 0.95, blue: 0.97, opacity: 1) }
}
