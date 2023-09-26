//
//  CIImage+Helpers.swift
//
//
//  Created by Anthony Dito on 9/18/23.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

/// Extensions related to the CIImage
extension CIImage {
    
    func resized(toWidth width: Int, height: Int) -> CIImage? {
        let startAspect = Float(self.extent.width / self.extent.height)
        let targetAspect = Float(width) / Float(height)
        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = self
        filter.aspectRatio = targetAspect / startAspect
        filter.scale = Float(height) / Float(self.extent.height)
        return filter.outputImage
    }
}
