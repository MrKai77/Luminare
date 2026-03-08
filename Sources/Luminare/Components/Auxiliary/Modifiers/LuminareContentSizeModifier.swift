//
//  LuminareContentSizeModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareContentSizeModifier: ViewModifier {
    @Environment(\.luminareMinHeight) private var minHeight
    private let aspectRatio: CGFloat?
    private let contentMode: ContentMode?
    private let hasFixedHeight: Bool

    public init(
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        hasFixedHeight: Bool = false
    ) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.hasFixedHeight = hasFixedHeight
    }

    public func body(content: Content) -> some View {
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
                .fixedSize(
                    horizontal: false,
                    vertical: hasFixedHeight
                )
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
