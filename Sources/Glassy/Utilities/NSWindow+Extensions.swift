//
//  NSWindow+Extensions.swift
//  
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

extension NSWindow {
    func setBackgroundBlur(radius: Int) {
        let connection: CGSConnectionID = CGSDefaultConnectionForThread()
        CGSSetWindowBackgroundBlurRadius(connection, windowNumber, radius)

        self.backgroundColor = .white.withAlphaComponent(0.0001)
        self.isOpaque = false
        self.ignoresMouseEvents = false
    }
}

// MARK: PRIVATE APIs
typealias CGSConnectionID = UInt32

@_silgen_name("CGSDefaultConnectionForThread")
func CGSDefaultConnectionForThread() -> CGSConnectionID

@_silgen_name("CGSSetWindowBackgroundBlurRadius") @discardableResult
func CGSSetWindowBackgroundBlurRadius(
    _ connection: CGSConnectionID,
    _ windowNum: NSInteger,
    _ radius: Int
) -> OSStatus
