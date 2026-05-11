//
//  LuminareModalModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

struct LuminareModalModifier<ModalContent>: ViewModifier
    where ModalContent: View {
    @Environment(\.luminareTintColor) private var tintColor
    @Environment(\.luminareModalStyle) private var style
    @Environment(\.luminareModalCornerRadius) private var modalCornerRadius
    @Environment(\.luminareModalPresentation) private var modalPresentation
    @Environment(\.luminareModalClosesOnDefocus) private var modalClosesOnDefocus

    @State private var panelController: NSWindowController?

    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> ModalContent

    func body(content: Content) -> some View {
        switch style {
        case .sheet:
            content
                .onChange(of: isPresented) { newValue in
                    if newValue {
                        presentSheet()
                    } else {
                        closeSheet()
                    }
                }
                .onDisappear {
                    isPresented = false
                    closeSheet()
                }
        case let .popover(attachmentAnchor, arrowEdge):
            content
                .popover(
                    isPresented: $isPresented,
                    attachmentAnchor: attachmentAnchor,
                    arrowEdge: arrowEdge
                ) {
                    self.content()
                        .luminareTint(overridingWith: tintColor)
                }
        }
    }

    private func presentSheet() {
        guard panelController?.window == nil else { return }
        let panel = LuminareWindow(
            _internalConfiguration: (),
            titleBarButtonConfiguration: nil,
            cornerRadius: modalCornerRadius,
            canBecomeMain: false,
            closesOnDefocus: modalClosesOnDefocus,
            initialOrigin: { modalPresentation.origin(of: $0) },
            onClose: {
                isPresented = false
            }
        ) {
            LuminareModalView {
                self.content()
                    .luminareTint(overridingWith: tintColor)
            }
        }
        panel.level = .floating
        panel.collectionBehavior.formUnion(.fullScreenAuxiliary)
        panel.animationBehavior = .documentWindow

        DispatchQueue.main.async {
            panel.makeKeyAndOrderFront(nil)
            panel.makeFirstResponder(panel.contentView)
        }

        panelController = .init(window: panel)
    }

    private func closeSheet() {
        panelController?.close()
        panelController = nil
    }
}
