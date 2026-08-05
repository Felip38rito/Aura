import ProjectDescription

let infoPlist: [String: Plist.Value] = [
    "UILaunchScreen": [:],
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
        "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
                [
                    "UISceneConfigurationName": "Default Configuration",
                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                ]
            ]
        ]
    ]
]

let project = Project(
    name: "AuraExample",
    targets: [
        .target(
            name: "AuraExample",
            destinations: [.iPhone, .macCatalyst],
            product: .app,
            bundleId: "com.nousresearch.aura.example",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "AuraKernel"),
                .external(name: "AuraDS"),
                .external(name: "AuraSDUI"),
            ]
        )
    ]
)
