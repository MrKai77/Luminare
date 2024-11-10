//
//  View+Extensions.swift
//  
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

public extension View {
    /// Adjusts the tint of the view, synchronously changing the `.tint()` modifier and the `\.luminareTint` environment
    /// value.
    @ViewBuilder func overrideTint(_ tint: @escaping () -> Color) -> some View {
        self
            .tint(tint())
            .environment(\.luminareTint, tint)
    }
}

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

// MARK: - Modal

public extension View {
    func luminareModal(
        isPresented: Binding<Bool>,
        closesOnDefocus: Bool = false,
        isCompact: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                closesOnDefocus: closesOnDefocus,
                isCompact: isCompact,
                content: content
            )
        )
    }
}

// MARK: - Background

public extension View {
    func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}
