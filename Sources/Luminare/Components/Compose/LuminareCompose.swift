//
//  LuminareCompose.swift
//  
//
//  Created by KrLite on 2024/10/25.
//

import SwiftUI

struct LuminareCompose<Label, Content>: View where Label: View, Content: View {
    @Environment(\.isEnabled) private var isEnabled
    
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let reducesTrailingSpace: Bool
    let spacing: CGFloat?
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        reducesTrailingSpace: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.reducesTrailingSpace = reducesTrailingSpace
        self.spacing = spacing
        self.label = label
        self.content = content
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        reducesTrailingSpace: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            reducesTrailingSpace: reducesTrailingSpace,
            spacing: spacing
        ) {
            content()
        } label: {
            Text(key)
        }
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            HStack(spacing: 0) {
                label()
                    .opacity(isEnabled ? 1 : 0.5)
                    .disabled(!isEnabled)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            content()
                .disabled(!isEnabled)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.trailing, reducesTrailingSpace ? -4 : 0)
        .frame(minHeight: elementMinHeight)
    }
}

#Preview {
    LuminareSection {
        LuminareCompose("Label", reducesTrailingSpace: true) {
            Button {
                
            } label: {
                Text("Test")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        
        
        LuminareCompose("Label", reducesTrailingSpace: true) {
            Button {
                
            } label: {
                Text("Test")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        .disabled(true)
    }
    .padding()
}
