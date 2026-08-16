import Foundation

// MARK: - AuraKernelPlugin Protocol

/// A plugin that hooks into the app lifecycle via `AuraKernel`.
///
/// Inspired by Linux kernel modules: each plugin declares its `identifier`
/// and `dependencies`, gets `boot(kernel:)` called in topological order,
/// and receives lifecycle events forwarded by the kernel.
///
/// All lifecycle methods have default empty implementations — conformers
/// only override what they need.
@MainActor
public protocol AuraKernelPlugin: AnyObject {

    // ── Identity & Ordering ──

    /// Unique identifier for this plugin. Used for dependency resolution.
    var identifier: String { get }

    /// Identifiers of plugins that must boot before this one.
    var dependencies: [String] { get }

    // ── Lifecycle ──

    /// Called once during `AuraKernelBase.boot()`, in topological order.
    /// - Parameter kernel: The kernel instance, for registering sub-components.
    func boot(kernel: AuraKernelBase)

    // ── UIKit Lifecycle Hooks ──
    // These are only available on platforms with UIKit (iOS, tvOS, visionOS).
    // On macOS, use AppKit equivalents via AuraKernelPlugin+AppKit.

#if canImport(UIKit)

    /// `application(_:didFinishLaunchingWithOptions:)`
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool

    func applicationDidBecomeActive(_ application: UIApplication)
    func applicationWillResignActive(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationWillTerminate(_ application: UIApplication)

    /// `application(_:open:options:)`
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool

    /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    )

    /// `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    )

    /// `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )

    // ── UISceneDelegate Hooks ──

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options: UIScene.ConnectionOptions
    )

    func sceneDidBecomeActive(_ scene: UIScene)
    func sceneDidEnterBackground(_ scene: UIScene)
    func sceneWillResignActive(_ scene: UIScene)
    func sceneWillEnterForeground(_ scene: UIScene)

    /// `scene(_:openURLContexts:)`
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)

    /// `scene(_:continue:)` — Handoff / NSUserActivity
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity)

#endif
}

// MARK: - Default Implementations

public extension AuraKernelPlugin {

    var dependencies: [String] { [] }

    func boot(kernel: AuraKernelBase) {}
}

#if canImport(UIKit)
import UIKit

@MainActor
public extension AuraKernelPlugin {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool { true }

    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool { true }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {}

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {}

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {}
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {}
}

#endif
