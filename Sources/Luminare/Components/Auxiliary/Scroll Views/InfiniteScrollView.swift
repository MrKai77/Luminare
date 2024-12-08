//
//  InfiniteScrollView.swift
//
//
//  Created by KrLite on 2024/11/2.
//

import AppKit
import SwiftUI

/// The direction of an ``InfiniteScrollView``.
public enum InfiniteScrollViewDirection: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    /// The view can, and can only be scrolled horizontally.
    case horizontal
    /// The view can, and can only be scrolled vertically.
    case vertical

    public var id: String { rawValue }

    /// Initializes an ``InfiniteScrollViewDirection`` from an `Axis`.
    public init(axis: Axis) {
        switch axis {
        case .horizontal:
            self = .horizontal
        case .vertical:
            self = .vertical
        }
    }

    /// The scrolling `Axis` of the ``InfiniteScrollView``.
    public var axis: Axis {
        switch self {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        }
    }
    
    /// The opposite direction.
    public var opposite: Self {
        switch self {
        case .horizontal:
                .vertical
        case .vertical:
                .horizontal
        }
    }

    func stack(spacing: CGFloat, views: [NSView]) -> NSStackView {
        let stackView = NSStackView(views: views)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = spacing
        
        switch self {
        case .horizontal:
            stackView.orientation = .horizontal
        case .vertical:
            stackView.orientation = .vertical
        }
        
        return stackView
    }

    // gets the length from the given 2D size according to the direction
    func length(of size: CGSize) -> CGFloat {
        switch self {
        case .horizontal:
            size.width
        case .vertical:
            size.height
        }
    }

    // gets the offset from the given 2D point according to the direction
    func offset(of point: CGPoint) -> CGFloat {
        switch self {
        case .horizontal:
            point.x
        case .vertical:
            point.y
        }
    }

    // forms a point from the given offset according to the direction
    func point(from offset: CGFloat) -> CGPoint {
        switch self {
        case .horizontal:
            .init(x: offset, y: 0)
        case .vertical:
            .init(x: 0, y: offset)
        }
    }

    // forms a size from the given length according to the direction
    func size(from length: CGFloat, fallback: CGFloat) -> CGSize {
        switch self {
        case .horizontal:
            .init(width: length, height: fallback)
        case .vertical:
            .init(width: fallback, height: length)
        }
    }
}

// MARK: - Infinite Scroll

/// An auxiliary view that handles infinite scrolling with conditional wrapping and snapping support.
///
/// The fundamental effect is achieved through resetting the scrolling position after every scroll event that reaches
/// the specified page length.
///
/// The scrolling result can be listened through ``InfiniteScrollView/offset`` and ``InfiniteScrollView/page``,
/// respectively representing the offset from the page and the scrolled page count.
public struct InfiniteScrollView: NSViewRepresentable {
    public typealias Direction = InfiniteScrollViewDirection

    @Environment(\.luminareAnimationFast) private var animationFast

    var debug: Bool = false
    /// The ``InfiniteScrollViewDirection`` that defines the scrolling direction.
    public var direction: Direction
    /// Whether mouse dragging is allowed as an alternative of scrolling.
    /// Overscrolling is not allowed when dragging.
    public var allowsDragging: Bool = true

    /// The explicit size of the scroll view.
    @Binding public var size: CGSize
    /// the spacing between pages.
    @Binding public var spacing: CGFloat
    /// Whether snapping is enabled.
    ///
    /// If snapping is enabled, the view will automatically snaps to the nearest available page anchor with animation.
    /// Otherwise, scrolling can stop at arbitrary midpoints.
    @Binding public var snapping: Bool
    /// Whether wrapping is enabled.
    ///
    /// If wrapping is enabled, the view will always allow infinite scrolling by constantly resetting the scrolling
    /// position.
    /// Otherwise, the view won't lock the scrollable region and allows overscrolling to happen.
    @Binding public var wrapping: Bool
    /// The initial offset of the scroll view.
    ///
    /// Can be useful when arbitrary initialization points are required.
    @Binding public var initialOffset: CGFloat

    /// Whether the scroll view should be resetted.
    ///
    /// This will automatically be set to `false` after a valid reset happens.
    @Binding public var shouldReset: Bool
    /// The offset from the nearest page.
    ///
    /// This binding is get-only.
    @Binding public var offset: CGFloat
    /// The scrolled page count.
    ///
    /// This binding is get-only.
    @Binding public var page: Int

    var length: CGFloat {
        direction.length(of: size)
    }

    var scrollableLength: CGFloat {
        length + spacing * 2
    }

    var centerRect: CGRect {
        .init(origin: direction.point(from: (scrollableLength - length) / 2), size: size)
    }

    private let firstSpacer: NSView = .init()
    private let centerSpacer: NSView = .init()
    private let lastSpacer: NSView = .init()

    func onBoundsChange(_ bounds: CGRect, animate: Bool = false) {
        let offset = direction.offset(of: bounds.origin) - direction.offset(of: centerRect.origin)
        if animate {
            withAnimation(animationFast) {
                self.offset = offset
            }
        } else {
            self.offset = offset
        }
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        
        // allocate the scrollable views
        do {
            let size = direction.size(from: spacing, fallback: direction.opposite.length(of: size))
            firstSpacer.translatesAutoresizingMaskIntoConstraints = false
            lastSpacer.translatesAutoresizingMaskIntoConstraints = false
            
            firstSpacer.wantsLayer = true
            lastSpacer.wantsLayer = true
            
            firstSpacer.layer?.backgroundColor = debug ? NSColor.red.cgColor : .clear
            lastSpacer.layer?.backgroundColor = debug ? NSColor.red.cgColor : .clear
            
            firstSpacer.setFrameSize(size)
            lastSpacer.setFrameSize(size)
        }
        
        do {
            centerSpacer.translatesAutoresizingMaskIntoConstraints = false
            centerSpacer.wantsLayer = true
            centerSpacer.layer?.backgroundColor = debug ? NSColor.red.withAlphaComponent(0.1).cgColor : .clear
            centerSpacer.setFrameSize(size)
        }
        
        let clipView = NSClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false
        clipView.drawsBackground = false
        scrollView.contentView = clipView
        NSLayoutConstraint.activate([
            .init(item: clipView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0),
            .init(item: clipView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: clipView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0),
            .init(item: clipView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        
        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView
        
        switch direction.axis {
        case .horizontal:
            NSLayoutConstraint.activate([
                clipView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                clipView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
            ])
        case .vertical:
            NSLayoutConstraint.activate([
                clipView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                clipView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
        }
        
        do {
            let directionString = switch direction.axis {
            case .horizontal: "V"
            case .vertical: "H"
            }
            
            documentView.addSubview(firstSpacer)
            documentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "\(directionString):|[first]|",
                metrics: nil,
                views: ["first": firstSpacer]
            ))
            
            documentView.addSubview(centerSpacer)
            documentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "\(directionString):|[center]|",
                metrics: nil,
                views: ["center": centerSpacer]
            ))
            
            documentView.addSubview(lastSpacer)
            documentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "\(directionString):|[last]|",
                metrics: nil,
                views: ["last": lastSpacer]
            ))
        }
        
        do {
            let directionString = switch direction.axis {
            case .horizontal: "H"
            case .vertical: "V"
            }
            
            documentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "\(directionString):|[first(==\(spacing))][center][last(==\(spacing))]|",
                metrics: nil,
                views: ["first": firstSpacer, "center": centerSpacer, "last": lastSpacer]
            ))
        }

        // observe when scrolls
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.didLiveScroll(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )

        // observe when scrolling starts
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.willStartLiveScroll(_:)),
            name: NSScrollView.willStartLiveScrollNotification,
            object: scrollView
        )

        // observe when scrolling ends
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.didEndLiveScroll(_:)),
            name: NSScrollView.didEndLiveScrollNotification,
            object: scrollView
        )

        return scrollView
    }

    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        print(scrollableLength)
        if let documentView = nsView.documentView {
            documentView.heightAnchor.constraint(equalToConstant: scrollableLength).isActive = true
            centerSpacer.heightAnchor.constraint(equalToConstant: length).isActive = true
        }
        
        DispatchQueue.main.async {
            context.coordinator.initializeScroll(nsView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject {
        private enum DraggingStage: Equatable {
            case invalid
            case preparing
            case dragging
        }

        var parent: InfiniteScrollView

        private var offsetOrigin: CGFloat = .zero
        private var pageOrigin: Int = .zero

        private var lastOffset: CGFloat = .zero
        private var lastPageOffset: Int = .zero

        private var monitor: Any?
        private var draggingStage: DraggingStage = .invalid

        init(_ parent: InfiniteScrollView) {
            self.parent = parent
        }

        func initializeScroll(_ scrollView: NSScrollView) {
            let clipView = scrollView.contentView

            // reset if required
            if parent.shouldReset {
                resetScrollViewPosition(clipView, offset: parent.direction.point(from: parent.initialOffset))
                pageOrigin = parent.page
            }

            // set dragging monitor if required
            if parent.allowsDragging {
                // deduplicating
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }

                monitor = NSEvent.addLocalMonitorForEvents(matching: [
                    .leftMouseDown, .leftMouseUp, .leftMouseDragged
                ]) { [weak self] event in
                    let location = clipView.convert(event.locationInWindow, from: nil)
                    guard let self else { return event }

                    // ensure the dragging *happens* inside the view and can *continue* anywhere else
                    let canIgnoreBounds = draggingStage == .dragging
                    guard canIgnoreBounds || clipView.bounds.contains(location) else { return event }

                    switch event.type {
                    case .leftMouseDown:
                        // indicates dragging might start in the future
                        draggingStage = .preparing
                    case .leftMouseUp:
                        switch draggingStage {
                        case .invalid:
                            break
                        case .preparing:
                            // invalidates dragging
                            draggingStage = .invalid
                        case .dragging:
                            // ends dragging
                            draggingStage = .invalid
                            didEndLiveScroll(.init(
                                name: NSScrollView.didEndLiveScrollNotification,
                                object: scrollView
                            )
                            )
                        }
                    case .leftMouseDragged:
                        // always update view bounds first
                        clipView.setBoundsOrigin(clipView.bounds.origin.applying(
                            .init(translationX: -event.deltaX, y: -event.deltaY)
                        ))

                        switch draggingStage {
                        case .invalid:
                            break
                        case .preparing:
                            // starts dragging
                            draggingStage = .dragging
                            willStartLiveScroll(.init(
                                name: NSScrollView.willStartLiveScrollNotification,
                                object: scrollView
                            )
                            )

                            // emits dragging
                            didLiveScroll(.init(
                                name: NSScrollView.didLiveScrollNotification,
                                object: scrollView
                            )
                            )
                        case .dragging:
                            // emits dragging
                            didLiveScroll(.init(
                                name: NSScrollView.didLiveScrollNotification,
                                object: scrollView
                            )
                            )
                        }
                    default:
                        break
                    }

                    return event
                }
            }
        }

        // should be called whenever a scroll happens.
        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let relativeOffset = offset - center

            // handles wrapping case
            if parent.wrapping {
                lastOffset = offset
                lastPageOffset = 0

                // check if reaches next page
                if abs(relativeOffset) >= parent.spacing {
                    resetScrollViewPosition(scrollView.contentView)

                    let pageOffset: Int = if relativeOffset >= parent.spacing {
                        +1
                    } else if relativeOffset <= -parent.spacing {
                        -1
                    } else { 0 }

                    accumulatePage(pageOffset)
                }
            }

            // handles non-wrapping case
            else {
                let offset = max(0, min(2 * parent.spacing, offset))
                let relativeOffset = offset - offsetOrigin

                // arithmetic approach to achieve a undirectional paging effect
                let isIncremental = offset - lastOffset > 0
                let comparation: (Int, Int) -> Int = isIncremental ? max : min
                let pageOffset = comparation(
                    lastPageOffset,
                    Int((relativeOffset / parent.spacing).rounded(isIncremental ? .down : .up))
                )

                lastOffset = offset
                lastPageOffset = pageOffset

                overridePage(pageOffset)
            }

            updateBounds(scrollView.contentView)
        }

        // should be called whenever a scroll starts.
        @objc func willStartLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            offsetOrigin = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            pageOrigin = parent.page

            lastOffset = offsetOrigin

            updateBounds(scrollView.contentView)
        }

        // should be called whenever a scroll ends.
        @objc func didEndLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            // snaps if required
            if parent.snapping {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    self.snapScrollViewPosition(scrollView.contentView)
                }
            }

            updateBounds(scrollView.contentView)
        }

        private func updateBounds(_ clipView: NSClipView, animate: Bool = false) {
            parent.onBoundsChange(clipView.bounds, animate: animate)
        }

        // accumulates the page for wrapping
        private func accumulatePage(_ offset: Int) {
            parent.page += offset
            pageOrigin = parent.page
        }

        // overrides the page, not for wrapping
        private func overridePage(_ offset: Int) {
            parent.page = pageOrigin + offset
        }

        private func resetScrollViewPosition(_ clipView: NSClipView, offset: CGPoint = .zero, animate: Bool = false) {
            clipView.setBoundsOrigin(parent.centerRect.origin.applying(.init(translationX: offset.x, y: offset.y)))

            parent.shouldReset = false
            offsetOrigin = parent.direction.offset(of: clipView.bounds.origin)

            updateBounds(clipView, animate: animate)
        }

        // snaps to the nearest available page anchor
        private func snapScrollViewPosition(_ clipView: NSClipView) {
            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: clipView.bounds.origin)

            let relativeOffset = offset - center

            let snapsToNext = relativeOffset >= parent.spacing / 2
            let snapsToPrevious = relativeOffset <= -parent.spacing / 2
            let localOffset: CGFloat = if snapsToNext {
                parent.spacing
            } else if snapsToPrevious {
                -parent.spacing
            } else { 0 }

            // - paging logic

            // handles wrapping case
            if parent.wrapping {
                let pageOffset: Int = if snapsToNext {
                    +1
                } else if snapsToPrevious {
                    -1
                } else { 0 }

                accumulatePage(pageOffset)
            }

            // handles non-wrapping case
            else {
                // simply rounds the page toward zero to find the nearest page
                let relativeOffsetOrigin = offsetOrigin - center
                let relativeOffset = localOffset - relativeOffsetOrigin
                let pageOffset = Int((relativeOffset / parent.spacing).rounded(.towardZero))

                overridePage(pageOffset)
            }

            // - animation logic (required for correctly presenting directional snapping animations)

            // handles wrapping case
            if parent.wrapping {
                // overflow to corresponding edge in advance to correct the animation origin
                if localOffset != 0 {
                    resetScrollViewPosition(
                        clipView,
                        offset: parent.direction.point(from: relativeOffset - localOffset)
                    )
                }

                resetScrollViewPosition(clipView, animate: true)
            }

            // handles non-wrapping case
            else {
                resetScrollViewPosition(
                    clipView,
                    offset: parent.direction.point(from: localOffset),
                    animate: true
                )
            }
        }
    }
}

// MARK: - Preview

private struct InfiniteScrollPreview: View {
    var direction: InfiniteScrollViewDirection = .horizontal
    var size: CGSize = .init(width: 500, height: 100)

    @State private var offset: CGFloat = 0
    @State private var page: Int = 0
    @State private var shouldReset: Bool = true
    @State private var wrapping: Bool = true

    var body: some View {
        InfiniteScrollView(
            debug: true,
            direction: direction,

            size: .constant(size),
            spacing: .constant(50),
            snapping: .constant(true),
            wrapping: $wrapping,
            initialOffset: .constant(0),

            shouldReset: $shouldReset,
            offset: $offset,
            page: $page
        )
        .frame(width: size.width, height: size.height)
        .border(.red)

        HStack {
            Button("Reset Offset") {
                shouldReset = true
            }

            Button(wrapping ? "Disable Wrapping" : "Enable Wrapping") {
                wrapping.toggle()
            }
        }
        .frame(maxWidth: .infinity)

        HStack {
            Text(String(format: "Offset: %.1f", offset))

            Text("Page: \(page)")
                .foregroundStyle(.tint)
        }
        .monospaced()
        .frame(height: 12)
    }
}

#Preview {
    VStack {
        InfiniteScrollPreview()

        Divider()

        InfiniteScrollPreview(direction: .vertical, size: .init(width: 100, height: 500))
    }
    .padding()
    .contentTransition(.numericText())
}
