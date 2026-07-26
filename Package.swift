// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aura",
    products: [
        .library(name: "AuraDS", targets: ["AuraDS"]),
        .library(name: "AuraSDUI", targets: ["AuraSDUI"]),
    ],
    targets: [
        .target(
            name: "AuraDS",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .target(
            name: "AuraSDUI",
            dependencies: ["AuraDS"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "AuraDSTests",
            dependencies: ["AuraDS"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "AuraSDUITests",
            dependencies: ["AuraSDUI"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
