import SwiftUI

/// Resolves `AuraFontToken` into a SwiftUI `Font`.
public struct AuraFontResolver: Sendable {
    public let resolve: @Sendable (AuraFontToken) -> Font

    public init(resolve: @escaping @Sendable (AuraFontToken) -> Font) {
        self.resolve = resolve
    }

    public static let `default` = AuraFontResolver { token in
        switch token {
        case .largeTitle: .largeTitle
        case .heading1: .title.bold()
        case .heading2: .title2.bold()
        case .heading3: .title3.bold()
        case .body: .body
        case .bodySmall: .callout
        case .caption: .caption
        case .button: .body.weight(.semibold)
        case .buttonSmall: .callout.weight(.semibold)
        case .label: .footnote
        }
    }
}
