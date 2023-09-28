# ``SwiftSegmentAnything``

A Swift implementation of the [Segment Anything](https://segment-anything.com/) model. Add the power of Segment Anything to your app.

## Overview

Segment anything allows you to 

## Installation

### Xcode Project

### Package.Swift

To install, use...

## Demo

> We have a demo app! To see this package in use, download our app at 

## Basic Usage

```swift
import SwiftSegmentAnything

let image: UIImage = ...
let segmentAnything = SwiftSegmentAnything()
let inference = segmentAnything.inference(forUiImage: image)
let mask = try await inference.getMask(includePoints: [CGPoint(x: 500, y: 500)])
```

## Reporting an Issue

You can either report an GitHub issue [here](https://github.com/ditotechnologies/SwiftSegmentAnything/issues). Or, if you would like your issue to remain private. Please reach out to anthony@ditotechnologies.com
