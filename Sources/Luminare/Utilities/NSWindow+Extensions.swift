//
//  NSWindow+Extensions.swift
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

extension NSWindow {
    /// Sets the background blur of the window with a specified radius.
    /// - Parameter radius: The blur radius to apply.
    func setBackgroundBlur(radius: Int) {
        guard let connection = try? getCGSConnection() else {
            print("Failed to get CGS connection")
            return
        }

        let status = CGSSetWindowBackgroundBlurRadius(connection, windowNumber, radius)
        if status != noErr {
            print("Error setting blur radius: \(status)")
        }

        configureWindowAppearance()
    }

    private func configureWindowAppearance() {
        self.backgroundColor = .white.withAlphaComponent(0.0001)
        self.isOpaque = false
        self.ignoresMouseEvents = false
    }
}

// MARK: - Private APIs and Helper Functions

typealias CGSConnectionID = UInt32

@_silgen_name("CGSDefaultConnectionForThread")
func CGSDefaultConnectionForThread() -> CGSConnectionID?

@_silgen_name("CGSSetWindowBackgroundBlurRadius") @discardableResult
func CGSSetWindowBackgroundBlurRadius(
    _ connection: CGSConnectionID,
    _ windowNum: NSInteger,
    _ radius: Int
) -> OSStatus

extension NSWindow {
    /// Attempts to get the default CGS connection for the current thread.
    /// - Returns: A `CGSConnectionID` if successful, `nil` otherwise.
    fileprivate func getCGSConnection() throws -> CGSConnectionID {
        guard let connection = CGSDefaultConnectionForThread() else {
            throw NSError(
                domain: "com.Luminare.NSWindow",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to get CGS connection"]
            )
        }
        return connection
    }
}
