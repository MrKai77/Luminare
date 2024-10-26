//
//  LuminareLabeledContent.swift
//  
//
//  Created by KrLite on 2024/10/25.
//

import SwiftUI

struct LuminareLabeledContent<Label, Content, Info>: View where Label: View, Content: View, Info: View {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let spacing: CGFloat?
    let disabled: Bool
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.spacing = spacing
        self.disabled = disabled
        self.label = label
        self.content = content
        self.info = info
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            spacing: spacing, disabled: disabled
        ) {
            content()
        } label: {
            label()
        } info: {
            LuminareInfoView()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            spacing: spacing, disabled: disabled
        ) {
            content()
        } label: {
            Text(key)
        } info: {
            info()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text, Info == EmptyView {
        self.init(
            key,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            spacing: spacing, disabled: disabled
        ) {
            content()
        } info: {
            LuminareInfoView()
        }
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        infoKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            spacing: spacing, disabled: disabled,
            content: content, label: label
        ) {
            LuminareInfoView(infoKey)
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        spacing: CGFloat? = nil,
        disabled: Bool = false,
        infoKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text, Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            spacing: spacing, disabled: disabled,
            infoKey: infoKey,
            content: content
        ) {
            Text(key)
        }
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                label()
                
                if Info.self != EmptyView.self {
                    info()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            content()
                .disabled(disabled)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minHeight: elementMinHeight)
    }
}
