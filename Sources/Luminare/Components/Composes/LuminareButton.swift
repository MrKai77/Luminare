//
//  LuminareButton.swift
//  Luminare
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

// MARK: - Button (Compose)

public struct LuminareButton<Label, Content>: View where Label: View, Content: View {
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding

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

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> ()
    ) where Label == Text {
        self.init(role: role) {
            Text(title)
        } content: {
            content()
        } action: {
            action()
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> ()
    ) where Label == Text {
        self.init(role: role) {
            Text(titleKey)
        } content: {
            content()
        } action: {
            action()
        }
    }

    @_disfavoredOverload
    public init(
        _ content: some StringProtocol,
        role: ButtonRole? = nil,
        @ViewBuilder label: @escaping () -> Label,
        action: @escaping () -> ()
    ) where Content == Text {
        self.init(role: role, label: label) {
            Text(content)
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
        self.init(role: role, label: label) {
            Text(contentKey)
        } action: {
            action()
        }
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        _ content: some StringProtocol,
        role: ButtonRole? = nil,
        action: @escaping () -> ()
    ) where Label == Text, Content == Text {
        self.init(role: role) {
            Text(title)
        } content: {
            Text(content)
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
        self.init(role: role) {
            Text(titleKey)
        } content: {
            Text(contentKey)
        } action: {
            action()
        }
    }

    // MARK: Body

    public var body: some View {
        LuminareCompose {
            Button(role: role) {
                action()
            } label: {
                content()
            }
            .buttonStyle(.luminareCompact)
            .preference(
                key: LuminareComposeIgnoreSafeAreaEdgesKey.self,
                value: .trailing
            )
        } label: {
            label()
        }
        .luminareComposeStyle(.inline)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareButton",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareButton("Button 1", "Click Me!") {
            print(1)
        }

        LuminareButton(
            "Button 2",
            content: {
                Label("Content", systemImage: "sparkles")
            },
            action: {
                print(2)
            }
        )

        LuminareButton(
            "Action 3",
            label: {
                Label("Label", systemImage: "star")
            }, action: {
                print(3)
            }
        )

        LuminareButton {
            Label("Label", systemImage: "wand.and.rays")
        } content: {
            Label("Content", systemImage: "party.popper")
        } action: {
            print(4)
        }
    }
}
