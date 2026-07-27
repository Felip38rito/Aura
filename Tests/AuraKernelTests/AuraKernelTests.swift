import Testing
@testable import AuraKernel

// MARK: - Test Doubles

final class BootRecorderPlugin: AuraKernelPlugin {
    let identifier: String
    let dependencies: [String]
    var bootOrder: Int = 0

    init(identifier: String, dependencies: [String] = []) {
        self.identifier = identifier
        self.dependencies = dependencies
    }

    func boot(kernel: AuraKernel) {
        bootOrder = Self._nextBootOrder
        Self._nextBootOrder += 1
    }

    nonisolated(unsafe) fileprivate static var _nextBootOrder: Int = 1

    nonisolated static func resetCounter() {
        _nextBootOrder = 1
    }
}

// MARK: - Test Helpers

@MainActor
func resetForTest() {
    AuraKernel.resetShared()
    BootRecorderPlugin.resetCounter()
}

// MARK: - Topological Sort Tests

@Suite("Topological Sort")
@MainActor
struct TopologicalSortTests {

    @Test("sorts plugins with no dependencies in registration order")
    func noDependencies() throws {
        resetForTest()
        let kernel = AuraKernel()
        let a = BootRecorderPlugin(identifier: "a")
        let b = BootRecorderPlugin(identifier: "b")
        let c = BootRecorderPlugin(identifier: "c")

        kernel.register(c)
        kernel.register(a)
        kernel.register(b)
        try kernel.boot()

        #expect(a.bootOrder == 2)
        #expect(b.bootOrder == 3)
        #expect(c.bootOrder == 1)
    }

    @Test("sorts plugins respecting dependencies")
    func withDependencies() throws {
        resetForTest()
        let kernel = AuraKernel()
        let db = BootRecorderPlugin(identifier: "db")
        let net = BootRecorderPlugin(identifier: "net", dependencies: ["db"])
        let feature = BootRecorderPlugin(identifier: "feature", dependencies: ["db", "net"])

        kernel.register(feature)
        kernel.register(net)
        kernel.register(db)
        try kernel.boot()

        #expect(db.bootOrder == 1)
        #expect(net.bootOrder == 2)
        #expect(feature.bootOrder == 3)
    }

    @Test("handles diamond dependency — siblings may be in any order")
    func diamondDependency() throws {
        resetForTest()
        let kernel = AuraKernel()
        let a = BootRecorderPlugin(identifier: "a")
        let b = BootRecorderPlugin(identifier: "b", dependencies: ["a"])
        let c = BootRecorderPlugin(identifier: "c", dependencies: ["a"])
        let d = BootRecorderPlugin(identifier: "d", dependencies: ["b", "c"])

        kernel.register(d)
        kernel.register(c)
        kernel.register(b)
        kernel.register(a)
        try kernel.boot()

        #expect(a.bootOrder == 1)
        #expect(d.bootOrder == 4)
        #expect(Set([b.bootOrder, c.bootOrder]) == Set([2, 3]))
    }

    @Test("throws on missing dependency")
    func missingDependency() {
        resetForTest()
        let kernel = AuraKernel()
        kernel.register(BootRecorderPlugin(identifier: "a", dependencies: ["nonexistent"]))

        #expect(throws: AuraKernelError.missingDependency(plugin: "a", dependency: "nonexistent")) {
            try kernel.boot()
        }
    }

    @Test("throws on cycle")
    func cycleDetection() {
        resetForTest()
        let kernel = AuraKernel()
        kernel.register(BootRecorderPlugin(identifier: "a", dependencies: ["b"]))
        kernel.register(BootRecorderPlugin(identifier: "b", dependencies: ["a"]))

        #expect(throws: AuraKernelError.cycleDetected(plugins: ["a", "b"])) {
            try kernel.boot()
        }
    }
}

// MARK: - Kernel Boot Tests

@Suite("Kernel Boot")
@MainActor
struct KernelBootTests {

    @Test("calls boot in dependency order")
    func bootOrder() throws {
        resetForTest()
        let kernel = AuraKernel()
        let db = BootRecorderPlugin(identifier: "db")
        let net = BootRecorderPlugin(identifier: "net", dependencies: ["db"])
        let feature = BootRecorderPlugin(identifier: "feature", dependencies: ["db", "net"])

        kernel.register(feature)
        kernel.register(net)
        kernel.register(db)
        try kernel.boot()

        #expect(db.bootOrder == 1)
        #expect(net.bootOrder == 2)
        #expect(feature.bootOrder == 3)
    }

    @Test("boot calls boot(kernel:) each time — not idempotent")
    func bootCalledEachTime() throws {
        resetForTest()
        let kernel = AuraKernel()
        let plugin = BootRecorderPlugin(identifier: "p")

        kernel.register(plugin)
        try kernel.boot()
        #expect(plugin.bootOrder == 1)

        try kernel.boot()
        #expect(plugin.bootOrder == 2)
    }

    @Test("boot sets shared singleton")
    func bootSetsShared() throws {
        resetForTest()
        let kernel = AuraKernel()
        try kernel.boot()

        #expect(AuraKernel.shared === kernel)
    }
}

// MARK: - Registration Tests

@Suite("Plugin Registration")
@MainActor
struct RegistrationTests {

    @Test("unregister removes plugin by identity")
    func unregister() {
        resetForTest()
        let kernel = AuraKernel()
        let plugin = BootRecorderPlugin(identifier: "p")
        kernel.register(plugin)
        #expect(kernel.pluginList.count == 1)

        kernel.unregister(plugin)
        #expect(kernel.pluginList.isEmpty)
    }

    @Test("reset clears all plugins")
    func reset() {
        resetForTest()
        let kernel = AuraKernel()
        kernel.register(BootRecorderPlugin(identifier: "a"))
        kernel.register(BootRecorderPlugin(identifier: "b"))
        #expect(kernel.pluginList.count == 2)

        kernel.reset()
        #expect(kernel.pluginList.isEmpty)
    }

    @Test("each kernel instance has its own plugins")
    func instanceIsolation() {
        resetForTest()
        let kernel1 = AuraKernel()
        let kernel2 = AuraKernel()
        let plugin = BootRecorderPlugin(identifier: "p")

        kernel1.register(plugin)
        #expect(kernel1.pluginList.count == 1)
        #expect(kernel2.pluginList.isEmpty)
    }
}
