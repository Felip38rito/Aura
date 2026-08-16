import AuraKernel
import UIKit

// MARK: - AppLifecyclePlugin
//
// Lives in the AppDelegate kernel and observes UIApplication lifecycle.
// Singleton so the UI can read its state.

@MainActor
final class AppLifecyclePlugin: AuraKernelPlugin {
    static let shared = AppLifecyclePlugin()

    let identifier = "app-lifecycle"
    private(set) var launchCount: Int = 0

    func boot(kernel: AuraKernelBase) {
        launchCount = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        launchCount += 1
    }
}
