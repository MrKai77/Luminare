//
//  LuminarePopover.swift
//  Luminare
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public enum LuminarePopoverTrigger {
    case hover(
        showDelay: TimeInterval = 0.25,
        hideDelay: TimeInterval = 0.0
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

public enum LuminarePopoverShade {
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

// MARK: - Popover

public struct LuminarePopover<Content, Badge>: View where Content: View, Badge: View {
    public typealias Trigger = LuminarePopoverTrigger
    public typealias Shade = LuminarePopoverShade

    // MARK: Environments

    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminarePopoverTrigger) private var trigger
    @Environment(\.luminarePopoverShade) private var shade
    @Environment(\.luminareCornerRadii) private var cornerRadii

    // MARK: Fields

    private let attachmentAnchor: PopoverAttachmentAnchor
    private let arrowEdge: Edge?
    private let padding: CGFloat

    @ViewBuilder private var content: () -> Content, badge: () -> Badge

    @State private var isPopoverPresented: Bool = false

    @State private var isHovering: Bool = false
    @State private var hoverTimer: Timer?

    @State private var forceTouchGesture: ForceTouchGesture = .inactive
    @State private var forceTouchRecognized: Bool = false
    @State private var forceTouchProgress: CGFloat = 0

    // MARK: Initializers

    public init(
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder badge: @escaping () -> Badge
    ) {
        self.attachmentAnchor = attachmentAnchor
        self.arrowEdge = arrowEdge
        self.padding = padding
        self.content = content
        self.badge = badge
    }

    public init(
        _ key: LocalizedStringKey,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        @ViewBuilder badge: @escaping () -> Badge
    ) where Content == Text {
        self.init(
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            padding: padding
        ) {
            Text(key)
        } badge: {
            badge()
        }
    }

    public init(
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        badgeSize: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Badge == AnyView {
        self.init(
            attachmentAnchor: attachmentAnchor,
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

    public init(
        _ contentKey: LocalizedStringKey,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        badgeSize: CGFloat = 4
    ) where Content == AnyView, Badge == AnyView {
        self.init(
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            padding: padding
        ) {
            AnyView(
                Text(contentKey)
                    .multilineTextAlignment(.center)
                    .padding(8)
            )
        } badge: {
            AnyView(
                Circle()
                    .frame(width: badgeSize, height: badgeSize)
                    .foregroundStyle(.tint)
            )
        }
    }

    // MARK: Body

    public var body: some View {
        Group {
            switch trigger {
            case let .hover(showDelay, hideDelay):
                badge()
                    .padding(padding)
                    .onHover { isHovering in
                        self.isHovering = isHovering
                        handleHoverTrigger(isHovering: isHovering, showDelay: showDelay, hideDelay: hideDelay)
                    }
            case let .forceTouch(threshold, onGesture):
                ForceTouch(threshold: threshold, gesture: $forceTouchGesture) {
                    badge()
                }
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
                case let .hover(showDelay, hideDelay):
                    content()
                        .onHover { isHovering in
                            // Hovering on the content can also update popover state
                            self.isHovering = isHovering
                            handleHoverTrigger(isHovering: isHovering, showDelay: showDelay, hideDelay: hideDelay)
                        }
                case .forceTouch:
                    content()
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

    private func handleHoverTrigger(isHovering: Bool, showDelay: TimeInterval, hideDelay: TimeInterval) {
        if isHovering {
            if isPopoverPresented {
                // Prevents the popover to hide when the delay is not met
                hoverTimer?.invalidate()
                hoverTimer = nil
            } else {
                // Schedules to show
                hoverTimer = .scheduledTimer(withTimeInterval: showDelay, repeats: false) { _ in
                    isPopoverPresented = true
                    hoverTimer?.invalidate()

                    // In case the cursor immediately moved away
                    hoverTimer = .scheduledTimer(withTimeInterval: hideDelay, repeats: false) { _ in
                        // The use of `self.isHovering` is crucial here!
                        isPopoverPresented = self.isHovering
                        hoverTimer?.invalidate()
                        hoverTimer = nil
                    }
                }
            }
        } else {
            if !isPopoverPresented {
                // Prevents the popover to show when the delay is not met
                hoverTimer?.invalidate()
                hoverTimer = nil
            } else {
                // Schedules to hide
                hoverTimer = .scheduledTimer(withTimeInterval: hideDelay, repeats: false) { _ in
                    isPopoverPresented = false
                    hoverTimer?.invalidate()

                    // In case the cursor immediately moved back inside
                    hoverTimer = .scheduledTimer(withTimeInterval: showDelay, repeats: false) { _ in
                        // The use of `self.isHovering` is crucial here!
                        isPopoverPresented = self.isHovering
                        hoverTimer?.invalidate()
                        hoverTimer = nil
                    }
                }
            }
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
    var arrowEdge: Edge? = nil
    var padding: CGFloat = 4

    @ViewBuilder var content: (_ gesture: ForceTouchGesture, _ recognized: Bool) -> Content
    @ViewBuilder var badge: () -> Badge

    @State private var gesture: ForceTouchGesture = .inactive
    @State private var recognized: Bool = false

    var body: some View {
        LuminarePopover(
            arrowEdge: arrowEdge,
            padding: padding
        ) {
            content(gesture, recognized)
        } badge: {
            badge()
        }
        .luminarePopoverTrigger(.forceTouch { gesture, recognized in
            self.gesture = gesture
            self.recognized = recognized
        })
    }
}

#Preview {
    LuminareSection {
        LuminareCompose {} label: {
            LuminarePopover {
                Text("Here's to the *crazy* ones.")
                    .padding()
            } badge: {
                Text("Pops to top *on hover*")
            }
            .luminarePopoverShade(.none)
        }

        LuminareCompose {} label: {
            LuminarePopover(arrowEdge: .trailing) {
                VStack(alignment: .leading) {
                    Text("The **misfits.** The ~rebels.~")
                    Text("The [troublemakers](https://apple.com).")
                }
                .padding()
            } badge: {
                Text("Pops to trailing with highlight *on hover*")
            }
        }

        LuminareCompose {} label: {
            HStack {
                Text("Pops from a dot ↗")

                LuminarePopover(arrowEdge: .top) {
                    VStack(alignment: .leading) {
                        Text("The round pegs in the square holes.")
                        Text("The ones **who see things differently.**")
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity, alignment: .top)
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
