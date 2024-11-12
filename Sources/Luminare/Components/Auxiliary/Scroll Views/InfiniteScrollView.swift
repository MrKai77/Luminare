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
        print(wrapping)
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

        private var boundsObservation: NSKeyValueObservation?
        private var offsetOrigin: CGFloat = .zero
        private var diffOrigin: Int = .zero

        private var lastOffset: CGFloat = .zero
        private var lastDiffOffset: Int = .zero

        init(_ parent: InfiniteScrollView) {
            self.parent = parent
        }

        func initializeScroll(_ clipView: NSClipView) {
            if parent.shouldReset {
                resetScrollViewPosition(clipView, offset: parent.direction.point(from: parent.initialOffset))
                diffOrigin = parent.diff
            }
        }

        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }

            boundsObservation = scrollView.contentView.observe(\.bounds, options: [
                .new, .initial]) { [weak self] _, change in
                guard let self, let bounds = change.newValue else { return }
                    parent.onBoundsChange(bounds)
            }

            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let relativeOffset = offset - center

            if parent.wrapping {
                lastOffset = offset
                lastDiffOffset = 0

                if abs(relativeOffset) >= parent.spacing {
                    resetScrollViewPosition(scrollView.contentView)

                    let diffOffset: Int = if relativeOffset >= parent.spacing {
                        +1
                    } else if relativeOffset <= -parent.spacing {
                        -1
                    } else {
                        0
                    }

                    accumulateDiff(diffOffset)
                }
            } else {
                let offset = max(0, min(2 * parent.spacing, offset))
                let relativeOffset = offset - offsetOrigin

                let isIncremental = offset - lastOffset > 0
                let comparation: (Int, Int) -> Int = isIncremental ? max : min
                let diffOffset = comparation(
                    lastDiffOffset,
                    Int((relativeOffset / parent.spacing).rounded(isIncremental ? .down : .up))
                )

                lastOffset = offset
                lastDiffOffset = diffOffset

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

            if parent.snapping {
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
            parent.onBoundsChange(clipView.bounds, animate: animate)

            parent.shouldReset = false
            offsetOrigin = parent.direction.offset(of: clipView.bounds.origin)
        }

        private func snapScrollViewPosition(_ clipView: NSClipView) {
            let center = parent.direction.offset(of: parent.centerRect.origin)
            let offset = parent.direction.offset(of: clipView.bounds.origin)

            let relativeOffset = offset - center

            let localOffset: CGFloat = switch relativeOffset {
            case relativeOffset where relativeOffset >= -parent.spacing && relativeOffset < -parent.spacing / 2:
                -parent.spacing
            case relativeOffset where relativeOffset >= -parent.spacing / 2 && relativeOffset < parent.spacing / 2:
                    .zero
            case relativeOffset where relativeOffset >= parent.spacing / 2:
                +parent.spacing
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
    var direction: InfiniteScrollViewDirection = .horizontal
    var size: CGSize = .init(width: 500, height: 100)

    @State private var offset: CGFloat = 0
    @State private var diff: Int = 0
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
            diff: $diff
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

            Text("Diff: \(diff)")
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
