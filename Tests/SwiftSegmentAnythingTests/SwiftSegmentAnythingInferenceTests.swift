//
//  SwiftSegmentAnythingInferenceTests.swift
//
//
//  Created by Anthony Dito on 9/18/23.
//

import Foundation
import XCTest
@testable import SwiftSegmentAnything

final class SwiftSegmentAnythingInferenceTests : XCTestCase {
    
    func testWarm() async throws {
        let url = URL(string: "https://www.ditotechnologies.com/images/starrynight.jpeg")!
        let ciImage = CIImage(contentsOf: url)!
        let sa = SwiftSegmentAnything.init()
        let inference = sa.inference(forCiImage: ciImage)
        try await inference.warm()
        print(try await sa.sessionPre().description)
    }
    
    func testGetMask() async throws {
        let url = URL(string: "https://www.ditotechnologies.com/images/starrynight.jpeg")!
        let ciImage = CIImage(contentsOf: url)!
        let sa = SwiftSegmentAnything.init()
        let inference = sa.inference(forCiImage: ciImage)
        let outputMask = try await inference.getMask(includePoints: [
            CGPoint(x: 100, y: 100)
        ], excludePoints: [])
        XCTAssertGreaterThan(outputMask.extent.width, 0)
        XCTAssertGreaterThan(outputMask.extent.height, 0)
    }
    
    func testGetMaskSanity2() async throws {
        let url = Bundle.module.url(forResource: "demo", withExtension: "jpg")!
        let ciImage = CIImage(contentsOf: url)!
        let sa = SwiftSegmentAnything.init()
        let inference = sa.inference(forCiImage: ciImage)
        let outputMask = try await inference.getMask(includePoints: [
            .init(x: 810, y: 550)
        ], excludePoints: [])
        XCTAssertGreaterThan(outputMask.extent.width, 0)
        XCTAssertGreaterThan(outputMask.extent.height, 0)
    }
    
    func testGetMaskSanityBox() async throws {
        let url = Bundle.module.url(forResource: "demo", withExtension: "jpg")!
        let ciImage = CIImage(contentsOf: url)!
        let sa = SwiftSegmentAnything.init()
        let inference = sa.inference(forCiImage: ciImage)
        let outputMask = try await inference.getMask(includePoints: [
            .init(x: 810, y: 550)
        ], excludePoints: [
            .init(x: 10, y: 10)
        ])
        XCTAssertGreaterThan(outputMask.extent.width, 0)
        XCTAssertGreaterThan(outputMask.extent.height, 0)
    }
    
    func testGetBoundingBoxesSanity() async throws {
        let url = Bundle.module.url(forResource: "demo", withExtension: "jpg")!
        let ciImage = CIImage(contentsOf: url)!
        let sa = SwiftSegmentAnything.init()
        let inference = sa.inference(forCiImage: ciImage)
        let outputMask = try await inference.getMask(includePoints: [
            .init(x: 810, y: 550)
        ], excludePoints: [])
        let boundingBoxes = try outputMask.boxes()
        XCTAssertGreaterThan(boundingBoxes.count, 0)
        for boundingBox in boundingBoxes {
            XCTAssertLessThan(boundingBox.width, 1)
        }
    }
}
