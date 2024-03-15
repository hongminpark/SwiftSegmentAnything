import Foundation

/// Errors that can occur from the Swift Segment Anything.
public enum SwiftSegmentAnythingError : Error {
    
    /// An unexpected internal error. Please reach out to Dito Technologies LLC. should you see an error of this enum. This is not expected.
    ///
    /// If you encounter this error, please reach out to Dito Technologies LLC. Providing the image and input in which this error happened is greatly appreciated.
    case internalError(description: String)
        
    case preprocessingFailed
    
    case maskFinderFailed
    
    case invalidImage
    
    /// An error thrown when there is no input given to the inference. Please include either `inputPoints`, `excludePoints` and or `includeBoxes` for the input to getMasks.
    case noInput
    
    case invalidInput(description: String)
    
    /// an error thrown when contour requests fail when processing a segment anything mask
    case contourRequestFailed
}
