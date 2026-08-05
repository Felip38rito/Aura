import SwiftUI
import AuraDS

@MainActor
struct DesignSystemView: View {
    private var theme: AuraTheme = .default
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AuraHeading(content: "Aura Design System", style: theme.heading[.primary] ?? .empty)
                
                AuraText(
                    content: "Components resolve tokens from the environment. Colors adapt automatically between light and dark modes.",
                    style: theme.text[.secondary] ?? .empty
                )
                
                // Headings
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Headings", style: theme.heading[.secondary] ?? .empty)
                    AuraHeading(content: "Primary Heading", style: theme.heading[.primary] ?? .empty)
                    AuraHeading(content: "Secondary Heading", style: theme.heading[.secondary] ?? .empty)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Typography", style: theme.heading[.secondary] ?? .empty)
                    AuraText(content: "Primary body text for general content.", style: theme.text[.primary] ?? .empty)
                    AuraText(content: "Secondary body text for captions and hints.", style: theme.text[.secondary] ?? .empty)
                }
                
                // Buttons
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Interactive Elements", style: theme.heading[.secondary] ?? .empty)
                    HStack {
                        AuraButton(label: "Primary", style: theme.button[.primary] ?? .empty) { }
                        AuraButton(label: "Secondary", style: theme.button[.secondary] ?? .empty) { }
                    }
                    HStack {
                        AuraButton(label: "Danger", style: theme.button[.danger] ?? .empty) { }
                        AuraButton(label: "Success", style: theme.button[.success] ?? .empty) { }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Design System")
    }
}
