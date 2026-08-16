#if canImport(UIKit)
import Testing
import UIKit
@testable import AuraKernel

// MARK: - Test Doubles

final class LifecycleRecorderPlugin: AuraKernelPlugin {
    let identifier = "lifecycle-recorder"
    var events: [String] = []

    func boot(kernel: AuraKernel) {
        events.append("boot")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        events.append("didBecomeActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        events.append("didEnterBackground")
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        events.append("sceneWillConnect")
    }
}

final class LaunchResultPlugin: AuraKernelPlugin {
    let identifier = "launch-result"
    let shouldReturn: Bool

    init(shouldReturn: Bool) {
        self.shouldReturn = shouldReturn
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        shouldReturn
    }
}

// MARK: - AuraAppKernel Lifecycle Forwarding Tests

@Suite("AuraAppKernel Lifecycle Forwarding")
@MainActor
struct AppKernelLifecycleTests {

    @Test("forwards applicationDidBecomeActive to all plugins")
    func forwardsDidBecomeActive() throws {
        let kernel = AuraAppKernel()
        let plugin = LifecycleRecorderPlugin()
        kernel.register(plugin)
        try kernel.boot()

        kernel.applicationDidBecomeActive(UIApplication.shared)

        #expect(plugin.events == ["boot", "didBecomeActive"])
    }

    @Test("returns true when all plugins return true for didFinishLaunching")
    func allLaunchSucceed() throws {
        let kernel = AuraAppKernel()
        kernel.register(LaunchResultPlugin(shouldReturn: true))
        kernel.register(LaunchResultPlugin(shouldReturn: true))
        try kernel.boot()

        let result = kernel.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        #expect(result == true)
    }

    @Test("returns false when any plugin returns false for didFinishLaunching")
    func oneLaunchFails() throws {
        let kernel = AuraAppKernel()
        kernel.register(LaunchResultPlugin(shouldReturn: true))
        kernel.register(LaunchResultPlugin(shouldReturn: false))
        kernel.register(LaunchResultPlugin(shouldReturn: true))
        try kernel.boot()

        let result = kernel.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        #expect(result == false)
    }
}

// MARK: - AuraSceneKernel Lifecycle Forwarding Tests
//
// NOTE: The scene lifecycle forwarding (scene(_:willConnectTo:options:)) is not
// unit-tested here because UISceneSession and UIScene.ConnectionOptions have no
// public initializers, so the arguments cannot be constructed in a test. The
// forwarding logic is exercised indirectly via the AuraExample app.

#endif
