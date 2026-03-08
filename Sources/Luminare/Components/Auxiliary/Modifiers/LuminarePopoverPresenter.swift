//
//  LuminarePopoverPresenter.swift
//  Luminare
//
//  Created by Kai Azim on 2026-01-17.
//

import SwiftUI

public struct LuminarePopoverPresenter<Content: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let behavior: NSPopover.Behavior
    let shouldHideAnchor: Bool?
    let shouldAnimate: Bool
    let content: () -> Content

    private func closePopover(_ context: Context) {
        context.coordinator.isPresented = false
        context.coordinator.popover?.close()
    }

    public func makeNSView(context _: Context) -> NSView {
        NSView()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented, context.coordinator.popover == nil, nsView.window != nil {
            let popover = NSPopover()
            let hostingController = NSHostingController(
                rootView: content()
                    .environment(\.luminareDismiss) { closePopover(context) }
            )

            hostingController.view.layoutSubtreeIfNeeded()
            let contentSize = hostingController.view.fittingSize
            popover.contentSize = contentSize
            popover.behavior = behavior
            popover.animates = shouldAnimate

            if let shouldHide = shouldHideAnchor {
                popover.setValue(NSNumber(value: shouldHide), forKey: "shouldHideAnchor")
            }

            popover.contentViewController = hostingController
            popover.delegate = context.coordinator

            let insetFactor: CGFloat = shouldHideAnchor == true ? 4 : 0
            var anchorRect = nsView.bounds.insetBy(dx: insetFactor, dy: insetFactor)
            if anchorRect.width < 0 { anchorRect.size.width = 0 }
            if anchorRect.height < 0 { anchorRect.size.height = 0 }

            popover.show(
                relativeTo: anchorRect,
                of: nsView,
                preferredEdge: edgeToNSRectEdge(arrowEdge)
            )
            context.coordinator.popover = popover

            if let parentWindow = nsView.window {
                context.coordinator.startObservingWindow(parentWindow)
            }
        } else if !isPresented, let popover = context.coordinator.popover {
            popover.close()
            context.coordinator.popover = nil
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    public class Coordinator: NSObject, NSPopoverDelegate {
        @Binding var isPresented: Bool
        var popover: NSPopover?

        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
            super.init()
        }

        func startObservingWindow(_ window: NSWindow) {
            // Observe when the window loses focus
            NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                // The parent window is no longer focused, close the popover
                DispatchQueue.main.async {
                    self.isPresented = false
                    self.popover?.close()
                }
            }
        }

        public func popoverWillClose(_: Notification) {
            DispatchQueue.main.async {
                self.isPresented = false
            }
        }

        public func popoverDidClose(_: Notification) {
            popover = nil
        }
    }

    private func edgeToNSRectEdge(_ edge: Edge) -> NSRectEdge {
        switch edge {
        case .top: .minY
        case .leading: .minX
        case .bottom: .maxY
        case .trailing: .maxX
        }
    }
}

public struct LuminarePopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let behavior: NSPopover.Behavior
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
                    shouldHideAnchor: shouldHideAnchor,
                    shouldAnimate: shouldAnimate,
                    content: popoverContent
                )
            )
    }
}
