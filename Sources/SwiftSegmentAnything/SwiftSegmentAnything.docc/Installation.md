# Installation

Learn how to install SwiftSegmentAnything in your app.

## Prequisite

The first thing that you need to do is get access to the code. Please reach out to `anthony@ditotechnologies.com` to get access for your comany.

## Via XCode

Add the package to XCode by using the GitHub repository.

### 1. Open the Add Package Dialog

Press `File > Add Package Dependency

This window should show up

@Image(source: "installpage1.png")

### 2. Enter the GitHub package URL in the top right corner. That would be []

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
