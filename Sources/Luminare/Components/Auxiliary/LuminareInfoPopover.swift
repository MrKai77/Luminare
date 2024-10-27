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
    let padding: CGFloat
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let badge: () -> Badge
    
    @State private var isPopoverPresented: Bool = false
    @State private var isHovering: Bool = false
    @State private var hoverTimer: Timer?
    
    public init(
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        padding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder badge: @escaping () -> Badge
    ) {
        self.delay = delay
        self.arrowEdge = arrowEdge
        self.padding = padding
        self.content = content
        self.badge = badge
    }
    
    public init(
        _ key: LocalizedStringKey,
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        padding: CGFloat = 4,
        @ViewBuilder badge: @escaping () -> Badge
    ) where Content == Text {
        self.init(
            delay: delay, 
            arrowEdge: arrowEdge,
            padding: padding
        ) {
            Text(key)
        } badge: {
            badge()
        }
    }
    
    public init(
        delay: CGFloat = 0.5,
        arrowEdge: Edge = .bottom,
        padding: CGFloat = 4,
        badgeSize: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Badge == AnyView {
        self.init(
            delay: delay,
            arrowEdge: arrowEdge,
            padding: padding,
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
            .onHover { hovering in
                isHovering = hovering
                
                if isHovering {
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                        isPopoverPresented = true
                    }
                } else {
                    hoverTimer?.invalidate()
                    isPopoverPresented = false
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
                Text("Pops to bottom")
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
                Text("Pops to trailing")
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
