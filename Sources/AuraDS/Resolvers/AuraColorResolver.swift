import CoreGraphics
import Foundation

/// Resolves `AuraColorToken` into a platform-agnostic `CGColor`.
///
/// Works with SwiftUI (`Color(cgColor:)`), UIKit (`UIColor(cgColor:)`),
/// and AppKit (`NSColor(cgColor:)`).
public struct AuraColorResolver: Sendable {
    public let resolve: @Sendable (AuraColorToken) -> CGColor

    public init(resolve: @escaping @Sendable (AuraColorToken) -> CGColor) {
        self.resolve = resolve
    }

    public static let `default` = AuraColorResolver { token in
        switch token {
        // Text
        case .textPrimary: CGColor(gray: 0, alpha: 1)
        case .textSecondary: CGColor(gray: 0.55, alpha: 1)
        case .textTertiary: CGColor(gray: 0.7, alpha: 1)
        case .textDanger: CGColor(srgbRed: 1, green: 0.23, blue: 0.19, alpha: 1)
        case .textSuccess: CGColor(srgbRed: 0.2, green: 0.78, blue: 0.35, alpha: 1)
        case .textWarning: CGColor(srgbRed: 1, green: 0.6, blue: 0, alpha: 1)
        case .textInfo: CGColor(srgbRed: 0, green: 0.48, blue: 1, alpha: 1)
        case .textDisabled: CGColor(gray: 0.7, alpha: 0.5)
        case .textOnPrimary: CGColor(gray: 1, alpha: 1)
        case .textOnDark: CGColor(gray: 1, alpha: 1)

        // Control
        case .controlPrimary: CGColor(srgbRed: 0, green: 0.48, blue: 1, alpha: 1)
        case .controlPrimaryPressed: CGColor(srgbRed: 0, green: 0.38, blue: 0.9, alpha: 1)
        case .controlSecondary: CGColor(gray: 0.85, alpha: 1)
        case .controlDanger: CGColor(srgbRed: 1, green: 0.23, blue: 0.19, alpha: 1)
        case .controlSuccess: CGColor(srgbRed: 0.2, green: 0.78, blue: 0.35, alpha: 1)
        case .controlGhost: CGColor(gray: 0, alpha: 0)

        // Surface
        case .surfacePrimary: CGColor(gray: 1, alpha: 1)
        case .surfaceSecondary: CGColor(srgbRed: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        case .surfaceTertiary: CGColor(srgbRed: 0.92, green: 0.92, blue: 0.95, alpha: 1)
        case .backgroundPrimary: CGColor(gray: 1, alpha: 1)
        case .backgroundSecondary: CGColor(srgbRed: 0.95, green: 0.95, blue: 0.97, alpha: 1)

        // Border
        case .borderPrimary: CGColor(gray: 0.8, alpha: 1)
        case .borderSecondary: CGColor(gray: 0.9, alpha: 1)
        case .borderDanger: CGColor(srgbRed: 1, green: 0.6, blue: 0.6, alpha: 1)

        // Neutral
        case .neutralWhite: CGColor(gray: 1, alpha: 1)
        case .neutralBlack: CGColor(gray: 0, alpha: 1)
        case .neutralClear: CGColor(gray: 0, alpha: 0)
        }
    }
}
