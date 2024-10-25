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
    let disabled: Bool
    private let hasInfo: Bool
    
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        hasInfo: Bool,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.disabled = disabled
        self.hasInfo = hasInfo
        self.label = label
        self.content = content
        self.info = info
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled, hasInfo: true,
            content: content, label: label, info: info
        )
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled, hasInfo: true,
            content: content
        ) {
            Text(key)
        } info: {
            info()
        }
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        infoKey: LocalizedStringKey,
        infoWithoutPadding: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled, hasInfo: true,
            content: content, label: label
        ) {
            LuminareInfoView(infoKey, withoutPadding: infoWithoutPadding)
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        infoKey: LocalizedStringKey,
        infoWithoutPadding: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text, Info == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled,
            infoKey: infoKey, infoWithoutPadding: infoWithoutPadding,
            content: content
        ) {
            Text(key)
        }
    }
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled, hasInfo: false,
            content: content, label: label
        ) {
            LuminareInfoView {
                EmptyView()
            }
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text, Info == EmptyView {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled,
            content: content
        ) {
            Text(key)
        }
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                label()
                
                if hasInfo {
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
