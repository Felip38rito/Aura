import SwiftUI
import AuraDS

/// Renders an `SUIComponent` tree into SwiftUI views.
///
/// The renderer uses the injected `AuraTheme` and resolvers to style each component.
/// It does **not** know about actions — it calls the `onAction` closure when a
/// button is tapped, leaving the action handling to the app.
public struct ComponentRenderer: Sendable {
    public let theme: AuraTheme
    public let onAction: @Sendable (AuraComponentAction) -> Void

    public init(theme: AuraTheme, onAction: @escaping @Sendable (AuraComponentAction) -> Void) {
        self.theme = theme
        self.onAction = onAction
    }

    public func render(_ component: SUIComponent) -> AnyView {
        switch component {
        case .heading(let data):
            let style = theme.heading[data.theme] ?? .empty
            return AnyView(AuraHeading(content: data.content, style: style))

        case .text(let data):
            let style = theme.text[data.theme] ?? .empty
            return AnyView(AuraText(content: data.content, style: style))

        case .button(let data):
            let style = theme.button[data.theme] ?? .empty
            return AnyView(AuraButton(label: data.label, style: style) { [action = data.action, onAction] in
                onAction(action)
            })

        case .container(let themeName, let children):
            let style = theme.container[themeName] ?? .empty
            return AnyView(
                VStack(spacing: 0) {
                    ForEach(Array(children.enumerated()), id: \.offset) { [self] _, child in
                        render(child)
                    }
                }
                .padding(style.padding.map {
                    CGFloat(AuraSpacingResolver.default.resolve(AuraSpacingToken(rawValue: $0) ?? .md))
                } ?? 0)
                .background(style.backgroundColor.map {
                    AuraColorResolver.default.resolve(AuraColorToken(rawValue: $0) ?? .surfacePrimary)
                } ?? Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 0))
            )

        case .spacer:
            return AnyView(Spacer())

        case .unknown:
            return AnyView(EmptyView())
        }
    }
}
