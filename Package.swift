// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSegmentAnything",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftSegmentAnything",
            targets: ["SwiftSegmentAnything"]),
    ],
    dependencies: [
        .package(url: "https://github.com/microsoft/onnxruntime-swift-package-manager", revision: "ce64739"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SwiftSegmentAnything", dependencies: [
            .productItem(name: "onnxruntime", package: "onnxruntime-swift-package-manager", moduleAliases: nil, condition: nil)
        ], resources: [
            .process("Resources"),
        ]),
        .testTarget(
            name: "SwiftSegmentAnythingTests",
            dependencies: ["SwiftSegmentAnything"],
        resources: [
            .process("Resources")
        ]),
    ]
)
