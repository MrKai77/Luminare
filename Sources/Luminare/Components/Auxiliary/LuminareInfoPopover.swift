//
//  LuminareInfoPopover.swift
//
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public struct LuminareInfoPopover<Content, Badge>: View
where Content: View, Badge: View {
    let delay: CGFloat
    let arrowEdge: Edge
    let highlight: Bool
    let cornerRadius: CGFloat
    let padding: CGFloat
    let shade: AnyShapeStyle
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let badge: () -> Badge
    
    @State private var isPopoverPresented: Bool = false
    @State private var isHovering: Bool = false
    @State private var hoverTimer: Timer?
    
    public init<S: ShapeStyle>(
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        highlight: Bool = true,
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        shade: S = .secondary,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder badge: @escaping () -> Badge
    ) {
        self.delay = delay
        self.arrowEdge = arrowEdge
        self.highlight = highlight
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shade = AnyShapeStyle(shade)
        self.content = content
        self.badge = badge
    }
    
    public init<S: ShapeStyle>(
        _ key: LocalizedStringKey,
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        highlight: Bool = true,
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        shade: S = .secondary,
        @ViewBuilder badge: @escaping () -> Badge
    ) where Content == Text {
        self.init(
            delay: delay, 
            arrowEdge: arrowEdge,
            highlight: highlight,
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
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        highlight: Bool = true,
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 4,
        badgeSize: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Badge == AnyView {
        self.init(
            delay: delay,
            arrowEdge: arrowEdge,
            highlight: highlight,
            cornerRadius: cornerRadius,
            padding: padding,
            shade: .tint,
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
                if highlight && isPopoverPresented {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(shade.opacity(0.1))
                        .blur(radius: padding)
                }
            }
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
                
                if isHovering {
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                        withAnimation(LuminareConstants.fastAnimation) {
                            isPopoverPresented = true
                        }
                        
                        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            withAnimation(LuminareConstants.fastAnimation) {
                                isPopoverPresented = isHovering
                            }
                            hoverTimer?.invalidate()
                            hoverTimer = nil
                        }
                    }
                } else if hoverTimer == nil || !isPopoverPresented {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    withAnimation(LuminareConstants.fastAnimation) {
                        isPopoverPresented = false
                    }
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
            LuminareInfoPopover {
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
    }
    .padding()
}
