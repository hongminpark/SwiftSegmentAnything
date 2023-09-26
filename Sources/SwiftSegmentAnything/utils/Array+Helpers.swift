//
//  Array.swift
//
//
//  Created by Anthony Dito on 9/19/23.
//

import Foundation

extension Float {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}

extension Array where Element == Float {
    func toData() -> Data {
        var byteArray: [UInt8] = []
        for value in self {
            byteArray.append(contentsOf: value.bytes)
        }
        return Data(byteArray)
    }
}
