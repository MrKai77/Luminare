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
        case onForceTouch(
            threshold: CGFloat = 0.5,
            onPressureChange: (CGFloat) -> () = { _ in }
        )
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
    
    @State private var forceTouchState: ForceTouchView.GestureState = .ended
    @State private var forceTouchPressure: CGFloat = 0
    @State private var forceTouchRecognized: Bool = false
    
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
        Group {
            switch trigger {
            case .onHover(_):
                badge()
            case .onForceTouch(let threshold, let onPressureChange):
                ForceTouchView(threshold: threshold, state: $forceTouchState) {
                    badge()
                } onPressureChange: { event in
                    let stage = event.stage
                    
                    if stage == 1 {
                        if !forceTouchRecognized {
                            forceTouchPressure = CGFloat(event.pressure)
                        }
                    }
                    
                    if stage == 2 {
                        forceTouchRecognized = true
                        forceTouchPressure = 1
                    }
                }
                .onChange(of: forceTouchState) { state in
                    switch state {
                    case .began:
                        isPopoverPresented = true
                    case .ended:
                        let recognized = forceTouchRecognized
                        forceTouchRecognized = false
                        isPopoverPresented = recognized
                    default:
                        break
                    }
                }
                .onChange(of: forceTouchPressure) { pressure in
                    onPressureChange(pressure)
                }
            }
        }
        .padding(padding)
        .background {
            if let style = shade.style, isPopoverPresented {
                Group {
                    switch trigger {
                    case .onHover:
                        RoundedRectangle(cornerRadius: cornerRadius)
                    case .onForceTouch:
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .opacity(forceTouchPressure)
                    }
                }
                .foregroundStyle(style.opacity(0.1))
                .blur(radius: padding)
            }
        }
        .onHover { hover in
            isHovering = hover
            
            switch trigger {
            case .onHover(let delay):
                if isHovering {
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                        isPopoverPresented = true
                        
                        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            isPopoverPresented = isHovering
                            hoverTimer?.invalidate()
                            hoverTimer = nil
                        }
                    }
                } else if hoverTimer == nil || !isPopoverPresented {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    isPopoverPresented = false
                }
            default:
                break
            }
            
        }
        .popover(isPresented: $isPopoverPresented, arrowEdge: arrowEdge) {
            Group {
                switch trigger {
                case .onHover:
                    content()
                case .onForceTouch:
                    content()
                        .opacity(0.5 + forceTouchPressure * 0.5)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(-padding)
        .animation(animationFast, value: isPopoverPresented)
    }
}

struct InfoPopoverForceTouchPreview<Content, Badge>: View where Content: View, Badge: View {
    var arrowEdge: Edge = .bottom
    var cornerRadius: CGFloat = 8
    var padding: CGFloat = 4
    var shade: LuminareInfoPopover<Content, Badge>.Shade = .styled()
    
    @ViewBuilder var content: (CGFloat) -> Content
    @ViewBuilder var badge: () -> Badge
    
    @State private var pressure: CGFloat = 0

    var body: some View {
        LuminareInfoPopover(
            arrowEdge: arrowEdge,
            trigger: .onForceTouch { pressure in
                self.pressure = pressure
            },
            cornerRadius: cornerRadius,
            padding: padding,
            shade: shade
        ) {
            content(pressure)
        } badge: {
            badge()
        }
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
                Text("Pops to trailing with highlight (hover me)")
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
            InfoPopoverForceTouchPreview(arrowEdge: .top) { pressure in
                VStack(alignment: .leading) {
                    Text("**Think different.**")
                    
                    ProgressView(value: pressure)
                }
                .padding()
            } badge: {
                Text("Pops to top (force touch me)")
            }
        }
    }
    .padding()
}
