import AuraDS
import AuraKernel
import SwiftUI
import UIKit

// MARK: - Scene Delegate
//
// Demonstrates AuraSceneKernel (UISceneDelegate). This is where scene-based
// plugins live — the kernel forwards scene lifecycle events to them. Boots
// the kernel (which also sets AuraKernelBase.shared) and creates the window.

@MainActor
final class SceneDelegate: AuraSceneKernel {
    private var window: UIWindow?

    override init() {
        super.init()
        register(LoggingPlugin())
        register(ConfigurationPlugin())
        try! boot()
    }

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Forward to plugins (logging).
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        guard let windowScene = scene as? UIWindowScene else { return }
        let rootView = ContentView()
            .environment(\.colorResolver, .default)
            .environment(\.fontResolver, .default)
            .environment(\.spacingResolver, .default)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        self.window = window
    }
}
