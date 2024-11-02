//
//  SwiftUIView.swift
//  
//
//  Created by KrLite on 2024/11/2.
//

import SwiftUI
import AppKit

public enum InfiniteScrollDirection {
    case horizontal
    case vertical
    
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
}

public struct InfiniteScrollView: NSViewRepresentable {
    public typealias Direction = InfiniteScrollDirection
    
    @Environment(\.luminareAnimation) private var animation
    
    public var direction: Direction
    public var size: CGSize
    public var spacing: CGFloat
    public var snapping: Bool
    @Binding public var offset: CGFloat
    
    var length: CGFloat {
        direction.length(of: size)
    }
    
    var scrollableLength: CGFloat {
        length * 3
    }
    
    var centerRect: CGRect {
        .init(origin: direction.point(from: (scrollableLength - length) / 2), size: size)
    }
    
    func onOffsetChange(_ bounds: CGRect, animate: Bool = false) {
        let offset = direction.offset(of: bounds.origin) - direction.offset(of: centerRect.origin)
        if animate {
            withAnimation(animation) {
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
//                Color.red
                Color.clear
                    .frame(width: size.width, height: size.height)
                
//                Color.white
                Color.clear
                    .frame(width: size.width, height: size.height)
                
//                Color.red
                Color.clear
                    .frame(width: size.width, height: size.height)
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
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self, spacing: spacing, snapping: snapping)
    }
    
    public class Coordinator: NSObject {
        var parent: InfiniteScrollView
        var spacing: CGFloat
        var snapping: Bool
        
        private var offsetObservation: NSKeyValueObservation?
        
        init(_ parent: InfiniteScrollView, spacing: CGFloat, snapping: Bool) {
            self.parent = parent
            self.spacing = spacing
            self.snapping = snapping
        }
        
        @objc func didLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }
            
            offsetObservation = scrollView.contentView.observe(\.bounds, options: [.new, .initial]) { [weak self] view, change in
                guard let self, let bounds = change.newValue else { return }
                parent.onOffsetChange(bounds)
            }
            
            let offset = parent.direction.offset(of: scrollView.contentView.bounds.origin)
            let center = parent.direction.offset(of: parent.centerRect.origin)
            if abs(center - offset) >= spacing {
                resetScrollViewPosition(scrollView.contentView)
            }
        }
        
        @objc func willStartLiveScroll(_ notification: Notification) {
            guard let _ = notification.object as? NSScrollView else { return }
        }
        
        @objc func didEndLiveScroll(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }
            
            if snapping {
                NSAnimationContext.runAnimationGroup { context in
                    context.allowsImplicitAnimation = true
                    self.snapScrollViewPosition(scrollView.contentView)
                } completionHandler: {
                    self.resetScrollViewPosition(scrollView.contentView)
                }
            }
        }
        
        private func resetScrollViewPosition(_ clipView: NSClipView, offset: CGPoint = .zero, animate: Bool = false) {
            clipView.setBoundsOrigin(parent.centerRect.origin.applying(.init(translationX: offset.x, y: offset.y)))
            parent.onOffsetChange(clipView.bounds, animate: animate)
        }
        
        private func snapScrollViewPosition(_ clipView: NSClipView) {
            let center = parent.centerRect.origin.y
            let diff = center - clipView.bounds.origin.y
            let offset: CGFloat = switch diff {
            case diff where diff >= -spacing && diff < -spacing / 2:
                -spacing
            case diff where diff >= -spacing / 2 && diff < spacing / 2:
                    .zero
            case diff where diff >= spacing / 2:
                spacing
            default:
                    .zero
            }
            resetScrollViewPosition(clipView, offset: parent.direction.point(from: -offset), animate: true)
        }
    }
}

private struct InfiniteScrollPreview: View {
    @State private var offset: CGFloat = 0
    var direction: InfiniteScrollDirection = .horizontal
    var size: CGSize = .init(width: 500, height: 100)
    
    var body: some View {
        InfiniteScrollView(direction: direction, size: size, spacing: 50, snapping: true, offset: $offset)
            .frame(width: size.width, height: size.height)
        
        Text(String(format: "%.1f", offset))
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
}
