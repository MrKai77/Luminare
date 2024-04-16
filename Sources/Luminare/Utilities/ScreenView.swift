//
//  ScreenView.swift
//  Luminare Tester
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct ScreenView<Content>: View where Content: View {

    let screenContent: () -> Content

    public init(@ViewBuilder _ screenContent: @escaping () -> Content) {
        self.screenContent = screenContent
    }

    public var body: some View {
        ZStack {
            Group {
                if let screen = NSScreen.main,
                   let url = NSWorkspace.shared.desktopImageURL(for: screen),
                   let image = NSImage(contentsOf: url) {

                    GeometryReader { geo in
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .allowsHitTesting(false)
                } else {
                    Rectangle()
                        .foregroundStyle(Color.accentColor)
                }
            }
            .overlay {
                screenContent()
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 12
            ))

            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 12
            )
            .stroke(.gray, lineWidth: 2)

            UnevenRoundedRectangle(
                topLeadingRadius: 9.5,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 9.5
            )
            .stroke(.black, lineWidth: 5)
            .padding(2.5)

            UnevenRoundedRectangle(
                topLeadingRadius: 11.5,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 11.5
            )
            .stroke(.gray.opacity(0.2), lineWidth: 1)
            .padding(0.5)
        }
        .aspectRatio(16/10, contentMode: .fill)
    }
}
