import Foundation

// MARK: - AuraKernel

/// The orchestration core of the Aura framework.
///
/// `AuraKernel` manages app lifecycle by forwarding `UIApplicationDelegate`
/// and `UISceneDelegate` events to registered `AuraKernelPlugin` instances.
///
/// For **new apps** (iOS 13+), use `AuraSceneKernel` as your `SceneDelegate`.
/// For **existing apps** with an `AppDelegate`, use `AuraAppKernel`.
///
/// ```swift
/// // New app — no AppDelegate needed
/// class SceneDelegate: AuraSceneKernel {
///     override init() {
///         super.init()
///         register(DeepLinkPlugin())
///         try! boot()
///     }
/// }
/// ```
@MainActor
open class AuraKernel: NSObject {

    // MARK: - Shared Singleton

    private static var _shared: AuraKernel?

    /// The shared kernel instance. Set automatically on first `boot()`.
    public static var shared: AuraKernel {
        guard let instance: AuraKernel = _shared else {
            fatalError(
                "AuraKernel.shared accessed before boot(). "
                + "Call boot() in your SceneDelegate or AppDelegate initializer."
            )
        }
        return instance
    }

    /// Reset the shared instance. For testing only.
    public static func resetShared() {
        _shared = nil
    }

    // MARK: - Plugin Registry

    private var plugins: [AuraKernelPlugin] = []

    /// All registered plugins.
    public var pluginList: [AuraKernelPlugin] { plugins }

    /// Register a plugin. Call during `init()` before `boot()`.
    public func register(_ plugin: AuraKernelPlugin) {
        plugins.append(plugin)
    }

    /// Remove a previously registered plugin by identity.
    public func unregister(_ plugin: AuraKernelPlugin) {
        plugins.removeAll { $0 === plugin }
    }

    /// Remove all plugins. Useful for testing between scenarios.
    public func reset() {
        plugins.removeAll()
    }

    // MARK: - Boot

    /// Boot all registered plugins in dependency order.
    ///
    /// Calls `plugin.boot(kernel:)` for each plugin, sorted topologically
    /// by their `dependencies`.
    /// - Throws: `AuraKernelError.missingDependency` or `AuraKernelError.cycleDetected`.
    public func boot() throws {
        Self._shared = self
        let sorted = try topologicalSort()
        for plugin in sorted {
            plugin.boot(kernel: self)
        }
    }

    // MARK: - Topological Sort

    /// Sorts plugins by their `dependencies` using Kahn's algorithm.
    private func topologicalSort() throws -> [AuraKernelPlugin] {
        let ids = plugins.map(\.identifier)
        let idSet = Set(ids)

        var inDegree: [String: Int] = [:]
        var adjacency: [String: [String]] = [:]

        for plugin in plugins {
            let id = plugin.identifier
            inDegree[id] = inDegree[id] ?? 0
            adjacency[id] = adjacency[id] ?? []

            for dep in plugin.dependencies {
                guard idSet.contains(dep) else {
                    throw AuraKernelError.missingDependency(plugin: id, dependency: dep)
                }
                adjacency[dep, default: []].append(id)
                inDegree[id, default: 0] += 1
            }
        }

        // Deterministic tie-breaking: registration order
        var queue: [String] = plugins.filter { inDegree[$0.identifier] == 0 }.map(\.identifier)
        var sortedIDs: [String] = []

        while !queue.isEmpty {
            let current = queue.removeFirst()
            sortedIDs.append(current)
            for neighbor in adjacency[current, default: []] {
                inDegree[neighbor, default: 0] -= 1
                if inDegree[neighbor] == 0 {
                    queue.append(neighbor)
                }
            }
        }

        if sortedIDs.count != plugins.count {
            let sortedSet = Set(sortedIDs)
            let unsorted = plugins
                .filter { !sortedSet.contains($0.identifier) }
                .map(\.identifier)
            throw AuraKernelError.cycleDetected(plugins: unsorted)
        }

        return sortedIDs.compactMap { id in plugins.first { $0.identifier == id } }
    }
}

// MARK: - AuraKernelError

/// Errors that can occur during kernel boot.
public enum AuraKernelError: Error, CustomStringConvertible, Equatable {
    /// A plugin depends on another plugin that was never registered.
    case missingDependency(plugin: String, dependency: String)
    /// A circular dependency was detected among the listed plugins.
    case cycleDetected(plugins: [String])

    public var description: String {
        switch self {
        case .missingDependency(let plugin, let dependency):
            return "AuraKernel: plugin '\(plugin)' depends on '\(dependency)', "
                + "but no registered plugin has that identifier."
        case .cycleDetected(let plugins):
            return "AuraKernel: dependency cycle detected among plugins: [\(plugins.joined(separator: ", "))]. "
                + "Check each plugin's `dependencies` for circular references."
        }
    }
}
