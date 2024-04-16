//
//  LuminareSection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct LuminareSection<Content: View>: View {
    let headerSpacing: CGFloat = 8
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4

    let header: String?
    let disablePadding: Bool
    let content: () -> Content

    public init(_ header: String? = nil, disablePadding: Bool = false, @ViewBuilder _ content: @escaping () -> Content) {
        self.header = header
        self.disablePadding = disablePadding
        self.content = content
    }

    public var body: some View {
        VStack(spacing: headerSpacing) {
            if let header = self.header {
                HStack {
                    Text(header)
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }

            DividedVStack(applyMaskToItems: !disablePadding) {
                self.content()
            }
            .frame(maxWidth: .infinity)
            .background(.quinary)
            .clipShape(
                .rect(
                    cornerRadius: self.cornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: self.cornerRadius,
                    style: .continuous
                )
                .strokeBorder(.quaternary, lineWidth: 1)
            }
        }
    }
}
