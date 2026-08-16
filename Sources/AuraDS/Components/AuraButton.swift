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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.fontResolver) private var fontResolver
    @Environment(\.spacingResolver) private var spacingResolver

    private var auraColorScheme: AuraColorScheme {
        colorScheme == .dark ? .dark : .light
    }

    public init(label: String, style: ComponentStyle, action: @escaping () -> Void) {
        self.label = label
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(resolvedFont)
                .foregroundStyle(resolvedTextColor)
                .padding(resolvedPadding)
                .background(resolvedBackground)
                .clipShape(RoundedRectangle(cornerRadius: resolvedCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: resolvedCornerRadius)
                        .strokeBorder(resolvedBorderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resolved Values

    private var resolvedFont: Font {
        guard let token = style.font else { return fontResolver.resolve(.button).auraFont }
        return fontResolver.resolve(AuraFontToken(rawValue: token) ?? .button).auraFont
    }

    private var resolvedTextColor: Color {
        guard let token = style.textColor else { return colorResolver.resolve(.textOnPrimary, auraColorScheme).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .textOnPrimary, auraColorScheme).auraColor
    }

    private var resolvedPadding: CGFloat {
        guard let token = style.padding else { return spacingResolver.resolve(.md) }
        return spacingResolver.resolve(AuraSpacingToken(rawValue: token) ?? .md)
    }

    private var resolvedBackground: Color {
        guard let token = style.backgroundColor else { return colorResolver.resolve(.controlPrimary, auraColorScheme).auraColor }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .controlPrimary, auraColorScheme).auraColor
    }

    private var resolvedBorderColor: Color {
        guard let token = style.borderColor else { return .clear }
        return colorResolver.resolve(AuraColorToken(rawValue: token) ?? .borderPrimary, auraColorScheme).auraColor
    }

    private var resolvedCornerRadius: CGFloat {
        style.cornerRadius ?? 8
    }
}
