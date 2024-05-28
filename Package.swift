// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LambdaspireDoOnce",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LambdaspireDoOnce",
            targets: ["LambdaspireDoOnce"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Lambdaspire/Lambdaspire-Swift-Abstractions",
            from: "1.0.0"),
        .package(
            url: "https://github.com/Lambdaspire/Lambdaspire-Swift-DependencyResolution",
            from: "1.0.0")
    ],
    targets: [
        .target(
            name: "LambdaspireDoOnce",
            dependencies: [
                .product(name: "LambdaspireAbstractions", package: "Lambdaspire-Swift-Abstractions")
            ]),
        .testTarget(
            name: "LambdaspireDoOnceTests",
            dependencies: [
                "LambdaspireDoOnce",
                .product(name: "LambdaspireDependencyResolution", package: "Lambdaspire-Swift-DependencyResolution")
            ]),
    ]
)
