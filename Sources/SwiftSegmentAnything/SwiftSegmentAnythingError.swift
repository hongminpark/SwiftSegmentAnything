import Foundation

/// Errors that can occur from the Swift Segment Anything.
public enum SwiftSegmentAnythingError : Error {
    
    /// An unexpected internal error. Please reach out to Dito Technologies LLC. should you see an error of this enum. This is not expected.
    case internalError(description: String)
    
    case segmentAnythingDeallocated
    
    case preprocessingFailed
    
    case maskFinderFailed
    
    case invalidImage
}
