//
//  LuminareButtonCompose.swift
//  Luminare
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

// MARK: - Button Compose

public struct LuminareButtonCompose<Label, Content>: View where Label: View, Content: View {
    // MARK: Fields

    private let role: ButtonRole?
    @ViewBuilder private var label: () -> Label
    @ViewBuilder private var content: () -> Content
    private let action: () -> ()

    // MARK: Initializers

    public init(
        role: ButtonRole? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> ()
    ) {
        self.role = role
        self.label = label
        self.content = content
        self.action = action
    }

    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> ()
    ) where Label == Text {
        self.init(
            role: role
        ) {
            Text(titleKey)
        } content: {
            content()
        } action: {
            action()
        }
    }

    public init(
        _ contentKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        @ViewBuilder label: @escaping () -> Label,
        action: @escaping () -> ()
    ) where Content == Text {
        self.init(
            role: role,
            label: label
        ) {
            Text(contentKey)
        } action: {
            action()
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        _ contentKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        action: @escaping () -> ()
    ) where Label == Text, Content == Text {
        self.init(
            role: role
        ) {
            Text(titleKey)
        } content: {
            Text(contentKey)
        } action: {
            action()
        }
    }

    // MARK: Body

    public var body: some View {
        LuminareCompose(contentMaxWidth: nil) {
            Button(role: role) {
                action()
            } label: {
                content()
            }
            .buttonStyle(.luminareCompact)
        } label: {
            label()
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareButtonCompose",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareButtonCompose("Button", "Click Me!") {
            print(1)
        }
    }
}
