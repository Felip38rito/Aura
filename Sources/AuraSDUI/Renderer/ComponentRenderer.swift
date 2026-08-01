import SwiftUI
import AuraDS

/// Renders an `SUIComponent` tree into SwiftUI views.
///
/// The renderer uses the injected `AuraTheme` and resolvers to style each component.
/// It does **not** know about actions — it calls the `onAction` closure when a
/// button is tapped, leaving the action handling to the app.
@MainActor
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
                .padding(resolvePadding(style.padding))
                .background(resolveBackground(style.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 0))
            )

        case .spacer:
            return AnyView(Spacer())

        case .image(let data):
            let style = theme.image[data.theme] ?? .empty
            return AnyView(
                AsyncImage(url: URL(string: data.source)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 0))
                    case .failure:
                        if let alt = data.altText {
                            AuraText(content: alt, style: .empty)
                        } else {
                            Image(systemName: "photo").foregroundColor(.gray)
                        }
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            )

        case .unknown:
            return AnyView(EmptyView())
        }
    }

    // MARK: - Resolution Helpers

    private func resolvePadding(_ token: String?) -> CGFloat {
        guard let token else { return 0 }
        return AuraSpacingResolver.default.resolve(AuraSpacingToken(rawValue: token) ?? .md)
    }

    private func resolveBackground(_ token: String?) -> Color {
        guard let token else { return .clear }
        return AuraColorResolver.default.resolve(AuraColorToken(rawValue: token) ?? .surfacePrimary, .light).auraColor
    }
}
