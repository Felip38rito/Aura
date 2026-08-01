import ProjectDescription

let project = Project(
    name: "AuraExample",
    targets: [
        .target(
            name: "AuraExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.nousresearch.aura.example",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:]
            ]),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "AuraSDUI"),
                .external(name: "AuraDS"),
                .external(name: "AuraKernel"),
            ]
        )
    ]
)
