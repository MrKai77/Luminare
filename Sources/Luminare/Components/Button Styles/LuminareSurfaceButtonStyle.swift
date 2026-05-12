//
//  LuminareSurfaceButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style with a plateau appearance.
public struct LuminareSurfaceButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareSurfaceStyle) private var surfaceStyle
    @State private var isHovering: Bool = false

    private let tinted: Bool
    private let overrideUseMainStyle: Bool
    private let overrideIsHovering: Bool
    private let overrideIsPressed: Bool

    public init(
        tinted: Bool = false,
        overrideUseMainStyle: Bool = false,
        overrideIsHovering: Bool = false,
        overrideIsPressed: Bool = false
    ) {
        self.tinted = tinted
        self.overrideUseMainStyle = overrideUseMainStyle
        self.overrideIsHovering = overrideIsHovering
        self.overrideIsPressed = overrideIsPressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        let resolvedButtonStyle = resolvedButtonStyle(configuration: configuration)
        let resolvedSurfaceStyle = surfaceStyle(for: resolvedButtonStyle)

        configuration.label
            .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            .fontWeight(resolvedButtonStyle.fontWeight)
            .luminareSurface(
                isHovering: overrideIsHovering || isHovering,
                isPressed: overrideIsPressed || configuration.isPressed,
                style: resolvedSurfaceStyle
            )
            .onHover { isHovering = $0 }
    }

    private func resolvedButtonStyle(configuration: Configuration) -> LuminareSurfaceStyle.ButtonStyle {
        let baseStyle = colorScheme == .dark ? surfaceStyle.darkStyle : surfaceStyle.lightStyle
        let buttonStyle: LuminareSurfaceStyle.ButtonStyle? = if overrideUseMainStyle {
            nil
        } else if colorScheme == .dark {
            surfaceStyle.buttonDarkStyle
        } else {
            surfaceStyle.buttonLightStyle
        }

        let resolvedButtonStyle = buttonStyle ?? .init(
            fillStyle: baseStyle.fillStyle,
            borderStyle: baseStyle.borderStyle,
            shadowStyle: baseStyle.shadowStyle,
            fontWeight: .regular
        )

        if let tint = buttonTint(configuration: configuration) {
            let tintFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle> = .init(
                normal: AnyShapeStyle(tint.opacity(0.2)),
                hovering: AnyShapeStyle(tint.opacity(0.3)),
                pressed: AnyShapeStyle(tint.opacity(0.4))
            )

            return .init(
                fillStyle: tintFillStyle,
                borderStyle: resolvedButtonStyle.borderStyle,
                shadowStyle: resolvedButtonStyle.shadowStyle,
                fontWeight: resolvedButtonStyle.fontWeight
            )
        }

        return resolvedButtonStyle
    }

    private func surfaceStyle(for buttonStyle: LuminareSurfaceStyle.ButtonStyle) -> LuminareSurfaceStyle {
        let resolvedStyle = LuminareSurfaceStyle.Style(
            fillStyle: buttonStyle.fillStyle,
            borderStyle: buttonStyle.borderStyle,
            shadowStyle: buttonStyle.shadowStyle
        )

        return .init(
            lightStyle: resolvedStyle,
            darkStyle: resolvedStyle
        )
    }

    private func buttonTint(configuration: Configuration) -> AnyShapeStyle? {
        if tinted {
            return AnyShapeStyle(.tint)
        }

        if let role = configuration.role,
           role == .destructive || role == .cancel {
            return AnyShapeStyle(.red)
        }

        return nil
    }
}
