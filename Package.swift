// swift-tools-version: 5.10
// the swift-tools-version declares the minimum version of Swift required to build this package

import PackageDescription

let package = Package(
    name: "Luminare",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // products define the executables and libraries a package produces, making them visible to other packages
        .library(
            name: "Luminare",
            targets: ["Luminare"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // targets are the basic building blocks of a package, defining a module or a test suite
        // targets can depend on other targets in this package and products from dependencies
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
