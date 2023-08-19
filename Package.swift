// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gysb",
    products: [
        .library(
            name: "GysbKit",
            type: .dynamic,
            targets: ["GysbKit"]
        ),
        .executable(
            name: "gysb",
            targets: ["gysb"])
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/BlueCryptor.git", from: "2.0.1")
    ],
    targets: [
        .target(name: "GysbBase",
                dependencies: ["Cryptor"]),
        .target(name: "GysbKit",
                dependencies: ["GysbBase"]),
        .target(name: "gysb",
                dependencies: ["GysbKit"]),
        .testTarget(name: "GysbKitTest",
                    dependencies: ["GysbKit"])
    ]
)
