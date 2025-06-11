//
//  NSImage+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/11/3.
//

import AppKit

extension NSImage {
    static func resize(_ url: URL, width: CGFloat) -> NSImage? {
        guard let inputImage = NSImage(contentsOf: url) else { return nil }
        let aspectRatio = inputImage.size.width / inputImage.size.height
        let thumbSize = NSSize(
            width: width,
            height: width / aspectRatio
        )

        let outputImage = NSImage(size: thumbSize)
        outputImage.lockFocus()
        inputImage.draw(
            in: NSRect(origin: .zero, size: thumbSize),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
        outputImage.unlockFocus()

        return outputImage
    }
}
