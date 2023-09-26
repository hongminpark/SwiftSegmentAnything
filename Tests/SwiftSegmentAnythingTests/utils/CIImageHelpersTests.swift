//
//  CIImageHelpersTests.swift
//
//
//  Created by Anthony Dito on 9/18/23.
//

import Foundation
import XCTest
import CoreImage
@testable import SwiftSegmentAnything

final class CIImageHelpersTests: XCTestCase {
    
    func testX() {
        let url = URL(string: "https://www.ditotechnologies.com/images/starrynight.jpeg")!
        let ciImage = CIImage(contentsOf: url)!
        let output = ciImage.resized(toWidth: 1024, height: 700)
        XCTAssertNotNil(output)
        let width = Int(output!.extent.width)
        let height = Int(output!.extent.height)        
        XCTAssertEqual(width, 1024)
        XCTAssertEqual(height, 700)
    }
}
