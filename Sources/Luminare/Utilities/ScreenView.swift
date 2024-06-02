//
//  ScreenView.swift
//  Luminare Tester
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct ScreenView<Content>: View where Content: View {
    let screenContent: () -> Content
    @State private var image: NSImage?

    private let screenShape = UnevenRoundedRectangle(
        topLeadingRadius: 12,
        bottomLeadingRadius: 0,
        bottomTrailingRadius: 0,
        topTrailingRadius: 12
    )

    public init(@ViewBuilder _ screenContent: @escaping () -> Content) {
        self.screenContent = screenContent
    }

    public var body: some View {
        ZStack {
            GeometryReader { geo in
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    ZStack {
                        /// We may be able to add the wallpaper
                        /// But the method changed in Sonoma
                        /// So this is kinda a v2 thing
                        Color.black
                        Image(systemName: "apple.logo")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .allowsHitTesting(false)
            .task {
                await updateImage()
            }
            .overlay {
                if image != nil {
                    screenContent()
                        .padding(5)
                }
            }
            .clipShape(screenShape)

            screenShape
                .stroke(.gray, lineWidth: 2)

            screenShape
                .inset(by: 2.5)
                .stroke(.black, lineWidth: 5)

            screenShape
                .inset(by: 3)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        }
        .aspectRatio(16/10, contentMode: .fill)
    }

    func updateImage() async {
        guard 
            let screen = NSScreen.main,
            let url = NSWorkspace.shared.desktopImageURL(for: screen),
            self.image == nil || self.image!.isValid == false
        else {
            return
        }

        if let newImage = NSImage.resize(url, width: 300) {
            withAnimation {
                self.image = newImage
            }
        }
    }
}

extension NSImage {
    static func resize(_ url: URL, width: CGFloat) -> NSImage? {
        guard let inputImage = NSImage(contentsOf: url) else { return nil }
        let aspectRatio = inputImage.size.width / inputImage.size.height
        let thumbSize = NSSize(
            width: width,
            height: width / aspectRatio
        )

        let outputImage = NSImage(size: thumbSize)
        outputImage.lockFocus()
        inputImage.draw(
            in: NSRect(origin: .zero, size: thumbSize),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
        outputImage.unlockFocus()

        return outputImage
    }
}
