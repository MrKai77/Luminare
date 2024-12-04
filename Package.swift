// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Luminare",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Luminare",
            targets: ["Luminare"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Luminare"
        ),
        .testTarget(
            name: "LuminareTests",
            dependencies: [
                "Luminare"
            ]
        )
    ]
)
