//
//  View+Extensions.swift
//  
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

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
