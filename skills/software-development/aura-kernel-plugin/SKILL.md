---
name: aura-kernel-plugin
description: "Create new AuraKernel plugins for the Aura framework. Use when the user wants to add a new plugin to AuraKernel."
---

# AuraKernel Plugin Authoring

This skill guides the creation of new `AuraKernelPlugin` implementations for the Aura framework.

## When to Use

- User asks to create a new kernel plugin
- User wants to add lifecycle hooks for a new feature (analytics, networking, deep links, etc.)
- User wants to understand the plugin pattern

## The AuraKernelPlugin Protocol

```swift
@MainActor
public protocol AuraKernelPlugin: AnyObject {
    var identifier: String { get }
    var dependencies: [String] { get }
    func boot(kernel: AuraKernel)
}
```

### UIKit Lifecycle Hooks (iOS only, all optional)

```swift
func application(_:didFinishLaunchingWithOptions:) -> Bool
func applicationDidBecomeActive(_:)
func applicationWillResignActive(_:)
func applicationDidEnterBackground(_:)
func applicationWillEnterForeground(_:)
func applicationWillTerminate(_:)
func application(_:open:options:) -> Bool
func application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
func application(_:didFailToRegisterForRemoteNotificationsWithError:)
func application(_:didReceiveRemoteNotification:fetchCompletionHandler:)
func scene(_:willConnectTo:options:)
func sceneDidBecomeActive(_:)
func sceneDidEnterBackground(_:)
func sceneWillResignActive(_:)
func sceneWillEnterForeground(_:)
func scene(_:openURLContexts:)
func scene(_:continue:)
```

All UIKit hooks have default empty implementations — override only what you need.

## Step-by-Step: Creating a Plugin

### 1. Create the Plugin File

Create a new Swift file in `Sources/AuraKernel/Plugins/` (or alongside your feature code):

```swift
import Foundation
import AuraKernel

@MainActor
public final class MyFeaturePlugin: AuraKernelPlugin {

    public let identifier = "my-feature"
    public let dependencies: [String] = []

    // MARK: - Lifecycle

    public func boot(kernel: AuraKernel) {
        // Called once during kernel.boot(), in dependency order.
        // Use this for one-time setup.
    }

    // MARK: - App Lifecycle Hooks

    public func applicationDidBecomeActive(_ application: UIApplication) {
        // App came to foreground
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        // App went to background
    }
}
```

### 2. Register in the App

```swift
class AppDelegate: AuraKernel, UIApplicationDelegate {
    override init() {
        super.init()
        register(MyFeaturePlugin())
        register(OtherPlugin())
        boot()
    }
}
```

### 3. Handle Dependencies

If your plugin depends on another plugin:

```swift
public let identifier = "my-feature"
public let dependencies = ["database", "networking"]
```

The kernel's topological sort guarantees `database.boot()` and `networking.boot()` run before `my-feature.boot()`.

### 4. Test the Plugin

Create tests in `Tests/AuraKernelTests/`:

```swift
import Testing
import UIKit
@testable import AuraKernel

final class MyFeaturePluginTests {

    @Test("boot calls setup")
    @MainActor
    func testBoot() {
        let kernel = AuraKernel()
        let plugin = MyFeaturePlugin()
        kernel.register(plugin)
        kernel.boot()
        // Assert plugin state after boot
    }

    @Test("handles didBecomeActive")
    @MainActor
    func testDidBecomeActive() {
        let kernel = AuraKernel()
        let plugin = MyFeaturePlugin()
        kernel.register(plugin)
        kernel.boot()
        kernel.applicationDidBecomeActive(UIApplication.shared)
        // Assert plugin behavior
    }
}
```

## Common Patterns

### Plugin with Configuration

```swift
public final class NetworkingPlugin: AuraKernelPlugin {
    public let identifier = "networking"
    private let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public func boot(kernel: AuraKernel) {
        // Configure networking client with baseURL
    }
}
```

### Plugin with Internal State

```swift
public final class AnalyticsPlugin: AuraKernelPlugin {
    public let identifier = "analytics"
    private var isEnabled = false

    public func boot(kernel: AuraKernel) {
        isEnabled = true
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        guard isEnabled else { return }
        // Track session start
    }
}
```

### Plugin Using SceneDelegate Hooks

```swift
public final class DeepLinkPlugin: AuraKernelPlugin {
    public let identifier = "deep-links"

    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            handleURL(context.url)
        }
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return }
        handleURL(url)
    }

    private func handleURL(_ url: URL) {
        // Parse and route the deep link
    }
}
```

## Pitfalls

- **@MainActor constraint:** All lifecycle hooks run on the main thread. If your plugin does heavy work (networking, database), dispatch to a background queue.
- **Static registry:** Plugins are stored in a `nonisolated(unsafe) private static var`. This means all `AuraKernel` instances share the same plugins. Reset with `AuraKernel.resetGlobal()` between tests.
- **Dependency cycles:** The kernel detects cycles at boot time and throws `AuraKernelError.cycleDetected`. Always test your dependency graph.
- **Missing dependencies:** If plugin A depends on plugin B but B is never registered, the kernel throws `AuraKernelError.missingDependency`.
- **Return values:** `application(_:didFinishLaunchingWithOptions:)` returns `true` only if ALL plugins return `true`. One plugin returning `false` makes the whole launch return `false`.
