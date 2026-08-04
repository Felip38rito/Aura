import AuraDS
import AuraKernel
import SwiftUI

// MARK: - Content View
//
// Reads plugin state from the kernels and renders it with AuraDS components.
// All colors resolve through AuraColorResolver using the environment's
// color scheme, so light/dark adapt automatically via the AuraDS tokens.

struct ContentView: View {
    @State private var theme: AuraTheme = .default
    @State private var pluginIdentifiers: [String] = []
    @State private var configItems: [String] = []
    @State private var lifecycleEvents: [String] = []
    @State private var appLaunchCount: Int = 0

    @Environment(\.colorScheme) private var colorScheme

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
                Color(cgColor: AuraColorResolver.default.resolve(.backgroundPrimary, auraColorScheme))
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
                    .foregroundStyle(iconColor)
                AuraText(content: "App active count: \(appLaunchCount)", style: theme.text[.primary] ?? .empty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: containerStyle.cornerRadius ?? 8))
    }

    private var pluginsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AuraHeading(content: "Registered Plugins", style: theme.heading[.secondary] ?? .empty)

            ForEach(pluginIdentifiers, id: \.self) { id in
                HStack {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .foregroundStyle(iconColor)
                    AuraText(content: id, style: theme.text[.primary] ?? .empty)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: containerStyle.cornerRadius ?? 8))
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
        .clipShape(RoundedRectangle(cornerRadius: containerStyle.cornerRadius ?? 8))
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
                            .foregroundStyle(iconColor)
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
        .clipShape(RoundedRectangle(cornerRadius: containerStyle.cornerRadius ?? 8))
    }

    // MARK: - Helpers

    private var auraColorScheme: AuraColorScheme {
        colorScheme == .dark ? .dark : .light
    }

    /// Icon tint derived from the AuraDS secondary text token (dark/light aware).
    private var iconColor: Color {
        Color(cgColor: AuraColorResolver.default.resolve(.textSecondary, auraColorScheme))
    }

    /// The container card style from the AuraDS theme (token-based, dark/light aware).
    private var containerStyle: ComponentStyle {
        theme.container[.secondary] ?? .empty
    }

    private var cardBackground: Color {
        guard let token = containerStyle.backgroundColor else {
            return Color(cgColor: AuraColorResolver.default.resolve(.surfaceSecondary, auraColorScheme))
        }
        return Color(cgColor: AuraColorResolver.default.resolve(AuraColorToken(rawValue: token) ?? .surfaceSecondary, auraColorScheme))
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
