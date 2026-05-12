//
//  LuminareSurfaceStyle.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-11.
//

import AppKit
import SwiftUI

public struct LuminareSurfaceShadowStyle: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(
        color: Color,
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public struct LuminareSurfaceStyle: Sendable {
    public struct Style: Sendable {
        public let fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
        public let borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
        public let shadowStyle: LuminareSurfaceShadowStyle?

        public init(
            fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
            borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
            shadowStyle: LuminareSurfaceShadowStyle? = nil
        ) {
            self.fillStyle = fillStyle
            self.borderStyle = borderStyle
            self.shadowStyle = shadowStyle
        }
    }

    public struct ButtonStyle: Sendable {
        public let fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
        public let borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
        public let shadowStyle: LuminareSurfaceShadowStyle?
        public let fontWeight: Font.Weight

        public init(
            fillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
            borderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
            shadowStyle: LuminareSurfaceShadowStyle? = nil,
            fontWeight: Font.Weight = .regular
        ) {
            self.fillStyle = fillStyle
            self.borderStyle = borderStyle
            self.shadowStyle = shadowStyle
            self.fontWeight = fontWeight
        }
    }

    public let lightStyle: Style
    public let darkStyle: Style
    public let buttonLightStyle: ButtonStyle?
    public let buttonDarkStyle: ButtonStyle?

    public init(
        lightStyle: Style,
        darkStyle: Style,
        buttonLightStyle: ButtonStyle? = nil,
        buttonDarkStyle: ButtonStyle? = nil
    ) {
        self.lightStyle = lightStyle
        self.darkStyle = darkStyle
        self.buttonLightStyle = buttonLightStyle
        self.buttonDarkStyle = buttonDarkStyle
    }

    public static let plateau: Self = .init(
        lightStyle: .init(
            fillStyle: .init(
                normal: AnyShapeStyle(.white.opacity(0.7)),
                hovering: AnyShapeStyle(.quinary),
                pressed: AnyShapeStyle(.quinary)
            ),
            borderStyle: .default.erased,
            shadowStyle: .init(
                color: .black.opacity(0.1),
                radius: 0.5,
                y: 0.5
            )
        ),
        darkStyle: .init(
            fillStyle: .init(
                normal: AnyShapeStyle(.quinary),
                hovering: AnyShapeStyle(.quaternary),
                pressed: AnyShapeStyle(.quaternary)
            ),
            borderStyle: .default.erased,
            shadowStyle: nil
        ),
        buttonLightStyle: .init(
            fillStyle: .init(
                normal: AnyShapeStyle(.white.opacity(0.7)),
                hovering: AnyShapeStyle(.quinary),
                pressed: AnyShapeStyle(.quinary)
            ),
            borderStyle: .default.erased,
            shadowStyle: .init(
                color: .black.opacity(0.1),
                radius: 0.5,
                y: 0.5
            ),
            fontWeight: .medium
        ),
        buttonDarkStyle: .init(
            fillStyle: .init(
                normal: AnyShapeStyle(.quinary),
                hovering: AnyShapeStyle(.quaternary),
                pressed: AnyShapeStyle(.quaternary)
            ),
            borderStyle: .init(
                normal: AnyShapeStyle(.quinary),
                hovering: AnyShapeStyle(.quinary),
                pressed: AnyShapeStyle(.quinary)
            ),
            shadowStyle: nil,
            fontWeight: .medium
        )
    )

    public static let flat: Self = .init(
        lightStyle: .init(
            fillStyle: .default.erased,
            borderStyle: .default.erased,
            shadowStyle: nil
        ),
        darkStyle: .init(
            fillStyle: .default.erased,
            borderStyle: .default.erased,
            shadowStyle: nil
        )
    )
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
