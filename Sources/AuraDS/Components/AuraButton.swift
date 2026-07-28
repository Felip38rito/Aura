import SwiftUI

/// A design system button with full token-based styling.
///
/// Usage:
/// ```swift
/// AuraButton(label: "Salvar", style: style, action: { })
/// ```
public struct AuraButton: View {
    let label: String
    let style: ComponentStyle
    let action: () -> Void

    @Environment(\.colorResolver) private var colorResolver
    @Environment(\.fontResolver) private var fontResolver
    @Environment(\.spacingResolver) private var spacingResolver

    public init(label: String, style: ComponentStyle, action: @escaping () -> Void) {
        self.label = label
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(resolvedFont)
                .foregroundColor(resolvedTextColor)
                .padding(resolvedPadding)
                .background(resolvedBackground)
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resolved Values

    private var resolvedFont: Font {
        guard let token = style.font else { return fontResolver.resolve(.button).auraFont }
        return fontResolver.resolve(AuraFontToken(rawValue: token) ?? .button).auraFont
    }

    private var resolvedTextColor: Color {
        guard let token = style.textColor else { return colorResolver.resolve(.textOnPrimary).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .textOnPrimary).auraColor
    }

    private var resolvedPadding: CGFloat {
        guard let token = style.padding else { return spacingResolver.resolve(.md) }
        return spacingResolver.resolve(AuraSpacingToken(rawValue: token) ?? .md)
    }

    private var resolvedBackground: Color {
        guard let token = style.backgroundColor else { return colorResolver.resolve(.controlPrimary).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .controlPrimary).auraColor
    }
}
