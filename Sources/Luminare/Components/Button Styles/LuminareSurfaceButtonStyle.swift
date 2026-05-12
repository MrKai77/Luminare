//
//  LuminareSurfaceButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style with a plateau appearance.
public struct LuminareSurfaceButtonStyle: ButtonStyle {
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareSurfaceStyle) private var surfaceStyle
    @State private var isHovering: Bool = false

    private let tinted: Bool
    private let overrideIsHovering: Bool
    private let overrideIsPressed: Bool

    public init(
        tinted: Bool = false,
        overrideIsHovering: Bool = false,
        overrideIsPressed: Bool = false
    ) {
        self.tinted = tinted
        self.overrideIsHovering = overrideIsHovering
        self.overrideIsPressed = overrideIsPressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        let resolvedSurfaceStyle = resolvedSurfaceStyle(configuration: configuration)

        configuration.label
            .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            .fontWeight(resolvedSurfaceStyle.buttonFontWeight)
            .luminareSurface(
                isHovering: overrideIsHovering || isHovering,
                isPressed: overrideIsPressed || configuration.isPressed,
                style: resolvedSurfaceStyle
            )
            .onHover { isHovering = $0 }
    }

    private func resolvedSurfaceStyle(configuration: Configuration) -> LuminareSurfaceStyle {
        if let tint = buttonTint(configuration: configuration) {
            let tintFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle> = .init(
                normal: AnyShapeStyle(tint.opacity(0.2)),
                hovering: AnyShapeStyle(tint.opacity(0.3)),
                pressed: AnyShapeStyle(tint.opacity(0.4))
            )

            return .init(
                fillStyle: tintFillStyle,
                darkFillStyle: tintFillStyle,
                borderStyle: surfaceStyle.borderStyle,
                shadowStyle: surfaceStyle.shadowStyle,
                buttonFontWeight: surfaceStyle.buttonFontWeight
            )
        }

        return surfaceStyle
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
