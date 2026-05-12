//
//  LuminarePopoverPresenter.swift
//  Luminare
//
//  Created by Kai Azim on 2026-01-17.
//

import SwiftUI

public struct LuminarePopoverPresenter<Content: View>: NSViewRepresentable {
    private let positioningOutset: CGFloat = 24

    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let behavior: NSPopover.Behavior
    let shouldHideAnchor: Bool?
    let shouldAnimate: Bool
    let content: () -> Content

    public func makeNSView(context _: Context) -> NSView {
        PopoverAnchorContainerView(positioningOutset: positioningOutset)
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        let coordinator = context.coordinator
        guard let anchorContainer = nsView as? PopoverAnchorContainerView else { return }
        let positioningView = anchorContainer.positioningView

        coordinator.configure(
            behavior: behavior,
            shouldHideAnchor: shouldHideAnchor,
            shouldAnimate: shouldAnimate
        )
        coordinator.reconcile(
            isPresented: isPresented,
            anchorView: positioningView,
            anchorRect: anchorRect(for: anchorContainer, in: positioningView),
            preferredEdge: edgeToNSRectEdge(arrowEdge)
        ) {
            HostedContent(
                content: content(),
                dismiss: {
                    coordinator.dismissFromContent()
                }
            )
        }
    }

    fileprivate struct HostedContent: View {
        let content: Content
        let dismiss: () -> ()

        var body: some View {
            content
                .environment(\.luminareDismiss, dismiss)
        }
    }

    public static func dismantleNSView(_: NSView, coordinator: Coordinator) {
        coordinator.closePopoverDuringDismantle()
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    final class PopoverAnchorContainerView: NSView {
        let positioningView = NSView()
        private let positioningOutset: CGFloat

        init(positioningOutset: CGFloat) {
            self.positioningOutset = positioningOutset
            super.init(frame: .zero)
            addSubview(positioningView)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layout() {
            super.layout()
            positioningView.frame = bounds.insetBy(dx: -positioningOutset, dy: -positioningOutset)
        }
    }

    @MainActor
    public class Coordinator: NSObject, NSPopoverDelegate {
        @Binding var isPresented: Bool
        private let popover: NSPopover
        private var hostingController: NSHostingController<HostedContent>?
        private var appliedShouldHideAnchor: Bool?
        private var isDismantling = false
        private var isClosingFromSwiftUI = false
        private var presentationID = 0

        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
            self.popover = NSPopover()
            super.init()

            popover.delegate = self
        }

        private func updateContent(_ rootView: HostedContent) {
            if let hostingController {
                hostingController.rootView = rootView
            } else {
                let hostingController = NSHostingController(rootView: rootView)
                self.hostingController = hostingController
            }

            guard let hostingController else { return }

            hostingController.view.layoutSubtreeIfNeeded()
            popover.contentSize = hostingController.view.fittingSize

            if popover.isShown {
                popover.contentViewController = hostingController
            }
        }

        func configure(
            behavior: NSPopover.Behavior,
            shouldHideAnchor: Bool?,
            shouldAnimate: Bool
        ) {
            popover.behavior = behavior
            popover.animates = shouldAnimate

            guard shouldHideAnchor != appliedShouldHideAnchor else { return }

            if let shouldHideAnchor {
                popover.setValue(NSNumber(value: shouldHideAnchor), forKey: "shouldHideAnchor")
            } else if appliedShouldHideAnchor != nil {
                popover.setValue(NSNumber(value: false), forKey: "shouldHideAnchor")
            }

            appliedShouldHideAnchor = shouldHideAnchor
        }

        fileprivate func reconcile(
            isPresented: Bool,
            anchorView: NSView,
            anchorRect: NSRect,
            preferredEdge: NSRectEdge,
            content: () -> HostedContent
        ) {
            if isPresented {
                guard anchorView.window != nil else { return }

                updateContent(content())
                guard !popover.isShown else { return }

                schedulePresentation(
                    anchorView: anchorView,
                    anchorRect: anchorRect,
                    preferredEdge: preferredEdge
                )
            } else if popover.isShown {
                closeFromSwiftUI()
            } else {
                cancelPendingPresentation()
                releaseContent()
            }
        }

        private func schedulePresentation(
            anchorView: NSView,
            anchorRect: NSRect,
            preferredEdge: NSRectEdge
        ) {
            presentationID += 1
            let presentationID = presentationID

            DispatchQueue.main.async { [weak self, weak anchorView] in
                guard let self else { return }
                guard presentationID == self.presentationID else { return }
                guard isPresented, !popover.isShown else { return }
                guard let anchorView, anchorView.window != nil else {
                    releaseContent()
                    return
                }
                guard let hostingController else { return }

                popover.contentViewController = hostingController
                popover.show(
                    relativeTo: anchorRect,
                    of: anchorView,
                    preferredEdge: preferredEdge
                )
            }
        }

        func dismissFromContent() {
            isPresented = false
            closeFromSwiftUI()
        }

        private func closeFromSwiftUI() {
            cancelPendingPresentation()
            guard popover.isShown else { return }

            isClosingFromSwiftUI = true
            popover.close()
        }

        func closePopoverDuringDismantle() {
            cancelPendingPresentation()

            guard popover.isShown else {
                releaseContent()
                return
            }

            isDismantling = true
            popover.close()
        }

        public func popoverDidClose(_: Notification) {
            let shouldUpdateBinding = !isDismantling && !isClosingFromSwiftUI
            isDismantling = false
            isClosingFromSwiftUI = false
            releaseContent()

            if shouldUpdateBinding {
                DispatchQueue.main.async { [weak self] in
                    self?.isPresented = false
                }
            }
        }

        private func releaseContent() {
            popover.contentViewController = nil
            hostingController = nil
        }

        private func cancelPendingPresentation() {
            presentationID += 1
        }
    }

    private func anchorRect(for nsView: NSView, in positioningView: NSView) -> NSRect {
        let translationAmount: CGFloat = shouldHideAnchor == true ? 4 : 0
        let anchorRect = positioningView.convert(nsView.bounds, from: nsView)
        let translatedRect: NSRect

        switch arrowEdge {
        case .top:
            translatedRect = anchorRect.offsetBy(dx: 0, dy: translationAmount)
        case .leading:
            translatedRect = anchorRect.offsetBy(dx: -translationAmount, dy: 0)
        case .bottom:
            translatedRect = anchorRect.offsetBy(dx: 0, dy: -translationAmount)
        case .trailing:
            translatedRect = anchorRect.offsetBy(dx: translationAmount, dy: 0)
        }

        return translatedRect.intersection(positioningView.bounds)
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
