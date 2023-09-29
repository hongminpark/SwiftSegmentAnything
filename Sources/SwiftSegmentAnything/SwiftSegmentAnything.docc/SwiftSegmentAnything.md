# ``SwiftSegmentAnything``

A Swift implementation of the [Segment Anything](https://segment-anything.com/) model. Add the power of Segment Anything to your app with this Swift Package.

## Getting Started

- <doc:Inquire>
- <doc:Installation>
- <doc:Support>

## Demos

- <doc:BoxDemo>: Segment based on a bounding box.

> tip: We have a demo app in the App Store! This is the best way to demo the capabilities of this package on your own content.


## Basic API Example

```swift
import SwiftSegmentAnything

let image: UIImage = ...
let segmentAnything = SwiftSegmentAnything()
let inference = segmentAnything.inference(forUiImage: image)
let mask = try await inference.getMask(includePoints: [CGPoint(x: 500, y: 500)])
```
