//
//  InfiniteScrollView.swift
//
//
//  Created by KrLite on 2024/11/2.
//

import SwiftUI
import AppKit

public enum InfiniteScrollViewDirection: Equatable {
    case horizontal
    case vertical

    public init(axis: Axis) {
        switch axis {
        case .horizontal:
            self = .horizontal
        case .vertical:
            self = .vertical
        }
    }

    public var axis: Axis {
        switch self {
        case .horizontal:
                .horizontal
        case .vertical:
                .vertical
        }
    }

    @ViewBuilder func stack(spacing: CGFloat, @ViewBuilder content: @escaping () -> some View) -> some View {
        switch self {
        case .horizontal:
            HStack(alignment: .center, spacing: spacing, content: content)
        case .vertical:
            VStack(alignment: .center, spacing: spacing, content: content)
        }
    }

    func length(of size: CGSize) -> CGFloat {
        switch self {
        case .horizontal:
            size.width
        case .vertical:
            size.height
        }
    }

    func offset(of point: CGPoint) -> CGFloat {
        switch self {
        case .horizontal:
            point.x
        case .vertical:
            point.y
        }
    }

    func point(from offset: CGFloat) -> CGPoint {
        switch self {
        case .horizontal:
                .init(x: offset, y: 0)
        case .vertical:
                .init(x: 0, y: offset)
        }
    }

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

public struct InfiniteScrollView: NSViewRepresentable {
    public typealias Direction = InfiniteScrollViewDirection

    @Environment(\.luminareAnimationFast) private var animationFast

    var debug: Bool = false
    public var direction: Direction

    @Binding public var size: CGSize
    @Binding public var spacing: CGFloat
    @Binding public var snapping: Bool
    @Binding public var wrapping: Bool
    @Binding public var initialOffset: CGFloat

    @Binding public var shouldReset: Bool
    @Binding public var offset: CGFloat
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

    @ViewBuilder private func centerView() -> some View {
        Color.clear
            .frame(width: size.width, height: size.height)
    }

    func onBoundsChange(
        _ bounds: CGRect,
        pageCompensation: Int? = nil,
        animate: Bool = false
    ) {
        let offset = direction.offset(of: bounds.origin) - direction.offset(of: centerRect.origin)
        let offsetCompensation: CGFloat = if let pageCompensation {
            -CGFloat(pageCompensation) * spacing
        } else { 0 }

        if animate {
            withAnimation(animationFast) {
                self.offset = offset + offsetCompensation
            }
        } else {
            self.offset = offset + offsetCompensation
        }
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false

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

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.didLiveScroll(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.willStartLiveScroll(_:)),
            name: NSScrollView.willStartLiveScrollNotification,
            object: scrollView
        )

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
            context.coordinator.initializeScroll(nsView.contentView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject {
        var parent: InfiniteScrollView

        private var offsetOrigin: CGFloat = .zero
        private var pageOrigin: Int = .zero
        private var pageCompensationOrigin: Int = .zero

        private var lastOffset: CGFloat = .zero
        private var lastPageOffset: Int = .zero

        init(_ parent: InfiniteScrollView) {
            self.parent = parent

            offsetOrigin = parent.offset
            pageOrigin = parent.page
            pageCompensationOrigin = parent.page
        }

        func initializeScroll(_ clipView: NSClipView) {
            if parent.shouldReset {
                resetScrollViewPosition(clipView, offset: parent.direction.point(from: parent.initialOffset))
                parent.offset = parent.initialOffset
                pageOrigin = parent.page

                lastOffset = 0
                lastPageOffset = 0
            }
        }

        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let relativeOffset = offset - center

            if parent.wrapping {
                if abs(relativeOffset) >= parent.spacing {
                    resetScrollViewPosition(scrollView.contentView)

                    let diffOffset: Int = if relativeOffset >= parent.spacing {
                        +1
                    } else if relativeOffset <= -parent.spacing {
                        -1
                    } else { 0 }

                    accumulatePage(diffOffset)
                }

                pageCompensationOrigin = parent.page
            } else {
                let offset = max(0, min(2 * parent.spacing, offset))
                let relativeOffset = offset - offsetOrigin

                let isIncremental = offset - lastOffset > 0
                let clamp: (Int, Int) -> Int = isIncremental ? max : min
                let pageOffset = clamp(
                    lastPageOffset,
                    Int((relativeOffset / parent.spacing).rounded(isIncremental ? .down : .up))
                )

                overridePage(pageOffset)
            }

            lastOffset = offset

            onBoundsChange(scrollView.contentView)
        }

        @objc func willStartLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            offsetOrigin = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            pageOrigin = parent.page

            lastOffset = offsetOrigin
        }

        @objc func didEndLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            if parent.snapping {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    self.snapScrollViewPosition(scrollView.contentView)
                }
            }
        }

        private func onBoundsChange(_ clipView: NSClipView, animate: Bool = false) {
            let bounds = clipView.bounds
            if parent.wrapping {
                parent.onBoundsChange(bounds, animate: animate)
            } else {
                parent.onBoundsChange(
                    bounds,
                    pageCompensation: parent.page - pageCompensationOrigin,
                    animate: animate
                )
            }
        }

        private func accumulatePage(_ offset: Int) {
            parent.page += offset
            pageOrigin = parent.page
            lastPageOffset = 0
        }

        private func overridePage(_ offset: Int) {
            parent.page = pageOrigin + offset
            lastPageOffset = offset
        }

        private func resetScrollViewPosition(_ clipView: NSClipView, offset: CGPoint = .zero, animate: Bool = false) {
            clipView.setBoundsOrigin(parent.centerRect.origin.applying(.init(translationX: offset.x, y: offset.y)))
            onBoundsChange(clipView, animate: animate)

            parent.shouldReset = false
            offsetOrigin = parent.direction.offset(of: clipView.bounds.origin)
        }

        private func snapScrollViewPosition(_ clipView: NSClipView) {
            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: clipView.bounds.origin)

            let relativeOffset = offset - center

            let snapsToPrevious = relativeOffset <= -parent.spacing / 2
            let snapsToNext = relativeOffset >= parent.spacing / 2

            let snapOffset: CGFloat = if snapsToPrevious {
                -parent.spacing
            } else if snapsToNext {
                parent.spacing
            } else { 0 }

            // update page
            if parent.wrapping {
                let pageOffset: Int = if snapsToNext {
                    +1
                } else if snapsToPrevious {
                    -1
                } else { 0 }

                accumulatePage(pageOffset)
            } else {
                let relativeOffsetOrigin = offsetOrigin - center
                let relativeOffset = snapOffset - relativeOffsetOrigin
                let pageOffset = Int((relativeOffset / parent.spacing).rounded(.towardZero))

                overridePage(pageOffset)
            }

            // update offset
            if parent.wrapping {
                if snapsToPrevious || snapsToNext {
                    resetScrollViewPosition(
                        clipView,
                        offset: parent.direction.point(from: relativeOffset - snapOffset)
                    )
                }

                resetScrollViewPosition(clipView, animate: true)
            } else {
                self.resetScrollViewPosition(
                    clipView,
                    offset: self.parent.direction.point(from: snapOffset),
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
