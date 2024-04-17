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
                GeometryReader { geo in
                    Group {
                        if let screen = NSScreen.main,
                           let url = NSWorkspace.shared.desktopImageURL(for: screen) {

                            AsyncImage(
                                url: url,
                                scale: 1,
                                transaction: .init(animation: .easeOut)
                            ) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .transition(.opacity.animation(.easeIn))
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .allowsHitTesting(false)
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
