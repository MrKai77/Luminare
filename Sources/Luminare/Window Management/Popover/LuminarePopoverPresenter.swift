//
//  LuminarePopoverPresenter.swift
//  Luminare
//
//  Created by Kai Azim on 2026-01-17.
//

import SwiftUI

public struct LuminarePopoverPresenter<Content: View>: NSViewRepresentable {
    private let minimumPositioningOutset: CGFloat = 24

    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let behavior: NSPopover.Behavior
    let attachmentAnchor: Alignment?
    let shouldHideAnchor: Bool?
    let shouldAnimate: Bool
    let content: () -> Content

    public func makeNSView(context _: Context) -> NSView {
        PopoverAnchorContainerView(minimumPositioningOutset: minimumPositioningOutset)
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
            anchorContainer: anchorContainer,
            anchorView: positioningView,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            shouldHideAnchor: shouldHideAnchor,
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
        private let minimumPositioningOutset: CGFloat
        private var positioningOutset: CGFloat

        init(minimumPositioningOutset: CGFloat) {
            self.minimumPositioningOutset = minimumPositioningOutset
            self.positioningOutset = minimumPositioningOutset
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

        func updatePositioningOutset(for contentSize: CGSize) {
            let nextOutset = max(minimumPositioningOutset, contentSize.width, contentSize.height)
            guard nextOutset != positioningOutset else { return }

            positioningOutset = nextOutset
            needsLayout = true
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
            anchorContainer: PopoverAnchorContainerView,
            anchorView: NSView,
            attachmentAnchor: Alignment?,
            arrowEdge: Edge,
            shouldHideAnchor: Bool?,
            preferredEdge: NSRectEdge,
            content: () -> HostedContent
        ) {
            if isPresented {
                guard anchorView.window != nil else { return }

                updateContent(content())
                anchorContainer.updatePositioningOutset(for: popover.contentSize)
                anchorContainer.layoutSubtreeIfNeeded()

                let anchorRect = LuminarePopoverPresenter<Content>.anchorRect(
                    for: anchorContainer,
                    in: anchorView,
                    attachmentAnchor: attachmentAnchor,
                    arrowEdge: arrowEdge,
                    preferredEdge: preferredEdge,
                    popoverSize: popover.contentSize,
                    shouldHideAnchor: shouldHideAnchor
                )

                if popover.isShown {
                    popover.positioningRect = anchorRect
                    return
                }

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

    private static func anchorRect(
        for nsView: NSView,
        in positioningView: NSView,
        attachmentAnchor: Alignment?,
        arrowEdge: Edge,
        preferredEdge: NSRectEdge,
        popoverSize: CGSize,
        shouldHideAnchor: Bool?
    ) -> NSRect {
        let translationAmount: CGFloat = shouldHideAnchor == true ? 4 : 0
        let anchorRect = positioningView.convert(nsView.bounds, from: nsView)
        let baseRect: NSRect

        if let attachmentAnchor {
            baseRect = Self.alignedAnchorRect(
                in: anchorRect,
                attachmentAnchor: attachmentAnchor,
                preferredEdge: preferredEdge,
                popoverSize: popoverSize
            )
        } else {
            baseRect = anchorRect
        }

        let translatedRect: NSRect

        switch arrowEdge {
        case .top:
            translatedRect = baseRect.offsetBy(dx: 0, dy: translationAmount)
        case .leading:
            translatedRect = baseRect.offsetBy(dx: -translationAmount, dy: 0)
        case .bottom:
            translatedRect = baseRect.offsetBy(dx: 0, dy: -translationAmount)
        case .trailing:
            translatedRect = baseRect.offsetBy(dx: translationAmount, dy: 0)
        }

        return translatedRect
    }

    private static func alignedAnchorRect(
        in rect: NSRect,
        attachmentAnchor: Alignment,
        preferredEdge: NSRectEdge,
        popoverSize: CGSize
    ) -> NSRect {
        let roundedCornerAdjustment: CGFloat = 24
        let horizontalAlignmentWidth = max(popoverSize.width - roundedCornerAdjustment, 1)
        let verticalAlignmentHeight = max(popoverSize.height - roundedCornerAdjustment, 1)

        let minX: CGFloat = switch attachmentAnchor {
        case .topLeading, .leading, .bottomLeading:
            rect.minX
        case .top, .center, .bottom:
            rect.midX - horizontalAlignmentWidth / 2
        case .topTrailing, .trailing, .bottomTrailing:
            rect.maxX - horizontalAlignmentWidth
        default:
            rect.midX - horizontalAlignmentWidth / 2
        }

        let minY: CGFloat = switch attachmentAnchor {
        case .bottomLeading, .bottom, .bottomTrailing:
            rect.minY
        case .leading, .center, .trailing:
            rect.midY - verticalAlignmentHeight / 2
        case .topLeading, .top, .topTrailing:
            rect.maxY - verticalAlignmentHeight
        default:
            rect.midY - verticalAlignmentHeight / 2
        }

        switch preferredEdge {
        case .minY, .maxY:
            let y = preferredEdge == .minY ? rect.minY : rect.maxY - 1
            return NSRect(x: minX, y: y, width: horizontalAlignmentWidth, height: 1)
        case .minX, .maxX:
            let x = preferredEdge == .minX ? rect.maxX - 1 : rect.minX
            return NSRect(x: x, y: minY, width: 1, height: verticalAlignmentHeight)
        @unknown default:
            return NSRect(x: minX, y: rect.maxY - 1, width: horizontalAlignmentWidth, height: 1)
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
