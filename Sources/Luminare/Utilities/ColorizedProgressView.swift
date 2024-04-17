//
//  ColorizedProgressView.swift
//  SwiftUIColorizedControlExample
//
//  Created by Stephan Casas on 7/16/23.
//

import SwiftUI;

struct ColorizedToggleButton: NSViewRepresentable {

    @Binding private var value: Bool
    @Binding private var indicatorColor: NSColor

    init(isOn value: Binding<Bool>, color: Binding<NSColor>) {
        self._value = value
        self._indicatorColor = color
    }

    private func applyState(in view: NSSwitch) {
        view.state = self.value ? .on : .off
        view.controlSize = .small

        if let color = self.indicatorColor.usingColorSpace(.displayP3),
           let filter = CIFilter.colorCube(for: color) {
            view.contentFilters = [filter];
        }
    }

    func makeNSView(context: Context) -> NSSwitch {
        let view = NSSwitch();
        self.applyState(in: view)
        return view;
    }

    func updateNSView(_ nsView: NSSwitch, context: Context) {
        self.applyState(in: nsView);
    }
}

//
//  CIFilter+ColorCube.swift
//  SwiftUIColorizedControlExample
//
//  Created by Stephan Casas on 7/16/23.
//

//import Foundation;
//import AppKit;
import CoreImage;

extension CIFilter {

    /// Create a color cube in which every color is filtered
    /// into a single, solid color.
    ///
    static func colorCube(for solidColor: NSColor) -> CIFilter? {
        guard
            let solidColor = solidColor.usingColorSpace(.deviceRGB),
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            return nil
        }

        let size = 2; // Decreased loading time
        let capacity = size * size * size * 4;
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
