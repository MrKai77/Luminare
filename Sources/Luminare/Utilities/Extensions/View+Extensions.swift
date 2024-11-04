//
//  View+Extensions.swift
//  
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

// MARK: - Popover

public extension View {
    @ViewBuilder func luminarePopover<Content>(
        arrowEdge: Edge = .bottom,
        trigger: LuminarePopoverTrigger = .onHover(),
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        shade: LuminarePopoverShade = .styled(),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        LuminarePopover(
            arrowEdge: arrowEdge,
            trigger: trigger,
            cornerRadius: cornerRadius,
            padding: padding,
            shade: shade,
            content: content
        ) {
            self
        }
    }
}

// MARK: - Popup

public extension View {
    @ViewBuilder func luminarePopup(
        material: NSVisualEffectView.Material = .popover,
        isPresented: Binding<Bool>
    ) -> some View {
        LuminarePopup(
            material: material,
            isPresented: isPresented
        ) {
            self
        }
    }
}

// MARK: - Background

public extension View {
    func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}
