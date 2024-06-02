//
//  LuminareInfoView.swift
//
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public struct LuminareInfoView: View {
    let color: Color
    let description: LocalizedStringKey
    @State var isShowingDescription: Bool = false

    public init(_ description: LocalizedStringKey, _ color: Color = .blue) {
        self.color = color
        self.description = description
    }

    public var body: some View {
        VStack {
            Button {
                isShowingDescription.toggle()
            } label: {
                Circle()
                    .foregroundStyle(color)
                    .frame(width: 4, height: 4)
                    .padding([.horizontal, .bottom], 4)
                    .contentShape(.rect)
            }
            .buttonStyle(PlainButtonStyle())

            .padding(.bottom, -4)
            .popover(isPresented: $isShowingDescription, arrowEdge: .bottom) {
                Text(description)
                    .multilineTextAlignment(.center)
                    .padding(8)
            }

            Spacer()
        }
    }
}
