//
//  InfiniteScrollView.swift
//
//
//  Created by KrLite on 2024/11/2.
//

import SwiftUI
import AppKit

public enum InfiniteScrollDirection: Equatable {
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
    public typealias Direction = InfiniteScrollDirection

    @Environment(\.luminareAnimationFast) private var animationFast

    public var direction: Direction
    public var size: CGSize
    public var spacing: CGFloat
    public var snapping: Bool

    var debug: Bool = false

    @Binding public var shouldReset: Bool
    @Binding public var wrapping: Bool
    @Binding public var initialOffset: CGFloat
    @Binding public var offset: CGFloat
    @Binding public var diff: Int

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

    func onOffsetChange(_ bounds: CGRect, animate: Bool = false) {
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
        Coordinator(self, spacing: spacing, snapping: snapping)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject {
        var parent: InfiniteScrollView
        var spacing: CGFloat
        var snapping: Bool

        private var offsetObservation: NSKeyValueObservation?
        private var offsetOrigin: CGFloat = .zero
        private var diffOrigin: Int = .zero

        private var lastOffset: CGFloat = .zero

        init(_ parent: InfiniteScrollView, spacing: CGFloat, snapping: Bool) {
            self.parent = parent
            self.spacing = spacing
            self.snapping = snapping
        }

        func initializeScroll(_ clipView: NSClipView) {
            if parent.shouldReset {
                resetScrollViewPosition(clipView, offset: parent.direction.point(from: parent.initialOffset))
                diffOrigin = parent.diff
            }
        }

        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            offsetObservation = scrollView.contentView.observe(\.bounds, options: [
                .new, .initial]) { [weak self] _, change in
                guard let self, let bounds = change.newValue else { return }
                parent.onOffsetChange(bounds)
            }

            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let relativeOffset = offset - center

            if parent.wrapping {
                if abs(relativeOffset) >= spacing {
                    resetScrollViewPosition(scrollView.contentView)
                    print(1)

                    let diffOffset: Int = if relativeOffset >= spacing {
                        +1
                    } else if relativeOffset <= -spacing {
                        -1
                    } else {
                        0
                    }

                    accumulateDiff(diffOffset)
                }
            } else {
                let offset = max(0, min(2 * spacing, offset))
                let relativeOffset = offset - offsetOrigin
                let diffOffset = Int((relativeOffset / parent.spacing).rounded(offset - lastOffset > 0 ? .down : .up))
                lastOffset = offset

                overrideDiff(diffOffset)
            }
        }

        @objc func willStartLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            offsetOrigin = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            diffOrigin = parent.diff

            lastOffset = offsetOrigin
        }

        @objc func didEndLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            if snapping {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    self.snapScrollViewPosition(scrollView.contentView)
                }
            }
        }

        private func accumulateDiff(_ offset: Int) {
            parent.diff += offset
            diffOrigin = parent.diff
        }

        private func overrideDiff(_ offset: Int) {
            parent.diff = diffOrigin + offset
        }

        private func resetScrollViewPosition(_ clipView: NSClipView, offset: CGPoint = .zero, animate: Bool = false) {
            clipView.setBoundsOrigin(parent.centerRect.origin.applying(.init(translationX: offset.x, y: offset.y)))
            parent.onOffsetChange(clipView.bounds, animate: animate)

            parent.shouldReset = false
            offsetOrigin = parent.direction.offset(of: clipView.bounds.origin)
        }

        private func snapScrollViewPosition(_ clipView: NSClipView) {
            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: clipView.bounds.origin)

            let relativeOffset = offset - center

            let localOffset: CGFloat = switch relativeOffset {
            case relativeOffset where relativeOffset >= -spacing && relativeOffset < -spacing / 2:
                -spacing
            case relativeOffset where relativeOffset >= -spacing / 2 && relativeOffset < spacing / 2:
                    .zero
            case relativeOffset where relativeOffset >= spacing / 2:
                +spacing
            default:
                    .zero
            }

            if parent.wrapping {
                let diffOffset: Int = if localOffset > 0 {
                    +1
                } else if localOffset < 0 {
                    -1
                } else {
                    0
                }

                accumulateDiff(diffOffset)
            } else {
                let relativeOffsetOrigin = offsetOrigin - center
                let relativeOffset = localOffset - relativeOffsetOrigin
                let diffOffset = Int((relativeOffset / parent.spacing).rounded(.towardZero))

                overrideDiff(diffOffset)
            }

            if parent.wrapping {
                if localOffset != 0 {
                    resetScrollViewPosition(
                        clipView,
                        offset: parent.direction.point(from: relativeOffset - localOffset)
                    )
                }

                resetScrollViewPosition(clipView, animate: true)
            } else {
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
    var direction: InfiniteScrollDirection = .horizontal
    var size: CGSize = .init(width: 500, height: 100)

    @State private var offset: CGFloat = 0
    @State private var diff: Int = 0
    @State private var shouldReset: Bool = true

    var body: some View {
        InfiniteScrollView(
            direction: direction,
            size: size,
            spacing: 50,
            snapping: true,
            debug: true,
            shouldReset: $shouldReset,
            wrapping: .constant(false),
            initialOffset: .constant(0),
            offset: $offset,
            diff: $diff
        )
        .frame(width: size.width, height: size.height)

        Button("Reset") {
            shouldReset = true
        }
        .frame(maxWidth: .infinity)

        Text(String(format: "%.1f", offset))
            .frame(height: 12)

        Text("\(diff)")
            .frame(height: 12)
    }
}

#Preview {
    VStack {
        InfiniteScrollPreview()
            .border(.red)

        Divider()

        InfiniteScrollPreview(direction: .vertical, size: .init(width: 100, height: 500))
            .border(.red)
    }
    .padding()
    .contentTransition(.numericText())
}
