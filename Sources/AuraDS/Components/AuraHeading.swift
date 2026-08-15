import SwiftUI

/// A design system heading with token-based styling.
public struct AuraHeading: View {
    let content: String
    let style: ComponentStyle

    @Environment(\.colorResolver) private var colorResolver
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fontResolver) private var fontResolver
    @Environment(\.spacingResolver) private var spacingResolver

    private var auraColorScheme: AuraColorScheme {
        colorScheme == .dark ? .dark : .light
    }

    public init(content: String, style: ComponentStyle) {
        self.content = content
        self.style = style
    }

    public var body: some View {
        Text(content)
            .font(resolvedFont)
            .foregroundStyle(resolvedColor)
            .padding(.bottom, resolvedMargin)
    }

    // MARK: - Resolved Values

    private var resolvedFont: Font {
        guard let token = style.font else { return fontResolver.resolve(.heading1).auraFont }
        return fontResolver.resolve(AuraFontToken(rawValue: token) ?? .heading1).auraFont
    }

    private var resolvedColor: Color {
        guard let token = style.textColor else { return colorResolver.resolve(.textPrimary, auraColorScheme).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .textPrimary, auraColorScheme).auraColor
    }

    private var resolvedMargin: CGFloat {
        guard let token = style.margin else { return spacingResolver.resolve(.md) }
        return spacingResolver.resolve(AuraSpacingToken(rawValue: token) ?? .md)
    }
}
