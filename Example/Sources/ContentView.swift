import AuraDS
import AuraKernel
import SwiftUI

// MARK: - Content View
//
// Reads plugin state from the kernels and renders it with AuraDS components.

struct ContentView: View {
    @State private var theme: AuraTheme = .default
    @State private var pluginIdentifiers: [String] = []
    @State private var configItems: [String] = []
    @State private var lifecycleEvents: [String] = []
    @State private var appLaunchCount: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    kernelSection
                    pluginsSection
                    configSection
                    lifecycleSection
                }
                .padding()
            }
            .navigationTitle("Aura Kernel Demo")
            .background(
                Color(cgColor: AuraColorResolver.default.resolve(.backgroundPrimary, .light))
            )
        }
        .onAppear { loadKernelData() }
    }

    // MARK: - Sections

    private var kernelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AuraHeading(content: "Kernels", style: theme.heading[.primary] ?? .empty)
            AuraText(content: "AppDelegate + SceneDelegate boot via AuraKernel", style: theme.text[.secondary] ?? .empty)
            HStack {
                Image(systemName: "app.fill")
                AuraText(content: "App active count: \(appLaunchCount)", style: theme.text[.primary] ?? .empty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var pluginsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AuraHeading(content: "Registered Plugins", style: theme.heading[.secondary] ?? .empty)

            ForEach(pluginIdentifiers, id: \.self) { id in
                HStack {
                    Image(systemName: "puzzlepiece.extension.fill")
                    AuraText(content: id, style: theme.text[.primary] ?? .empty)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AuraHeading(content: "Configuration", style: theme.heading[.secondary] ?? .empty)

            ForEach(configItems, id: \.self) { item in
                AuraText(content: item, style: theme.text[.secondary] ?? .empty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var lifecycleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AuraHeading(content: "Scene Lifecycle", style: theme.heading[.secondary] ?? .empty)

            if lifecycleEvents.isEmpty {
                AuraText(
                    content: "No events yet. Move app to background and back.",
                    style: theme.text[.tertiary] ?? .empty
                )
            } else {
                ForEach(lifecycleEvents, id: \.self) { event in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                        AuraText(content: event, style: theme.text[.primary] ?? .empty)
                    }
                }
            }

            AuraButton(label: "Refresh", style: theme.button[.secondary] ?? .empty) {
                loadKernelData()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var cardBackground: Color {
        Color(cgColor: AuraColorResolver.default.resolve(.surfaceSecondary, .light))
    }

    private func loadKernelData() {
        let kernel = AuraKernel.shared
        pluginIdentifiers = kernel.pluginList.map(\.identifier)

        if let configPlugin = kernel.pluginList.first(where: { $0.identifier == "configuration" }) as? ConfigurationPlugin {
            configItems = configPlugin.config.map { "\($0.key): \($0.value)" }.sorted()
        }

        if let loggingPlugin = kernel.pluginList.first(where: { $0.identifier == "logging" }) as? LoggingPlugin {
            lifecycleEvents = loggingPlugin.events
        }

        appLaunchCount = AppLifecyclePlugin.shared.launchCount
    }
}
