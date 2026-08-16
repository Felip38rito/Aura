import AuraKernel
import Foundation

#if canImport(UIKit)
import UIKit

@MainActor
final class LoggingPlugin: AuraKernelPlugin {
    let identifier = "logging"
    private(set) var events: [String] = []

    func boot(kernel: AuraKernelBase) {
        events.append("boot")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        events.append("sceneDidBecomeActive")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        events.append("sceneDidEnterBackground")
    }
}

#endif