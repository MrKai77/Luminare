
//
//  CIFilter+ColorCube.swift
//  SwiftUIColorizedControlExample
//
//  Created by Stephan Casas on 7/16/23.
//  Edited by Kai Azim on 2024-04-14.
//

import AppKit
import CoreImage

// From https://github.com/stephancasas/SwiftUIColorizedControlExample
extension CIFilter {

    /// Create a color cube in which every color is filtered
    /// into a single, solid color.
    static func colorCube(for solidColor: NSColor) -> CIFilter? {
        guard
            let solidColor = solidColor.usingColorSpace(.deviceRGB),
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            return nil
        }

        let size = 2 // Decreased loading time
        let capacity = size * size * size * 4
        var cube = Array(repeating: Float(0), count: capacity)

        let r = Float(solidColor.redComponent)
        let g = Float(solidColor.greenComponent)
        let b = Float(solidColor.blueComponent)
        let a = Float(solidColor.alphaComponent)

        for _b in 0..<size {
            for _g in 0..<size {
                for _r in 0..<size {
                    let i = 4 * ((_b * size * size) + (_g * size) + _r)
                    cube[i + 0] = r
                    cube[i + 1] = g
                    cube[i + 2] = b
                    cube[i + 3] = a
                }
            }
        }

        return CIFilter(
            name: "CIColorCubeWithColorSpace",
            parameters: [
                "inputCubeData": Data(bytes: &cube, count: capacity * MemoryLayout<Float>.size),
                "inputCubeDimension": size,
                "inputColorSpace": colorSpace
            ]
        )
    }
}
