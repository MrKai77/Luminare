//
//  LuminareModalView+Previews.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

private struct ModalContent: View {
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            Button("Toggle Expansion") {
                withAnimation(.snappy(duration: 0.25)) {
                    isExpanded.toggle()
                }
            }
            .padding()

            if isExpanded {
                Text("Expanded Content")
                    .font(.title)
                    .padding()
            }
        }
    }
}

@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isPresented1 = false
    @Previewable @State var isPresented2 = false

    @Previewable @State var offsetX = Double.zero
    @Previewable @State var offsetY = Double.zero

    VStack {
        Spacer()

        HStack {
            TextField("Offset X", value: $offsetX, format: .number)

            TextField("Offset Y", value: $offsetY, format: .number)

            Button("Reset") {
                offsetX = .zero
                offsetY = .zero
            }
        }

        HStack {
            Button("Toggle Modal (Screen Center)") {
                isPresented1.toggle()
            }
            .luminareModal(isPresented: $isPresented1) {
                ModalContent()
                    .frame(width: 400)
            }
            .luminareModalPresentation(.screenCenter.offset(x: CGFloat(offsetX), y: CGFloat(offsetY)))

            Button("Toggle Modal (Window Center)") {
                isPresented2.toggle()
            }
            .luminareModal(isPresented: $isPresented2) {
                ModalContent()
                    .frame(width: 400)
            }
            .luminareModalPresentation(.windowCenter.offset(x: CGFloat(offsetX), y: CGFloat(offsetY)))
        }
    }
    .padding()
    .frame(width: 500, height: 300)
}
