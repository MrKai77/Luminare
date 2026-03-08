//
//  LuminareToolTipModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public enum LuminareToolTipTrigger {
    case hover(
        showDelay: TimeInterval = 0.5,
        hideDelay: TimeInterval = 0.5,
        throttleDelay: TimeInterval = 0.5
    )
    case forceTouch(
        threshold: CGFloat = 0.5,
        onGesture: ((_ gesture: ForceTouchGesture, _ recognized: Bool) -> ())? = nil
    )

    public static var hover: Self {
        .hover()
    }

    public static var forceTouch: Self {
        .forceTouch()
    }
}

public enum LuminareToolTipShade {
    case none
    case styled(_ style: AnyShapeStyle)

    public static var styled: Self {
        .styled()
    }

    var style: AnyShapeStyle? {
        switch self {
        case let .styled(style): style
        default: nil
        }
    }

    public static func styled(_ style: some ShapeStyle = .secondary) -> Self {
        .styled(.init(style))
    }
}

// MARK: - Tool Tip

public struct LuminareToolTipModifier<ToolTipContent>: ViewModifier where ToolTipContent: View {
    public typealias Trigger = LuminareToolTipTrigger
    public typealias Shade = LuminareToolTipShade

    // MARK: Environments

    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareToolTipTrigger) private var trigger
    @Environment(\.luminareToolTipShade) private var shade
    @Environment(\.luminareCornerRadii) private var cornerRadii

    // MARK: Fields

    private let attachmentAnchor: PopoverAttachmentAnchor
    private let arrowEdge: Edge?
    private let padding: CGFloat

    @ViewBuilder private var toolTipContent: () -> ToolTipContent

    @State private var isPopoverPresented: Bool = false
    @State private var isHovering: Bool = false

    @State private var forceTouchGesture: ForceTouchGesture = .inactive
    @State private var forceTouchRecognized: Bool = false
    @State private var forceTouchProgress: CGFloat = 0

    // MARK: Initializers

    public init(
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        @ViewBuilder toolTipContent: @escaping () -> ToolTipContent
    ) {
        self.attachmentAnchor = attachmentAnchor
        self.arrowEdge = arrowEdge
        self.padding = padding
        self.toolTipContent = toolTipContent
    }

    // MARK: Body

    public func body(content: Content) -> some View {
        Group {
            switch trigger {
            case let .hover(showDelay, hideDelay, throttleDelay):
                content
                    .padding(padding)
                    .onHover { isHovering = $0 }
                    .booleanThrottleDebounced(
                        isHovering,
                        flipOnDelay: showDelay,
                        flipOffDelay: hideDelay,
                        throttleDelay: throttleDelay
                    ) { debouncedValue in
                        isPopoverPresented = debouncedValue
                    }
            case let .forceTouch(threshold, onGesture):
                content
                    .modifier(ForceTouchModifier(threshold: threshold, gesture: $forceTouchGesture))
                    .padding(padding)
                    .onChange(of: forceTouchGesture) { gesture in
                        handleForceTouchTrigger(gesture: gesture)
                        onGesture?(gesture, forceTouchRecognized)
                    }
            }
        }
        .background {
            if let style = shade.style, isPopoverPresented {
                Group {
                    switch trigger {
                    case .hover:
                        UnevenRoundedRectangle(cornerRadii: cornerRadii)
                    case .forceTouch:
                        UnevenRoundedRectangle(cornerRadii: cornerRadii)
                            .opacity(normalizedForceTouchProgress)
                    }
                }
                .foregroundStyle(style.opacity(0.1))
                .blur(radius: padding)
            }
        }
        .popover(
            isPresented: $isPopoverPresented,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge
        ) {
            Group {
                switch trigger {
                case let .hover(showDelay, hideDelay, throttleDelay):
                    toolTipContent()
                        .onHover { isHovering = $0 }
                        .booleanThrottleDebounced(
                            isHovering,
                            flipOnDelay: showDelay,
                            flipOffDelay: hideDelay,
                            throttleDelay: throttleDelay
                        ) { debouncedValue in
                            isPopoverPresented = debouncedValue
                        }
                case .forceTouch:
                    toolTipContent()
                        .opacity(normalizedForceTouchProgress)
                        .scaleEffect(forceTouchRecognized ? 1.1 : 1, anchor: .center)
                        .animation(.bouncy, value: forceTouchRecognized)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(-padding)
        .animation(animationFast, value: isPopoverPresented)
    }

    private var normalizedForceTouchProgress: CGFloat {
        switch trigger {
        case let .forceTouch(threshold, _):
            let progress = (forceTouchProgress - threshold) / (1 - threshold)
            return max(0, progress)
        default:
            return 0
        }
    }

    private func handleForceTouchTrigger(gesture: ForceTouchGesture) {
        switch gesture {
        case .inactive:
            let recognized = forceTouchRecognized

            forceTouchRecognized = false
            isPopoverPresented = recognized
        case let .active(event):
            let stage = event.stage
            isPopoverPresented = true

            if stage == 1 {
                if !forceTouchRecognized {
                    forceTouchProgress = event.pressure
                }
            }

            if stage == 2 {
                forceTouchRecognized = true
                forceTouchProgress = 1
            }
        }
    }
}

// MARK: - Preview

private struct PopoverForceTouchPreview<Content, Badge>: View where Content: View, Badge: View {
    var arrowEdge: Edge?
    var padding: CGFloat = 4

    @ViewBuilder var content: (_ gesture: ForceTouchGesture, _ recognized: Bool) -> Content
    @ViewBuilder var badge: () -> Badge

    @State private var gesture: ForceTouchGesture = .inactive
    @State private var recognized: Bool = false

    var body: some View {
        badge()
            .luminareToolTip(
                arrowEdge: arrowEdge,
                padding: padding
            ) {
                content(gesture, recognized)
            }
            .luminareToolTipTrigger(.forceTouch { gesture, recognized in
                self.gesture = gesture
                self.recognized = recognized
            })
    }
}

#Preview {
    LuminareSection {
        LuminareCompose {} label: {
            Text("Pops to top *on hover*")
                .luminareToolTip {
                    Text("Here's to the *crazy* ones.")
                        .padding()
                }
                .luminareToolTipShade(.none)
        }

        LuminareCompose {} label: {
            Text("Pops to trailing with highlight *on hover*")
                .luminareToolTip {
                    VStack(alignment: .leading) {
                        Text("The **misfits.** The ~rebels.~")
                        Text("The [troublemakers](https://apple.com).")
                    }
                    .padding()
                }
        }

        LuminareCompose {} label: {
            Text("Pops from a dot ↗")
                .luminareToolTip(attachedTo: .topTrailing, arrowEdge: .top) {
                    VStack(alignment: .leading) {
                        Text("The round pegs in the square holes.")
                        Text("The ones **who see things differently.**")
                    }
                    .padding()
                }
        }

        LuminareCompose {} label: {
            PopoverForceTouchPreview(arrowEdge: .bottom) { gesture, recognized in
                Group {
                    switch gesture {
                    case let .active(event) where event.stage == 1 && !recognized:
                        ProgressView(value: event.pressure)
                    default:
                        Text("**Think different.**")
                    }
                }
                .frame(width: 200)
                .padding()
            } badge: {
                Text("Pops to bottom *on force touch*")
            }
        }
    }
    .padding()
}
