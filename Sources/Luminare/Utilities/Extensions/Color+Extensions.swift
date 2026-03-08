//
//  Color+Extensions.swift
//  Luminare
//
//  Created by Kai Azim on 2024-05-13.
//

import AppKit
import SwiftUI

/// A shorthand for storing colors in hue-saturation-brightness format
struct HSBColor: Equatable, Hashable, Codable, Sendable {
    var hue: Double
    var saturation: Double
    var brightness: Double
    var opacity: Double

    init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.opacity = opacity
    }

    init(rgb: Color) {
        self = rgb.toHSB()
    }

    var rgb: Color {
        get {
            .init(hsb: self)
        }

        set {
            self = .init(rgb: newValue)
        }
    }
}

/// Adds functionality to `Color`
extension Color {
    /// Initializes with a hex value, supporting both 3 and 6 characters
    init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        let expandedHex: String = if hexSanitized.count == 3 {
            hexSanitized
                .map { "\($0)\($0)" }
                .joined()
        } else {
            hexSanitized
        }

        let rgbValue = UInt64(expandedHex, radix: 16) ?? 0

        if rgbValue == 0, expandedHex != "000000" {
            NSLog("Invalid HEX value provided: \(hex)")
            return nil
        }

        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }

    init(hsb: HSBColor) {
        self.init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, opacity: hsb.opacity)
    }

    /// Converts to hex representation
    func toHex() -> String {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? .black
        return String(
            format: "#%02X%02X%02X", Int(nsColor.redComponent * 255), Int(nsColor.greenComponent * 255),
            Int(nsColor.blueComponent * 255)
        )
    }

    /// Converts to HSB representatoin
    func toHSB() -> HSBColor {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor.black
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return .init(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }

    /// Extracts RGBA components
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        get {
            let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor.black
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (red, green, blue, alpha)
        }

        set {
            self = .init(red: newValue.red, green: newValue.green, blue: newValue.blue, opacity: newValue.opacity)
        }
    }

    var hsb: HSBColor {
        get {
            .init(rgb: self)
        }

        set {
            self = .init(hsb: newValue)
        }
    }
}

extension Color {
    static let disabledControlTextColor: Color = .init(NSColor.disabledControlTextColor)
}
