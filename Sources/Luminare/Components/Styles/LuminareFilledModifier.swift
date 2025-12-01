//
//  LuminareFilledModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareFilledStates: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let normal: Self = .init(rawValue: 1 << 0)
    public static let hovering: Self = .init(rawValue: 1 << 1)
    public static let pressed: Self = .init(rawValue: 1 << 2)

    public static let all: Self = [.normal, .hovering, .pressed]
    public static let none: Self = []
}

public struct LuminareFilledStyle<F: ShapeStyle, H: ShapeStyle, P: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H
    public let pressed: P

    public init(
        normal: F,
        hovering: H = Color.clear,
        pressed: P = Color.clear
    ) {
        self.normal = normal
        self.hovering = hovering
        self.pressed = pressed
    }

    public static var `default`: LuminareFilledStyle<HierarchicalShapeStyle, HierarchicalShapeStyle, HierarchicalShapeStyle> {
        .init(
            normal: .quinary,
            hovering: .quaternary,
            pressed: .tertiary
        )
    }
}

public struct LuminareFilledModifier<F, H, P>: ViewModifier where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle {
    private let isHovering: Bool, isPressed: Bool
    private let style: LuminareFilledStyle<F, H, P>

    public init(
        isHovering: Bool = false,
        isPressed: Bool = false,
        style: LuminareFilledStyle<F, H, P> = .default
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .background {
                LuminareFill(
                    isHovering: isHovering,
                    isPressed: isPressed,
                    style: style
                )
            }
    }
}

public struct LuminareFill<F, H, P>: View where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareFilledStates) private var luminareFilledStates
    
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsInsideSection) private var isInsideSection
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded
    @State private var disableInnerPadding: Bool? = nil

    private let isHovering: Bool, isPressed: Bool
    private let style: LuminareFilledStyle<F, H, P>

    public init(
        isHovering: Bool = false,
        isPressed: Bool = false,
        style: LuminareFilledStyle<F, H, P> = .default
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.style = style
    }

    public var body: some View {
        Group {
            let shape = getShape()
            
            if isEnabled {
                if luminareFilledStates.contains(.pressed), isPressed {
                    shape
                        .foregroundStyle(style.pressed)
                } else if luminareFilledStates.contains(.hovering), isHovering {
                    shape
                        .foregroundStyle(style.hovering)
                } else if luminareFilledStates.contains(.normal) {
                    shape
                        .foregroundStyle(style.normal)
                }
            } else {
                if luminareFilledStates.contains(.normal) {
                    shape
                        .foregroundStyle(style.normal)
                        .opacity(isEnabled ? 1 : 0.5)
                }
            }
        }
        .readPreference(LuminareSectionStackDisableInnerPaddingKey.self, to: $disableInnerPadding)
    }
    
    func getShape() -> UnevenRoundedRectangle {
        if isInsideSection {
            let disableInnerPadding = disableInnerPadding == true
            let cornerRadii = disableInnerPadding ? cornerRadii : cornerRadii.inset(by: 4)
            let defaultCornerRadius: CGFloat = 4
            return UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRounded ? cornerRadii.topLeading : defaultCornerRadius,
                bottomLeadingRadius: bottomLeadingRounded ? cornerRadii.bottomLeading : defaultCornerRadius,
                bottomTrailingRadius: bottomTrailingRounded ? cornerRadii.bottomTrailing : defaultCornerRadius,
                topTrailingRadius: topTrailingRounded ? cornerRadii.topTrailing : defaultCornerRadius,
            )
        } else {
            return UnevenRoundedRectangle(cornerRadii: cornerRadii)
        }
    }
}
