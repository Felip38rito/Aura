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
            bundleId: "com.felip38rito.aura",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "AuraKernel"),
                .external(name: "AuraDS"),
                .external(name: "AuraSDUI"),
            ],
            settings: .settings(base: [
                "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "YES",
                "DEVELOPMENT_TEAM": "9V2UBM64QJ",
                "CODE_SIGN_STYLE": "Automatic",
            ])
        )
    ]
)
