//
//  LuminareSurfaceStyle.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-11.
//

import AppKit
import SwiftUI

public struct LuminareSurfaceShadowStyle: Sendable {
    public let lightColor: Color
    public let darkColor: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(
        lightColor: Color,
        darkColor: Color = .clear,
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) {
        self.lightColor = lightColor
        self.darkColor = darkColor
        self.radius = radius
        self.x = x
        self.y = y
    }

    func color(for colorScheme: ColorScheme) -> Color {
        colorScheme == .light ? lightColor : darkColor
    }
}

public struct LuminareSurfaceStyle: Sendable {
    public let fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
    public let darkFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
    public let borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
    public let shadowStyle: LuminareSurfaceShadowStyle?
    public let buttonFontWeight: Font.Weight?

    public init(
        fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        darkFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        shadowStyle: LuminareSurfaceShadowStyle? = nil,
        buttonFontWeight: Font.Weight? = nil
    ) {
        self.fillStyle = fillStyle
        self.darkFillStyle = darkFillStyle
        self.borderStyle = borderStyle
        self.shadowStyle = shadowStyle
        self.buttonFontWeight = buttonFontWeight
    }

    public static let plateau: Self = .init(
        fillStyle: .init(
            normal: AnyShapeStyle(.white.opacity(0.7)),
            hovering: AnyShapeStyle(.quinary),
            pressed: AnyShapeStyle(.quinary)
        ),
        darkFillStyle: .init(
            normal: AnyShapeStyle(.quinary),
            hovering: AnyShapeStyle(.quaternary),
            pressed: AnyShapeStyle(.quaternary)
        ),
        borderStyle: .default.erased,
        shadowStyle: .init(
            lightColor: .black.opacity(0.1),
            darkColor: .clear,
            radius: 0.5,
            y: 0.5
        ),
        buttonFontWeight: .medium
    )

    public static let flat: Self = .init(
        fillStyle: .default.erased,
        darkFillStyle: nil,
        borderStyle: .default.erased,
        shadowStyle: nil,
        buttonFontWeight: nil
    )

    public func withoutFill() -> Self {
        .init(
            fillStyle: nil,
            darkFillStyle: nil,
            borderStyle: borderStyle,
            shadowStyle: shadowStyle,
            buttonFontWeight: buttonFontWeight
        )
    }

    public func withoutBorder() -> Self {
        .init(
            fillStyle: fillStyle,
            darkFillStyle: darkFillStyle,
            borderStyle: nil,
            shadowStyle: shadowStyle,
            buttonFontWeight: buttonFontWeight
        )
    }

    public func withoutShadow() -> Self {
        .init(
            fillStyle: fillStyle,
            darkFillStyle: darkFillStyle,
            borderStyle: borderStyle,
            shadowStyle: nil,
            buttonFontWeight: buttonFontWeight
        )
    }
}

private extension LuminareFillStyle {
    var erased: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle> {
        .init(
            normal: AnyShapeStyle(normal),
            hovering: AnyShapeStyle(hovering),
            pressed: AnyShapeStyle(pressed)
        )
    }
}

private extension LuminareBorderStyle {
    var erased: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle> {
        .init(
            normal: AnyShapeStyle(normal),
            hovering: AnyShapeStyle(hovering),
            pressed: AnyShapeStyle(pressed)
        )
    }
}
