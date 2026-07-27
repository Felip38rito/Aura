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
                .font(style.font.map { fontResolver.resolve(AuraFontToken(rawValue: $0) ?? .button) } ?? fontResolver.resolve(.button))
                .foregroundColor(style.textColor.map { colorResolver.resolve(AuraColorToken(rawValue: $0) ?? .textPrimary) } ?? colorResolver.resolve(.textOnPrimary))
                .padding(style.padding.map { spacingResolver.resolve(AuraSpacingToken(rawValue: $0) ?? .md) } ?? spacingResolver.resolve(.md))
                .background(style.backgroundColor.map { colorResolver.resolve(AuraColorToken(rawValue: $0) ?? .controlPrimary) } ?? colorResolver.resolve(.controlPrimary))
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 8))
        }
        .buttonStyle(.plain)
    }
}
