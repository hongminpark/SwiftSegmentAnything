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
        .target(
            name: "SwiftSegmentAnything",
            dependencies: [
                .product(name: "onnxruntime", package: "onnxruntime-swift-package-manager")
            ],
            resources: [
                .process("Resources"),
                // Add Info.plist for onnxruntime
                .process("OnnxInfo.plist")
            ]),
        .testTarget(
            name: "SwiftSegmentAnythingTests",
            dependencies: ["SwiftSegmentAnything"],
            resources: [
                .process("Resources")
            ]),
    ]
)
