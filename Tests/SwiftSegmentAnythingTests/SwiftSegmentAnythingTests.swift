import XCTest
@testable import SwiftSegmentAnything

final class SwiftSegmentAnythingV2Tests: XCTestCase {
    
    func testLoadModels() async throws {
        let sa = SwiftSegmentAnything()
        try await sa.warmIfNeeded()
    }
    
    func testGetInputSize() async throws {
        let inputSize = SwiftSegmentAnything.imageInputSize
        XCTAssertGreaterThan(inputSize.width, 0)
        XCTAssertGreaterThan(inputSize.height, 0)
    }
}
