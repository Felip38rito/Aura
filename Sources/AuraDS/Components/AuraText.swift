import SwiftUI

/// A design system text component with token-based styling.
public struct AuraText: View {
    let content: String
    let style: ComponentStyle

    @Environment(\.colorResolver) private var colorResolver
    @Environment(\.fontResolver) private var fontResolver

    public init(content: String, style: ComponentStyle) {
        self.content = content
        self.style = style
    }

    public var body: some View {
        Text(content)
            .font(resolvedFont)
            .foregroundColor(resolvedColor)
    }

    // MARK: - Resolved Values

    private var resolvedFont: Font {
        guard let token = style.font else { return fontResolver.resolve(.body).auraFont }
        return fontResolver.resolve(AuraFontToken(rawValue: token) ?? .body).auraFont
    }

    private var resolvedColor: Color {
        guard let token = style.textColor else { return colorResolver.resolve(.textPrimary).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .textPrimary).auraColor
    }
}
