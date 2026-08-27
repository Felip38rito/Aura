import Foundation

#if canImport(UIKit)
import UIKit

// MARK: - AuraAppKernel

/// A bridge kernel for **existing apps** that still use `UIApplicationDelegate`.
///
/// Use as your `AppDelegate`. When you're ready to migrate to the modern
/// scene-based lifecycle, switch to `AuraSceneKernel` and remove this class.
///
/// ```swift
/// class AppDelegate: AuraAppKernel {
///     override init() {
///         super.init()
///         register(PushPlugin())
///         register(DeepLinkPlugin())
///         try! boot()
///     }
/// }
/// ```
@MainActor
open class AuraAppKernel: AuraKernelBase, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate Forwarding

    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        var result = true
        for plugin in pluginList {
            if !plugin.application(application, didFinishLaunchingWithOptions: launchOptions) {
                result = false
            }
        }
        return result
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationDidBecomeActive(application)
        }
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillResignActive(application)
        }
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationDidEnterBackground(application)
        }
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillEnterForeground(application)
        }
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillTerminate(application)
        }
    }

    open func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        var result = true
        for plugin in pluginList {
            if !plugin.application(application, open: url, options: options) {
                result = false
            }
        }
        return result
    }

    open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        for plugin in pluginList {
            plugin.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    open func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        for plugin in pluginList {
            plugin.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    open func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let plugins = pluginList
        guard !plugins.isEmpty else {
            completionHandler(.noData)
            return
        }

        var finalResult: UIBackgroundFetchResult = .noData
        var pending = plugins.count

        for plugin in plugins {
            plugin.application(
                application,
                didReceiveRemoteNotification: userInfo,
                fetchCompletionHandler: { result in
                    // Plugins may invoke their handler asynchronously and from any
                    // thread, so aggregate on the main actor before completing.
                    Task { @MainActor in
                        // Lower rawValue wins: .newData < .noData < .failed
                        if result.rawValue < finalResult.rawValue {
                            finalResult = result
                        }
                        pending -= 1
                        if pending == 0 {
                            completionHandler(finalResult)
                        }
                    }
                }
            )
        }
    }
}

#endif
