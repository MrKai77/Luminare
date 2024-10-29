//
//  LuminareInfoPopover.swift
//
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public struct LuminareInfoPopover<Content, Badge>: View
where Content: View, Badge: View {
    public enum Trigger {
        case onHover(delay: CGFloat = 0.5)
        case onLongPress
    }
    
    public enum Shade {
        case none
        case some(_ style: AnyShapeStyle)
        
        var style: AnyShapeStyle? {
            switch self {
            case .some(let style): style
            default: nil
            }
        }
        
        public static func styled<S: ShapeStyle>(_ style: S = .secondary) -> Self {
            .some(AnyShapeStyle(style))
        }
    }
    
    @Environment(\.luminareAnimationFast) private var animationFast
    
    private let arrowEdge: Edge
    private let trigger: Trigger
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let shade: Shade
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let badge: () -> Badge
    
    @State private var isPopoverPresented: Bool = false
    @State private var isHovering: Bool = false
    @State private var hoverTimer: Timer?
    
    public init(
        arrowEdge: Edge = .bottom,
        trigger: Trigger = .onHover(),
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        shade: Shade = .styled(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder badge: @escaping () -> Badge
    ) {
        self.arrowEdge = arrowEdge
        self.trigger = trigger
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shade = shade
        self.content = content
        self.badge = badge
    }
    
    public init(
        _ key: LocalizedStringKey,
        arrowEdge: Edge = .bottom,
        trigger: Trigger = .onHover(),
        highlight: Bool = true,
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        shade: Shade = .styled(),
        @ViewBuilder badge: @escaping () -> Badge
    ) where Content == Text {
        self.init(
            arrowEdge: arrowEdge,
            trigger: trigger,
            cornerRadius: cornerRadius,
            padding: padding,
            shade: shade
        ) {
            Text(key)
        } badge: {
            badge()
        }
    }
    
    public init(
        arrowEdge: Edge = .bottom,
        trigger: Trigger = .onHover(),
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        badgeSize: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Badge == AnyView {
        self.init(
            arrowEdge: arrowEdge,
            trigger: trigger,
            cornerRadius: cornerRadius,
            padding: padding,
            shade: .styled(.tint),
            content: content
        ) {
            AnyView(
                Circle()
                    .frame(width: badgeSize, height: badgeSize)
                    .foregroundStyle(.tint)
            )
        }
    }

    public var body: some View {
        badge()
            .padding(padding)
            .background {
                if let style = shade.style, isPopoverPresented {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(style.opacity(0.1))
                        .blur(radius: padding)
                }
            }
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
                
                switch trigger {
                case .onHover(let delay):
                    if isHovering {
                        hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                            withAnimation(animationFast) {
                                isPopoverPresented = true
                            }
                            
                            hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                withAnimation(animationFast) {
                                    isPopoverPresented = isHovering
                                }
                                hoverTimer?.invalidate()
                                hoverTimer = nil
                            }
                        }
                    } else if hoverTimer == nil || !isPopoverPresented {
                        hoverTimer?.invalidate()
                        hoverTimer = nil
                        withAnimation(animationFast) {
                            isPopoverPresented = false
                        }
                    }
                case .onLongPress:
                    return
                }
                
            }
            .popover(isPresented: $isPopoverPresented, arrowEdge: arrowEdge) {
                content()
                    .multilineTextAlignment(.center)
            }
            .padding(-padding)
    }
}

#Preview {
    LuminareSection {
        LuminareCompose {
        } label: {
            LuminareInfoPopover(shade: .none) {
                Text("Here's to the *crazy* ones.")
                    .padding()
            } badge: {
                Text("Pops to bottom (hover me)")
            }
        }
        
        LuminareCompose {
        } label: {
            LuminareInfoPopover(arrowEdge: .trailing) {
                VStack(alignment: .leading) {
                    Text("The **misfits.** The ~rebels.~")
                    Text("The [troublemakers](https://apple.com).")
                }
                .padding()
            } badge: {
                Text("Pops to trailing (hover me)")
            }
        }
        
        LuminareCompose {
        } label: {
            HStack {
                Text("Pops from a dot ↗")
                
                VStack {
                    LuminareInfoPopover(arrowEdge: .top) {
                        VStack(alignment: .leading) {
                            Text("The round pegs in the square holes.")
                            Text("The ones **who see things differently.**")
                        }
                        .padding()
                    }
                    .tint(.violet)
                    
                    Spacer()
                }
            }
        }
        
        LuminareCompose {
        } label: {
            LuminareInfoPopover(arrowEdge: .top, trigger: .onLongPress) {
                VStack(alignment: .leading) {
                    Text("The **misfits.** The ~rebels.~")
                    Text("The [troublemakers](https://apple.com).")
                }
                .padding()
            } badge: {
                Text("Pops to top (long press me)")
            }
        }
    }
    .padding()
}
