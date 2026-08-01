import SwiftUI
import AuraKernel
import AuraDS
import AuraSDUI

// MARK: - App Entry Point

@main
struct AuraExampleApp: App {
    @State private var theme = AuraTheme.default
    @State private var screen: Screen = .home

    enum Screen {
        case home
        case detail(String)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                contentView
                    .navigationTitle("Aura Example")
            }
            .environment(\.colorResolver, .default)
            .environment(\.fontResolver, .default)
            .environment(\.spacingResolver, .default)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch screen {
        case .home:
            HomeView(theme: $theme, navigate: { screen = $0 })
        case .detail(let message):
            DetailView(message: message, goBack: { screen = .home })
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Binding var theme: AuraTheme
    let navigate: (AuraExampleApp.Screen) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Section: Typography
                SectionHeader(title: "Typography")

                AuraHeading(content: "Heading Primary", style: theme.heading[.primary] ?? .empty)
                AuraHeading(content: "Heading Secondary", style: theme.heading[.secondary] ?? .empty)
                AuraHeading(content: "Heading Danger", style: theme.heading[.danger] ?? .empty)

                AuraText(content: "Body text with primary style. This is the default body font used throughout the design system.", style: theme.text[.primary] ?? .empty)
                AuraText(content: "Secondary text with a smaller font for captions and metadata.", style: theme.text[.secondary] ?? .empty)
                AuraText(content: "Danger text for error messages and warnings.", style: theme.text[.danger] ?? .empty)

                Divider()

                // Section: Buttons
                SectionHeader(title: "Buttons")

                AuraButton(label: "Primary Action", style: theme.button[.primary] ?? .empty) {
                    navigate(.detail("Primary button tapped!"))
                }

                AuraButton(label: "Secondary", style: theme.button[.secondary] ?? .empty) {
                    navigate(.detail("Secondary button tapped!"))
                }

                AuraButton(label: "Danger", style: theme.button[.danger] ?? .empty) {
                    navigate(.detail("Danger button tapped!"))
                }

                AuraButton(label: "Ghost", style: theme.button[.ghost] ?? .empty) {
                    navigate(.detail("Ghost button tapped!"))
                }

                Divider()

                // Section: SDUI Demo
                SectionHeader(title: "SDUI — JSON Decoded")

                SDUIDemoView(navigate: navigate)
            }
            .padding()
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - SDUI Demo View

struct SDUIDemoView: View {
    let navigate: (AuraExampleApp.Screen) -> Void

    private let json = """
    {
        "type": "container",
        "theme": "primary",
        "children": [
            { "type": "heading", "content": "SDUI Screen", "theme": "primary" },
            { "type": "text", "content": "This view was decoded from a JSON payload using AuraSDUI.", "theme": "secondary" },
            {
                "type": "container",
                "theme": "secondary",
                "children": [
                    { "type": "text", "content": "Nested container with a button:", "theme": "primary" },
                    { "type": "button", "content": "SDUI Button", "theme": "primary", "action": { "type": "navigate", "value": "sdui-demo" } }
                ]
            },
            { "type": "spacer" }
        ]
    }
    """

    var body: some View {
        Group {
            if let component = try? JSONDecoder().decode(SUIComponent.self, from: json.data(using: .utf8)!) {
                ComponentRenderer(
                    theme: AuraTheme.default,
                    onAction: { action in
                        if case .navigate(let screen) = action {
                            navigate(.detail("SDUI Navigate to: \(screen)"))
                        }
                    }
                )
                .render(component)
            } else {
                AuraText(content: "Failed to decode SDUI JSON", style: .empty)
            }
        }
    }
}

// MARK: - Detail View

struct DetailView: View {
    let message: String
    let goBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            AuraHeading(content: "Action Received", style: AuraTheme.default.heading[.primary] ?? .empty)

            AuraText(content: message, style: AuraTheme.default.text[.secondary] ?? .empty)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            AuraButton(label: "Go Back", style: AuraTheme.default.button[.primary] ?? .empty, action: goBack)
        }
        .padding()
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
