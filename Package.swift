// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aura",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "AuraKernel", targets: ["AuraKernel"]),
        .library(name: "AuraDS", targets: ["AuraDS"]),
        .library(name: "AuraSDUI", targets: ["AuraSDUI"]),
        .library(name: "AuraConnect", targets: ["AuraConnect"]),
    ],
    targets: [
        .target(
            name: "AuraKernel",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .target(
            name: "AuraDS",
            dependencies: ["AuraKernel"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .target(
            name: "AuraSDUI",
            dependencies: ["AuraDS", "AuraKernel"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .target(
            name: "AuraConnect",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "AuraKernelTests",
            dependencies: ["AuraKernel"],
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
            dependencies: ["AuraSDUI", "AuraDS"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "AuraConnectTests",
            dependencies: ["AuraConnect"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
