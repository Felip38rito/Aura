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
            .font(style.font.map { fontResolver.resolve(AuraFontToken(rawValue: $0) ?? .body) } ?? fontResolver.resolve(.body))
            .foregroundColor(style.textColor.map { colorResolver.resolve(AuraColorToken(rawValue: $0) ?? .textPrimary) } ?? colorResolver.resolve(.textPrimary))
    }
}
