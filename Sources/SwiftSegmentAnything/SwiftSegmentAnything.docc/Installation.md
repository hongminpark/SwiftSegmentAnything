# Installation

Learn how to install SwiftSegmentAnything in your app.

## Prequisite

The first thing that you need to do is get access to the code. Please reach out to `anthony@ditotechnologies.com` to get access for your comany.

## Via XCode



## Via Package.swift

Use the example below to install SwiftSegmentAnything for your package via a `Package.swift`.

```swift
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary"]),
    ],
    dependencies: [
        .package(url: "git@github.com:ditotechnologies/SwiftSegmentAnything.git", tag: "v1.0.0"),
    ],
    targets: [
        .target(name: "MyLibrary", dependencies: ["SwiftSegmentAnything"]),
    ]
)

```
