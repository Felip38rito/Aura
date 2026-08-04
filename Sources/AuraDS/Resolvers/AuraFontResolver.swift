import Foundation

/// Resolves `AuraFontToken` into a platform-agnostic `AuraResolvedFont`.
///
/// Works with SwiftUI, UIKit, and AppKit. The default resolver maps tokens to
/// SF text styles so text scales with the user's Dynamic Type preference.
public struct AuraFontResolver: Sendable {
    public let resolve: @Sendable (AuraFontToken) -> AuraResolvedFont

    public init(resolve: @escaping @Sendable (AuraFontToken) -> AuraResolvedFont) {
        self.resolve = resolve
    }

    public static let `default` = AuraFontResolver { token in
        switch token {
        case .largeTitle: .system(textStyle: .largeTitle)
        case .heading1: .system(textStyle: .title1)
        case .heading2: .system(textStyle: .title2)
        case .heading3: .system(textStyle: .title3)
        case .body: .system(textStyle: .body)
        case .bodySmall: .system(textStyle: .subheadline)
        case .caption: .system(textStyle: .caption1)
        case .button: .system(textStyle: .headline, weight: .semibold)
        case .buttonSmall: .system(textStyle: .subheadline, weight: .semibold)
        case .label: .system(textStyle: .footnote)
        }
    }
}
