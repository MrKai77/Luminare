//
//  LuminareInfoView.swift
//
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public struct LuminareInfoView<Content>: View where Content: View {
    let color: Color
    let arrowEdge: Edge
    @ViewBuilder private let content: () -> Content
    
    @State private var isShowingDescription: Bool = false
    @State private var isHovering: Bool = false
    @State private var hoverTimer: Timer?
    
    public init(
        color: Color = .accentColor,
        arrowEdge: Edge = .bottom,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.color = color
        self.arrowEdge = arrowEdge
        self.content = content
    }

    public init(
        _ key: LocalizedStringKey,
        color: Color = .accentColor,
        arrowEdge: Edge = .bottom
    ) where Content == Text {
        self.init(color: color, arrowEdge: arrowEdge) {
            Text(key)
        }
    }
    
    public init() where Content == EmptyView {
        self.init {
            EmptyView()
        }
    }

    public var body: some View {
        VStack {
            Circle()
                .foregroundStyle(color)
                .frame(width: 4, height: 4)
                .padding(.leading, 4)
                .padding(12)
                .contentShape(.circle)
                .padding(-12)
                .onHover { hovering in
                    isHovering = hovering

                    if isHovering {
                        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                            isShowingDescription = true
                        }
                    } else {
                        hoverTimer?.invalidate()
                        isShowingDescription = false
                    }
                }

                .popover(isPresented: $isShowingDescription, arrowEdge: arrowEdge) {
                    content()
                        .multilineTextAlignment(.center)
                }

            Spacer()
        }
    }
}

#Preview {
    VStack {
        HStack {
            Text("A sentence")
            
            LuminareInfoView {
                Text("An info description")
                    .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        
        HStack {
            Text("A sentence")
            
            LuminareInfoView(color: .violet, arrowEdge: .leading) {
                Text("An info description")
                    .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding()
}
