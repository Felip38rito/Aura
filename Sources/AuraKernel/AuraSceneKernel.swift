import Foundation

#if canImport(UIKit)
import UIKit

// MARK: - AuraSceneKernel

/// The recommended kernel for **new apps** (iOS 13+).
///
/// Use as your `SceneDelegate`. No `AppDelegate` needed — the kernel
/// handles all lifecycle events via plugins.
///
/// ```swift
/// class SceneDelegate: AuraSceneKernel {
///     override init() {
///         super.init()
///         register(DeepLinkPlugin())
///         try! boot()
///     }
/// }
/// ```
@MainActor
open class AuraSceneKernel: AuraKernel, UISceneDelegate {

    // MARK: - UISceneDelegate Forwarding

    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) {
        for plugin in pluginList {
            plugin.scene(scene, willConnectTo: session, options: options)
        }
    }

    open func sceneDidBecomeActive(_ scene: UIScene) {
        for plugin in pluginList {
            plugin.sceneDidBecomeActive(scene)
        }
    }

    open func sceneDidEnterBackground(_ scene: UIScene) {
        for plugin in pluginList {
            plugin.sceneDidEnterBackground(scene)
        }
    }

    open func sceneWillResignActive(_ scene: UIScene) {
        for plugin in pluginList {
            plugin.sceneWillResignActive(scene)
        }
    }

    open func sceneWillEnterForeground(_ scene: UIScene) {
        for plugin in pluginList {
            plugin.sceneWillEnterForeground(scene)
        }
    }

    open func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for plugin in pluginList {
            plugin.scene(scene, openURLContexts: URLContexts)
        }
    }

    open func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        for plugin in pluginList {
            plugin.scene(scene, continue: userActivity)
        }
    }
}

#endif
