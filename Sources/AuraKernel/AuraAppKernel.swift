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
open class AuraAppKernel: AuraKernel, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate Forwarding

    @objc open func application(
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

    @objc open func applicationDidBecomeActive(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationDidBecomeActive(application)
        }
    }

    @objc open func applicationWillResignActive(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillResignActive(application)
        }
    }

    @objc open func applicationDidEnterBackground(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationDidEnterBackground(application)
        }
    }

    @objc open func applicationWillEnterForeground(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillEnterForeground(application)
        }
    }

    @objc open func applicationWillTerminate(_ application: UIApplication) {
        for plugin in pluginList {
            plugin.applicationWillTerminate(application)
        }
    }

    @objc open func application(
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

    @objc open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        for plugin in pluginList {
            plugin.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    @objc open func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        for plugin in pluginList {
            plugin.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    @objc open func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        var finalResult: UIBackgroundFetchResult = .noData
        for plugin in pluginList {
            plugin.application(
                application,
                didReceiveRemoteNotification: userInfo,
                fetchCompletionHandler: { result in
                    if result.rawValue < finalResult.rawValue {
                        finalResult = result
                    }
                }
            )
        }
        completionHandler(finalResult)
    }
}

#endif
