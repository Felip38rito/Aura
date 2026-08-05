import SwiftUI
import AuraKernel
import AuraDS

@MainActor
struct KernelsView: View {
    private var theme: AuraTheme = .default
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AuraHeading(content: "Kernel Lifecycle", style: theme.heading[.primary] ?? .empty)
                
                AuraText(
                    content: "Aura uses a pluggable kernel to manage app and scene lifecycles. Plugins can be registered at boot to hook into system events.",
                    style: theme.text[.secondary] ?? .empty
                )
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Registered Plugins", style: theme.heading[.secondary] ?? .empty)
                    
                    ForEach(AuraKernel.shared.pluginList.map { $0.identifier }, id: \.self) { id in
                        AuraText(content: "🧩 \(id)", style: theme.text[.primary] ?? .empty)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Configuration", style: theme.heading[.secondary] ?? .empty)
                    
                    if let configPlugin = AuraKernel.shared.pluginList.first(where: { $0.identifier == "configuration" }) as? ConfigurationPlugin {
                        ForEach(configPlugin.config.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            AuraText(content: "\(key): \(value)", style: theme.text[.primary] ?? .empty)
                        }
                    } else {
                        AuraText(content: "No configuration plugin found", style: theme.text[.tertiary] ?? .empty)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    AuraHeading(content: "Lifecycle State", style: theme.heading[.secondary] ?? .empty)
                    AuraText(
                        content: "App Launch Count: \(AppLifecyclePlugin.shared.launchCount)",
                        style: theme.text[.primary] ?? .empty
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Kernels")
    }
}
