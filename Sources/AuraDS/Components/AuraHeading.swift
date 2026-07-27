import SwiftUI

/// A design system heading with token-based styling.
public struct AuraHeading: View {
    let content: String
    let style: ComponentStyle

    @Environment(\.colorResolver) private var colorResolver
    @Environment(\.fontResolver) private var fontResolver
    @Environment(\.spacingResolver) private var spacingResolver

    public init(content: String, style: ComponentStyle) {
        self.content = content
        self.style = style
    }

    public var body: some View {
        Text(content)
            .font(style.font.map { fontResolver.resolve(AuraFontToken(rawValue: $0) ?? .heading1) } ?? fontResolver.resolve(.heading1))
            .foregroundColor(style.textColor.map { colorResolver.resolve(AuraColorToken(rawValue: $0) ?? .textPrimary) } ?? colorResolver.resolve(.textPrimary))
            .padding(.bottom, style.margin.map { spacingResolver.resolve(AuraSpacingToken(rawValue: $0) ?? .md) } ?? spacingResolver.resolve(.md))
    }
}
