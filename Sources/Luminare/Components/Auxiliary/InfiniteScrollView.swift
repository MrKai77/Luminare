//
//  InfiniteScrollView.swift
//  Luminare
//
//  Created by KrLite on 2024/11/2.
//

import AppKit
import SwiftUI

/// The direction of an ``InfiniteScrollView``.
public enum InfiniteScrollViewDirection: String, Equatable, Hashable, Identifiable, CaseIterable, Codable, Sendable {
    /// The view can, and can only be scrolled horizontally.
    case horizontal
    /// The view can, and can only be scrolled vertically.
    case vertical

    public var id: Self { self }

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

    /// Stacks the given elements according to the direction
    @ViewBuilder func stack(spacing: CGFloat, @ViewBuilder content: @escaping () -> some View) -> some View {
        switch self {
        case .horizontal:
            HStack(alignment: .center, spacing: spacing, content: content)
        case .vertical:
            VStack(alignment: .center, spacing: spacing, content: content)
        }
    }

    /// Gets the length from the given 2D size according to the direction
    func length(of size: CGSize) -> CGFloat {
        switch self {
        case .horizontal:
            size.width
        case .vertical:
            size.height
        }
    }

    /// Gets the offset from the given 2D point according to the direction
    func offset(of point: CGPoint) -> CGFloat {
        switch self {
        case .horizontal:
            point.x
        case .vertical:
            point.y
        }
    }

    /// Forms a point from the given offset according to the direction
    func point(from offset: CGFloat) -> CGPoint {
        switch self {
        case .horizontal:
            .init(x: offset, y: 0)
        case .vertical:
            .init(x: 0, y: offset)
        }
    }

    /// Forms a size from the given length according to the direction
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

    let debug: Bool
    public let direction: Direction
    public let allowsDragging: Bool

    public let size: CGSize
    public let spacing: CGFloat
    public let snapping: Bool
    public let wrapping: Bool
    public let initialOffset: CGFloat

    @Binding public var shouldReset: Bool
    @Binding public var offset: CGFloat
    @Binding public var page: Int

    /// Initializes a ``InfiniteScrollView``.
    ///
    /// - Parameters:
    ///   - direction: the ``InfiniteScrollViewDirection`` that defines the scrolling direction.
    ///   - allowsDragging: whether mouse dragging is allowed as an alternative of scrolling.
    ///   Overscrolling is not allowed when dragging.
    ///   - size: the explicit size of the scroll view.
    ///   - spacing: the spacing between pages.
    ///   - snapping: whether snapping is enabled.
    ///   If snapping is enabled, the view will automatically snaps to the nearest available page anchor with animation.
    ///   Otherwise, scrolling can stop at arbitrary midpoints.
    ///   - wrapping: whether wrapping is enabled.
    ///   If wrapping is enabled, the view will always allow infinite scrolling by constantly resetting the scrolling position.
    ///   Otherwise, the view won't lock the scrollable region and allows overscrolling to happen.
    ///   - initialOffset: the initial offset of the scroll view.
    ///   This can be useful when arbitrary initialization points are required.
    ///   - shouldReset: whether the scroll view should be resetted.
    ///   This binding will be automatically set to `false` after a valid reset happens.
    ///   - offset: the offset from the nearest page.
    ///   This binding is get-only.
    ///   - page: the scrolled page count.
    ///   This binding is get-only.
    public init(
        direction: Direction = .horizontal,
        allowsDragging: Bool = true,
        size: CGSize,
        spacing: CGFloat,
        snapping: Bool = true,
        wrapping: Bool = true,
        initialOffset: CGFloat = .zero,
        shouldReset: Binding<Bool> = .constant(false),
        offset: Binding<CGFloat>,
        page: Binding<Int>
    ) {
        self.debug = false
        self.direction = direction
        self.allowsDragging = allowsDragging
        self.size = size
        self.spacing = spacing
        self.snapping = snapping
        self.wrapping = wrapping
        self.initialOffset = initialOffset
        self._shouldReset = shouldReset
        self._offset = offset
        self._page = page
    }

    #if DEBUG
        init(
            debug: Bool,
            direction: Direction = .horizontal,
            allowsDragging: Bool = true,
            size: CGSize,
            spacing: CGFloat,
            snapping: Bool = true,
            wrapping: Bool = true,
            initialOffset: CGFloat = .zero,
            shouldReset: Binding<Bool> = .constant(false),
            offset: Binding<CGFloat>,
            page: Binding<Int>
        ) {
            self.debug = debug
            self.direction = direction
            self.allowsDragging = allowsDragging
            self.size = size
            self.spacing = spacing
            self.snapping = snapping
            self.wrapping = wrapping
            self.initialOffset = initialOffset
            self._shouldReset = shouldReset
            self._offset = offset
            self._page = page
        }
    #endif

    var length: CGFloat {
        direction.length(of: size)
    }

    var scrollableLength: CGFloat {
        length + spacing * 2
    }

    var centerRect: CGRect {
        .init(origin: direction.point(from: (scrollableLength - length) / 2), size: size)
    }

    @ViewBuilder private func sideView() -> some View {
        let size = direction.size(from: spacing, fallback: direction.length(of: size))

        Group {
            if debug {
                Color.red
            } else {
                Color.clear
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func centerView() -> some View {
        Color.clear
            .frame(width: size.width, height: size.height)
    }

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

        // Allocate the scrollable area
        let documentView = NSHostingView(
            rootView: direction.stack(spacing: 0) {
                sideView()
                centerView()
                sideView()
            }
        )
        scrollView.documentView = documentView

        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false

        // Observe scrolls
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.didLiveScroll(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )

        // Observe when scrolling starts
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.willStartLiveScroll(_:)),
            name: NSScrollView.willStartLiveScrollNotification,
            object: scrollView
        )

        // Observe when scrolling ends
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.didEndLiveScroll(_:)),
            name: NSScrollView.didEndLiveScrollNotification,
            object: scrollView
        )

        return scrollView
    }

    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.parent = self
            context.coordinator.initializeScroll(nsView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    @MainActor
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

        private var draggingStage: DraggingStage = .invalid

        private let id: UUID = .init()

        init(_ parent: InfiniteScrollView) {
            self.parent = parent
        }

        func initializeScroll(_ scrollView: NSScrollView) {
            let clipView = scrollView.contentView

            // Reset if required
            if parent.shouldReset {
                resetScrollViewPosition(clipView, offset: parent.direction.point(from: parent.initialOffset))
                pageOrigin = parent.page
            }

            // Set dragging monitor if required
            if parent.allowsDragging {
                // Deduplicate
                EventMonitorManager.shared.addLocalMonitor(
                    for: id,
                    matching: [
                        .leftMouseDown, .leftMouseUp, .leftMouseDragged
                    ]
                ) { [weak self] event in
                    let location = clipView.convert(event.locationInWindow, from: nil)
                    guard let self else { return event }

                    // ensure the dragging *happens* inside the view and can *continue* anywhere else
                    let canIgnoreBounds = draggingStage == .dragging
                    guard canIgnoreBounds || clipView.bounds.contains(location) else { return event }

                    switch event.type {
                    case .leftMouseDown:
                        // Indicates dragging might start in the future
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
                            didEndLiveScroll(
                                .init(
                                    name: NSScrollView.didEndLiveScrollNotification,
                                    object: scrollView
                                )
                            )
                        }
                    case .leftMouseDragged:
                        // Always update view bounds first
                        clipView.setBoundsOrigin(clipView.bounds.origin.applying(
                            .init(translationX: -event.deltaX, y: -event.deltaY)
                        ))

                        switch draggingStage {
                        case .invalid:
                            break
                        case .preparing:
                            // Starts dragging
                            draggingStage = .dragging
                            willStartLiveScroll(.init(
                                name: NSScrollView.willStartLiveScrollNotification,
                                object: scrollView
                            ))

                            // Emits dragging
                            didLiveScroll(.init(
                                name: NSScrollView.didLiveScrollNotification,
                                object: scrollView
                            ))
                        case .dragging:
                            // Emits dragging
                            didLiveScroll(.init(
                                name: NSScrollView.didLiveScrollNotification,
                                object: scrollView
                            ))
                        }
                    default:
                        break
                    }

                    return event
                }
            }
        }

        /// Should be called whenever a scroll happens.
        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let relativeOffset = offset - center

            // Handles wrapping case
            if parent.wrapping {
                lastOffset = offset
                lastPageOffset = 0

                // Check if reaches next page
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

            // Handles non-wrapping case
            else {
                let offset = max(0, min(2 * parent.spacing, offset))
                let relativeOffset = offset - offsetOrigin

                // Arithmetic approach to achieve a undirectional paging effect
                let isIncremental = offset - lastOffset > 0
                let comparation: (Int, Int) -> Int = isIncremental ? { max($0, $1) } : { min($0, $1) }
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

        /// Should be called whenever a scroll starts.
        @objc func willStartLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            offsetOrigin = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            pageOrigin = parent.page

            lastOffset = offsetOrigin

            updateBounds(scrollView.contentView)
        }

        /// Should be called whenever a scroll ends.
        @objc func didEndLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            // Snaps if required
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

        /// Accumulates the page for wrapping
        private func accumulatePage(_ offset: Int) {
            parent.page += offset
            pageOrigin = parent.page
        }

        /// Overrides the page, not for wrapping
        private func overridePage(_ offset: Int) {
            parent.page = pageOrigin + offset
        }

        private func resetScrollViewPosition(_ clipView: NSClipView, offset: CGPoint = .zero, animate: Bool = false) {
            clipView.setBoundsOrigin(parent.centerRect.origin.applying(.init(translationX: offset.x, y: offset.y)))

            parent.shouldReset = false
            offsetOrigin = parent.direction.offset(of: clipView.bounds.origin)

            updateBounds(clipView, animate: animate)
        }

        /// Snaps to the nearest available page anchor
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

            // - Paging logic

            // Handles wrapping case
            if parent.wrapping {
                let pageOffset: Int = if snapsToNext {
                    +1
                } else if snapsToPrevious {
                    -1
                } else { 0 }

                accumulatePage(pageOffset)
            }

            // Handles non-wrapping case
            else {
                // Simply rounds the page toward zero to find the nearest page
                let relativeOffsetOrigin = offsetOrigin - center
                let relativeOffset = localOffset - relativeOffsetOrigin
                let pageOffset = Int((relativeOffset / parent.spacing).rounded(.towardZero))

                overridePage(pageOffset)
            }

            // - Animation logic (required for correctly presenting directional snapping animations)

            // Handles wrapping case
            if parent.wrapping {
                // Overflow to corresponding edge in advance to correct the animation origin
                if localOffset != 0 {
                    resetScrollViewPosition(
                        clipView,
                        offset: parent.direction.point(from: relativeOffset - localOffset)
                    )
                }

                resetScrollViewPosition(clipView, animate: true)
            }

            // Handles non-wrapping case
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

#if DEBUG

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

                size: size,
                spacing: 50,
                snapping: true,
                wrapping: wrapping,
                initialOffset: 0,

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
#endif
