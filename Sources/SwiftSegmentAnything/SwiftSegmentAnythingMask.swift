//
//  SwiftSegmentAnythingResult.swift
//
//
//  Created by Anthony Dito on 9/27/23.
//

import Foundation
import CoreImage

/// A simple typealias around CIImage. Providing helper functions for commonly used operations when modifying masks
public typealias SwiftSegmentAnythingMask = CIImage

extension SwiftSegmentAnythingMask {
    
    /// Reduces the noise around the edges of a mask result
    ///
    /// The Segment Anything model can produce noise around the mask. By using this method, you can remove some of those little dots.
    public func closingGaps(radius: CGFloat = 10) -> SwiftSegmentAnythingMask {
        // run the morphology stuff
        fatalError()
    }
}
