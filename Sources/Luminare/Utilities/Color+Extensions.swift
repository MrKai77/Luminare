//
//  Color+Extensions.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

extension Color {

    // https://stackoverflow.com/a/58155074
    init(hex string: String) {
        var hexSanitized: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        // Double the last value if incomplete hex
        if !hexSanitized.count.isMultiple(of: 2), let last = hexSanitized.last {
            hexSanitized.append(last)
        }

        // Fix invalid values
        if hexSanitized.count > 8 {
            hexSanitized = String(hexSanitized.prefix(8))
        }

        let scanner = Scanner(string: hexSanitized)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if hexSanitized.count <= 4 {
            // In a 4 character format, last two are opacity, which aren't needed
            hexSanitized = String(hexSanitized.prefix(2))
            let mask = 0xFF

            let g = Int(color) & mask
            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if hexSanitized.count <= 8 {
            // In a 8 character format, last two are opacity, which aren't needed
            hexSanitized = String(hexSanitized.prefix(6))
            let mask = 0x0000FF

            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }

    func toHex() -> String {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor.black
        let red = nsColor.redComponent
        let green = nsColor.greenComponent
        let blue = nsColor.blueComponent
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
