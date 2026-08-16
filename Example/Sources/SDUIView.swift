import SwiftUI
import AuraDS
import AuraSDUI

@MainActor
struct SDUIView: View {
    @State private var alertMessage: String?
    @State private var showAlert = false

    private var theme: AuraTheme = .default

    private static let jsonPayload = """
    {
        "id": "screen-1",
        "type": "container",
        "theme": "primary",
        "children": [
            {
                "id": "h-1",
                "type": "heading",
                "content": "SDUI Welcome",
                "theme": "primary"
            },
            {
                "id": "t-1",
                "type": "text",
                "content": "This screen is rendered from a JSON payload using AuraSDUI.",
                "theme": "secondary"
            },
            {
                "id": "t-2",
                "type": "text",
                "content": "Try the button below to trigger a custom action.",
                "theme": "secondary"
            },
            {
                "id": "s-1",
                "type": "spacer"
            },
            {
                "id": "b-1",
                "type": "button",
                "content": "Perform Action",
                "theme": "primary",
                "action": {
                    "type": "custom",
                    "value": "sdui_action_triggered"
                }
            }
        ]
    }
    """

    /// Decoded once at struct initialization — the payload is static.
    private let component: SUIComponent? = {
        guard let data = Self.jsonPayload.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(SUIComponent.self, from: data)
    }()

    var body: some View {
        VStack {
            if let component {
                ComponentRenderer(theme: theme, onAction: { action in
                    Task { @MainActor in
                        handleAction(action)
                    }
                })
                .render(component)
            } else {
                AuraText(content: "Failed to decode SDUI payload", style: theme.text[.danger] ?? .empty)
            }
        }
        .navigationTitle("SDUI")
        .alert("SDUI Action", isPresented: $showAlert) {
            Button("OK", action: {})
        } message: {
            Text(alertMessage ?? "Unknown action")
        }
    }

    private func handleAction(_ action: AuraComponentAction) {
        switch action {
        case .custom(let value):
            alertMessage = "Custom Action: \(value)"
        case .deepLink(let url):
            alertMessage = "Deep Link: \(url.absoluteString)"
        case .openURL(let url):
            alertMessage = "Open URL: \(url.absoluteString)"
        case .navigate(let path):
            alertMessage = "Navigate to: \(path)"
        }
        showAlert = true
    }
}
