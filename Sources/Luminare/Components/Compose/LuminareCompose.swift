//
//  LuminareCompose.swift
//  
//
//  Created by KrLite on 2024/10/25.
//

import SwiftUI

struct LuminareCompose<Label, Content, Info>: View where Label: View, Content: View, Info: View {
    @Environment(\.isEnabled) private var isEnabled
    
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let alignTrailing: Bool
    let spacing: CGFloat?
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        alignTrailing: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info> = {
            LuminareInfoView()
        }
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.alignTrailing = alignTrailing
        self.spacing = spacing
        self.label = label
        self.content = content
        self.info = info
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        alignTrailing: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info> = {
            LuminareInfoView()
        }
    ) where Label == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            alignTrailing: alignTrailing,
            spacing: spacing
        ) {
            content()
        } label: {
            Text(key)
        } info: {
            info()
        }
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        alignTrailing: Bool = false,
        spacing: CGFloat? = nil,
        infoKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            alignTrailing: alignTrailing,
            spacing: spacing,
            content: content, label: label
        ) {
            LuminareInfoView(infoKey)
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        alignTrailing: Bool = false,
        spacing: CGFloat? = nil,
        infoKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text, Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            alignTrailing: alignTrailing,
            spacing: spacing,
            infoKey: infoKey,
            content: content
        ) {
            Text(key)
        }
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            HStack(spacing: 0) {
                label()
                    .opacity(isEnabled ? 1 : 0.5)
                    .disabled(!isEnabled)
                
                if Info.self != EmptyView.self {
                    info()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            content()
                .disabled(!isEnabled)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.trailing, alignTrailing ? -4 : 0)
        .frame(minHeight: elementMinHeight)
    }
}

#Preview {
    LuminareSection {
        LuminareCompose("Label", alignTrailing: true) {
            Button {
                
            } label: {
                Text("Test")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        
        
        LuminareCompose("Label", alignTrailing: true) {
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
