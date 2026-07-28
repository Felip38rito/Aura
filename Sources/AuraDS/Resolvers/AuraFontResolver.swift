import Foundation

/// Resolves `AuraFontToken` into a platform-agnostic `AuraResolvedFont`.
///
/// Works with SwiftUI, UIKit, and AppKit.
public struct AuraFontResolver: Sendable {
    public let resolve: @Sendable (AuraFontToken) -> AuraResolvedFont

    public init(resolve: @escaping @Sendable (AuraFontToken) -> AuraResolvedFont) {
        self.resolve = resolve
    }

    public static let `default` = AuraFontResolver { token in
        switch token {
        case .largeTitle: AuraResolvedFont.system(size: 34, weight: .regular)
        case .heading1: AuraResolvedFont.system(size: 28, weight: .bold)
        case .heading2: AuraResolvedFont.system(size: 22, weight: .bold)
        case .heading3: AuraResolvedFont.system(size: 20, weight: .bold)
        case .body: AuraResolvedFont.system(size: 17, weight: .regular)
        case .bodySmall: AuraResolvedFont.system(size: 15, weight: .regular)
        case .caption: AuraResolvedFont.system(size: 12, weight: .regular)
        case .button: AuraResolvedFont.system(size: 17, weight: .semibold)
        case .buttonSmall: AuraResolvedFont.system(size: 15, weight: .semibold)
        case .label: AuraResolvedFont.system(size: 11, weight: .regular)
        }
    }
}
