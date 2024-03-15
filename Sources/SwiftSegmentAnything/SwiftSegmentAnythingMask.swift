//
//  SwiftSegmentAnythingResult.swift
//
//
//  Created by Anthony Dito on 9/27/23.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

/// A simple typealias around CIImage. Providing helper functions for commonly used operations when modifying masks
public typealias SwiftSegmentAnythingMask = CIImage

extension SwiftSegmentAnythingMask {
    
    /// Reduces the noise around the edges of a mask result
    ///
    /// - Parameter radius: The radius of noise to be closed.
    ///
    /// The Segment Anything model can produce noise around the mask. By using this method, you can remove some of those little dots.
    public func closingGaps(radius: Float = 10) throws -> SwiftSegmentAnythingMask {
        if radius < 0 {
            throw SwiftSegmentAnythingError.invalidInput(description: "radius must be greater than 0")
        } else if radius == 0 {
            return self
        }
        // run the morphology stuff
        let minFilter = CIFilter.morphologyMinimum()
        minFilter.radius = radius
        minFilter.inputImage = self
        let maxFilter = CIFilter.morphologyMaximum()
        maxFilter.radius = radius
        maxFilter.inputImage = minFilter.outputImage
        guard let result = maxFilter.outputImage else {
            throw SwiftSegmentAnythingError.internalError(description: "unexpected closing caps image result")
        }
        return result
    }
    
    public func paths() throws -> [CGPath] {
        let request = VNDetectContoursRequest()
        let imageRequestHandler = VNImageRequestHandler(ciImage: self)
        try imageRequestHandler.perform([request])
        guard let results = request.results else {
            throw SwiftSegmentAnythingError.contourRequestFailed
        }
        return results.flatMap({ $0.topLevelContours }).flatMap({ $0.childContours }).map({ $0.normalizedPath })
    }
    
    public func boxes() throws -> [CGRect] {
        return try self.paths().map({ $0.boundingBox })
    }
}
