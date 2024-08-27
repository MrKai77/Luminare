//
//  PopoverPanel.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//


import SwiftUI

public class PopoverPanel: NSPanel, ObservableObject {
    public static let cornerRadius: CGFloat = 12
    public static let contentPadding: CGFloat = 6
    public static let sectionPadding: CGFloat = 8

    @Published public var closeHandler: (() -> Void)?

    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView, .titled],
            backing: .buffered,
            defer: false
        )
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isOpaque = false
        ignoresMouseEvents = false
        becomesKeyOnlyIfNeeded = true
        level = .floating
    }

    public override var canBecomeKey: Bool {
        true
    }

    public override var canBecomeMain: Bool {
        false
    }

    public override var acceptsFirstResponder: Bool {
        true
    }

    public override func close() {
        closeHandler?()
        super.close()
    }

    public override func resignKey() {
        close()
    }
}
