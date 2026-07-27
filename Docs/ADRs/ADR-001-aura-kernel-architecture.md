# ADR-001: AuraKernel — Plugin-Based App Lifecycle Orchestration

**Status:** Accepted  
**Date:** 2026-07-26  
**Author:** Felipe Brito  
**Deciders:** Felipe Brito, Hermes Agent  

---

## Context

The Aura framework needs a standardized way to handle app initialization across all apps that consume it. Currently, every iOS/macOS app has a monolithic `AppDelegate` that manually configures SDKs, sets up databases, registers push notifications, and handles deep links — all in one file. This is:

- **Untestable** — the `AppDelegate` is a black box
- **Uncomposable** — adding a new feature means editing the same file
- **Unportable** — every app reimplements the same pattern

Aura, as a framework, should provide a **reusable orchestration layer** that apps extend rather than replace.

## Decision

We will create **AuraKernel**, a `@MainActor` base class that apps extend to register **plugins** which respond to `UIApplicationDelegate` and `UISceneDelegate` lifecycle events.

### Architecture

```
AuraKernel (base class, @MainActor)
├── static _plugins: [AuraKernelPlugin]
├── register(_:) — adds a plugin
├── boot() — topological sort + calls plugin.boot()
├── application(...) — forwards to all plugins
└── scene(...) — forwards to all plugins
```

### AuraKernelPlugin Protocol

```swift
@MainActor
public protocol AuraKernelPlugin: AnyObject {
    var identifier: String { get }
    var dependencies: [String] { get }
    func boot(kernel: AuraKernel)
    // Lifecycle hooks with default empty implementations
}
```

### App Usage

```swift
class AppDelegate: AuraKernel, UIApplicationDelegate {
    override init() {
        super.init()
        register(NetworkingPlugin())
        register(DatabasePlugin())
        register(DeepLinkPlugin())
        boot()
    }
    // application(...) inherited from AuraKernel
}
```

## Key Decisions

### 1. `@MainActor` over `nonisolated(unsafe)` or generic `Actor`

- **Chosen:** `@MainActor` on the entire `AuraKernel` class
- **Why:** `UIApplicationDelegate` and `UISceneDelegate` are main-thread-only. `@MainActor` gives compile-time guarantees without runtime overhead. A generic `Actor` would be incompatible with synchronous `@objc` delegate methods.
- **Rejected:** `nonisolated(unsafe) static var` (Swift 6 warnings), generic `Actor` (cannot `await` inside `@objc` methods)

### 2. Monorepo over multiple packages

- **Chosen:** Single `Package.swift` with multiple targets (`AuraKernel`, `AuraDS`, `AuraSDUI`)
- **Why:** Atomic versioning, simpler CI, single dependency for consumers
- **Rejected:** Separate repos per module (version coordination overhead, cross-repo refactoring)

### 3. Shared static plugin registry

- **Chosen:** `private static var _plugins` inside `AuraKernel`
- **Why:** Both `AppDelegate` and `SceneDelegate` need access to the same plugins. Static registry means one registration point.
- **Rejected:** Instance-based registry (would require passing kernel between delegates)

### 4. No external DI container

- **Chosen:** AuraKernel itself is the DI mechanism
- **Why:** The kernel *is* the container. Plugins are registered explicitly. No dependency on Factory, Swinject, or any third-party library.
- **Rejected:** Factory (external dependency, adds complexity for framework consumers)

### 5. Topological sort for boot order

- **Chosen:** `boot()` sorts plugins by `dependencies` before calling each plugin's `boot(kernel:)`
- **Why:** A database plugin must boot before a feature plugin that depends on it. Cycles are detected and reported as errors.
- **Rejected:** FIFO order (no dependency guarantees), manual ordering (error-prone)

## Consequences

### Positive

- **Testable:** Each plugin is an isolated unit that can be tested independently
- **Composable:** Apps choose which plugins to register — no dead code
- **Portable:** The same pattern works across iOS and macOS apps
- **Extensible:** New lifecycle hooks can be added to `AuraKernelPlugin` without breaking existing plugins
- **Framework-grade:** Aura provides the orchestration layer; apps just configure it

### Negative

- **Static state:** The plugin registry is a static variable, which complicates testing if not reset between tests
- **Main-thread constraint:** All plugin lifecycle hooks run on the main thread — plugins doing heavy setup must dispatch to background queues themselves
- **Learning curve:** Developers must understand the plugin pattern vs. traditional AppDelegate

### Mitigations

- Add a `reset()` method for testing
- Document background work patterns in plugin guide
- Provide example plugins in the Aura repository

## Alternatives Considered

### Traditional AppDelegate (status quo)

Every app writes its own `AppDelegate` with all initialization inline. Simple for one-off apps, but Aura is a framework — it should provide structure, not leave it to each consumer.

### Protocol-Oriented Composition

Using a `KernelConfiguration` protocol that configures a kernel instance. This was explored in the earlier "Swift Foundations Kernel" concept. The current approach is simpler — the kernel *is* the base class, not a separate object.

### Event Bus / NotificationCenter

Plugins could subscribe to `NotificationCenter` for lifecycle events. Rejected because it's runtime-string-based, untestable, and doesn't leverage the type system.

## References

- [AuraKernel Architecture (Obsidian)](obsidian://open?vault=Obsidian%20Vault&file=Aura%2FAuraKernel%20Architecture)
- [Swift Foundations Kernel Ideia (Obsidian)](obsidian://open?vault=Obsidian%20Vault&file=Swift%20Foundations%20Kernel%2FIdeia)
- [Linux Kernel Module System](https://en.wikipedia.org/wiki/Loadable_kernel_module) — inspiration for plugin architecture
