//
//  LuminareAspectRatioModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

struct LuminareAspectRatioModifier: ViewModifier {
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareAspectRatio) private var aspectRatio
    @Environment(\.luminareAspectRatioContentMode) private var contentMode
    @Environment(\.luminareAspectRatioHasFixedHeight) private var hasFixedHeight

    @ViewBuilder func body(content: Content) -> some View {
        if let contentMode {
            Group {
                if isConstrained {
                    content
                        .frame(
                            minWidth: minWidth, maxWidth: .infinity,
                            minHeight: minHeight,
                            maxHeight: hasFixedHeight ? nil : .infinity
                        )
                        .aspectRatio(
                            aspectRatio,
                            contentMode: contentMode
                        )
                } else {
                    content
                        .frame(
                            maxWidth: .infinity, minHeight: minHeight,
                            maxHeight: .infinity
                        )
                }
            }
            .fixedSize(
                horizontal: contentMode == .fit,
                vertical: hasFixedHeight
            )
        } else {
            content
        }
    }

    private var isConstrained: Bool {
        guard let contentMode else { return false }
        return contentMode == .fit || hasFixedHeight
    }

    private var minWidth: CGFloat? {
        if hasFixedHeight, let aspectRatio {
            minHeight * aspectRatio
        } else {
            nil
        }
    }
}
