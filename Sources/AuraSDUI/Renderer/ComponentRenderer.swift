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

    public func render(_ component: SUIComponent) -> some View {
        SUIComponentView(component: component, theme: theme, onAction: onAction)
    }
}

/// A concrete view that renders a single `SUIComponent` node.
///
/// Being a named `View` type (rather than a recursive `some View` function)
/// breaks the type recursion that a self-referential `@ViewBuilder` would
/// otherwise create, while keeping every branch a concrete view — no `AnyView`.
@MainActor
private struct SUIComponentView: View {
    let component: SUIComponent
    let theme: AuraTheme
    let onAction: @Sendable (AuraComponentAction) -> Void

    var body: some View {
        switch component {
        case .heading(_, let data):
            let style = theme.heading[data.theme] ?? .empty
            AuraHeading(content: data.content, style: style)

        case .text(_, let data):
            let style = theme.text[data.theme] ?? .empty
            AuraText(content: data.content, style: style)

        case .button(_, let data):
            let style = theme.button[data.theme] ?? .empty
            AuraButton(label: data.label, style: style) { [action = data.action, onAction] in
                onAction(action)
            }

        case .container(_, let themeName, let children):
            let style = theme.container[themeName] ?? .empty
            VStack(spacing: 0) {
                ForEach(children) { child in
                    SUIComponentView(component: child, theme: theme, onAction: onAction)
                }
            }
            .padding(resolvePadding(style.padding))
            .background(ContainerBackground(token: style.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius ?? 0))

        case .spacer:
            Spacer()

        case .image(_, let data):
            let style = theme.image[data.theme] ?? .empty
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
                        Image(systemName: "photo").foregroundStyle(.gray)
                    }
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }

        case .unknown:
            EmptyView()
        }
    }

    // MARK: - Resolution Helpers

    private func resolvePadding(_ token: String?) -> CGFloat {
        guard let token else { return 0 }
        return AuraSpacingResolver.default.resolve(AuraSpacingToken(rawValue: token) ?? .md)
    }
}

/// Resolves a container background color token from the environment's color
/// resolver and color scheme so dark/light adapt via the injected resolver.
private struct ContainerBackground: View {
    let token: String?

    @Environment(\.colorResolver) private var colorResolver
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let scheme: AuraColorScheme = colorScheme == .dark ? .dark : .light
        colorResolver
            .resolve(AuraColorToken(rawValue: token ?? "") ?? .surfacePrimary, scheme)
            .auraColor
    }
}
