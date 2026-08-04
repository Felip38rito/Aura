import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

/// Resolves `AuraColorToken` into a platform-agnostic `CGColor`.
///
/// Works with SwiftUI (`Color(cgColor:)`), UIKit (`UIColor(cgColor:)`),
/// and AppKit (`NSColor(cgColor:)`).
///
/// The default resolver maps tokens to **system semantic colors**
/// (`UIColor` / `NSColor` semantic values such as `.label`, `.systemBackground`,
/// `.systemRed`). This delegates light/dark (and future high-contrast)
/// adaptation to the OS, giving the framework a native Apple look by default.
/// The `AuraColorScheme` argument remains available so custom resolvers and
/// server-driven themes can distinguish light/dark explicitly.
public struct AuraColorResolver: Sendable {
    public let resolve: @Sendable (AuraColorToken, AuraColorScheme) -> CGColor

    public init(resolve: @escaping @Sendable (AuraColorToken, AuraColorScheme) -> CGColor) {
        self.resolve = resolve
    }

    public static let `default` = AuraColorResolver { token, _ in
        switch token {
        // Text
        case .textPrimary: sys(.label)
        case .textSecondary: sys(.secondaryLabel)
        case .textTertiary: sys(.tertiaryLabel)
        case .textOnPrimary: sys(.white)
        case .textOnDark: sys(.white)
        case .textDanger: sys(.systemRed)
        case .textSuccess: sys(.systemGreen)
        case .textWarning: sys(.systemOrange)
        case .textInfo: sys(.systemBlue)
        case .textDisabled: sys(.tertiaryLabel)

        // Control
        case .controlPrimary: sys(.tintColor)
        case .controlPrimaryPressed: sys(.systemBlue)
        case .controlSecondary: sys(.tertiarySystemFill)
        case .controlDanger: sys(.systemRed)
        case .controlSuccess: sys(.systemGreen)
        case .controlGhost: clear()

        // Surface
        case .surfacePrimary: sys(.systemBackground)
        case .surfaceSecondary: sys(.secondarySystemBackground)
        case .surfaceTertiary: sys(.tertiarySystemBackground)
        case .backgroundPrimary: sys(.systemBackground)
        case .backgroundSecondary: sys(.secondarySystemBackground)

        // Border
        case .borderPrimary: sys(.separator)
        case .borderSecondary: sys(.separator)
        case .borderDanger: sys(.systemRed)

        // Neutral
        case .neutralWhite: sys(.white)
        case .neutralBlack: sys(.black)
        case .neutralClear: clear()
        }
    }
}

// MARK: - Platform helpers

/// Converts a system semantic color to a `CGColor`, or falls back to a
/// neutral gray approximation on platforms without UIKit/AppKit.
@inline(__always)
private func sys(_ provider: SystemColor) -> CGColor {
    provider.cgColor
}

#if canImport(UIKit)

private enum SystemColor {
    case label, secondaryLabel, tertiaryLabel
    case systemRed, systemGreen, systemOrange, systemBlue
    case tintColor
    case tertiarySystemFill
    case systemBackground, secondarySystemBackground, tertiarySystemBackground
    case separator
    case white, black

    var cgColor: CGColor {
        let ui: UIColor
        switch self {
        case .label: ui = .label
        case .secondaryLabel: ui = .secondaryLabel
        case .tertiaryLabel: ui = .tertiaryLabel
        case .systemRed: ui = .systemRed
        case .systemGreen: ui = .systemGreen
        case .systemOrange: ui = .systemOrange
        case .systemBlue: ui = .systemBlue
        case .tintColor: ui = .tintColor
        case .tertiarySystemFill: ui = .tertiarySystemFill
        case .systemBackground: ui = .systemBackground
        case .secondarySystemBackground: ui = .secondarySystemBackground
        case .tertiarySystemBackground: ui = .tertiarySystemBackground
        case .separator: ui = .separator
        case .white: ui = .white
        case .black: ui = .black
        }
        return ui.cgColor
    }
}

#elseif canImport(AppKit)

private enum SystemColor {
    case label, secondaryLabel, tertiaryLabel
    case systemRed, systemGreen, systemOrange, systemBlue
    case tintColor
    case tertiarySystemFill
    case systemBackground, secondarySystemBackground, tertiarySystemBackground
    case separator
    case white, black

    var cgColor: CGColor {
        let ns: NSColor
        switch self {
        case .label: ns = .labelColor
        case .secondaryLabel: ns = .secondaryLabelColor
        case .tertiaryLabel: ns = .tertiaryLabelColor
        case .systemRed: ns = .systemRed
        case .systemGreen: ns = .systemGreen
        case .systemOrange: ns = .systemOrange
        case .systemBlue: ns = .systemBlue
        case .tintColor: ns = .controlAccentColor
        case .tertiarySystemFill: ns = .controlBackgroundColor
        case .systemBackground: ns = .windowBackgroundColor
        case .secondarySystemBackground: ns = .underPageBackgroundColor
        case .tertiarySystemBackground: ns = .underPageBackgroundColor
        case .separator: ns = .separatorColor
        case .white: ns = .white
        case .black: ns = .black
        }
        return ns.cgColor
    }
}

#else

/// Fallback neutral palette for platforms without UIKit/AppKit (e.g. Linux).
private enum SystemColor {
    case label, secondaryLabel, tertiaryLabel
    case systemRed, systemGreen, systemOrange, systemBlue
    case tintColor
    case tertiarySystemFill
    case systemBackground, secondarySystemBackground, tertiarySystemBackground
    case separator
    case white, black

    var cgColor: CGColor {
        switch self {
        case .label: CGColor(gray: 0.1, alpha: 1)
        case .secondaryLabel: CGColor(gray: 0.45, alpha: 1)
        case .tertiaryLabel: CGColor(gray: 0.6, alpha: 1)
        case .systemRed: CGColor(srgbRed: 1, green: 0.23, blue: 0.19, alpha: 1)
        case .systemGreen: CGColor(srgbRed: 0.2, green: 0.78, blue: 0.35, alpha: 1)
        case .systemOrange: CGColor(srgbRed: 1, green: 0.6, blue: 0, alpha: 1)
        case .systemBlue: CGColor(srgbRed: 0, green: 0.48, blue: 1, alpha: 1)
        case .tintColor: CGColor(srgbRed: 0, green: 0.48, blue: 1, alpha: 1)
        case .tertiarySystemFill: CGColor(gray: 0.85, alpha: 1)
        case .systemBackground: CGColor(gray: 1, alpha: 1)
        case .secondarySystemBackground: CGColor(gray: 0.95, alpha: 1)
        case .tertiarySystemBackground: CGColor(gray: 0.92, alpha: 1)
        case .separator: CGColor(gray: 0.8, alpha: 1)
        case .white: CGColor(gray: 1, alpha: 1)
        case .black: CGColor(gray: 0, alpha: 1)
        }
    }
}

#endif

@inline(__always)
private func clear() -> CGColor {
    CGColor(gray: 0, alpha: 0)
}
