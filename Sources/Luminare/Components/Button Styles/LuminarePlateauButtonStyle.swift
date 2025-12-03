//
//  LuminarePlateauButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style with a plateau appearance.
public struct LuminarePlateauButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareMinHeight) private var minHeight

    @State private var isHovering: Bool = false
    private let tinted: Bool

    public init(tinted: Bool = false) {
        self.tinted = tinted
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            .opacity(isEnabled ? 1 : 0.5)
            .fontWeight(.medium)
            .luminarePlateau(
                isPressed: configuration.isPressed,
                isHovering: isHovering,
                overrideFillStyle: fillStyle(configuration: configuration)
            )
            .onHover { isHovering = $0 }
    }

    private func fillStyle(configuration: Configuration) -> LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? {
        if let tint = buttonTint(configuration: configuration) {
            return .init(
                normal: AnyShapeStyle(tint.opacity(0.15)),
                hovering: AnyShapeStyle(tint.opacity(0.25)),
                pressed: AnyShapeStyle(tint.opacity(0.4))
            )
        }

        return nil
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
