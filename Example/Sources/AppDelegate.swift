import AuraKernel
import UIKit

// MARK: - App Delegate
//
// Demonstrates AuraAppKernel (UIApplicationDelegate bridge). Registers
// an app-lifecycle plugin and boots the kernel. Scene lifecycle is handled
// by SceneDelegate (AuraSceneKernel).

@main
@MainActor
final class AppDelegate: AuraAppKernel {
    override init() {
        super.init()
        register(AppLifecyclePlugin.shared)
        try! boot()
    }
}
