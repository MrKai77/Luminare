//
//  LuminarePopoverModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-09.
//

import SwiftUI

public struct LuminarePopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let behavior: NSPopover.Behavior
    let attachmentAnchor: Alignment?
    let shouldHideAnchor: Bool?
    let shouldAnimate: Bool
    let popoverContent: () -> PopoverContent

    public func body(content: Content) -> some View {
        content
            .background(
                LuminarePopoverPresenter(
                    isPresented: $isPresented,
                    arrowEdge: arrowEdge,
                    behavior: behavior,
                    attachmentAnchor: attachmentAnchor,
                    shouldHideAnchor: shouldHideAnchor,
                    shouldAnimate: shouldAnimate,
                    content: popoverContent
                )
            )
    }
}
