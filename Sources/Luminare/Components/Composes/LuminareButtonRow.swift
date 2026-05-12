//
//  LuminareButtonRow.swift
//  Luminare
//
//  Created by Adon Omeri on 23/3/2026.
//

import SwiftUI

@resultBuilder
public struct LuminareButtonBuilder {
    public static func buildExpression(_ expression: some View) -> [AnyView] {
        [AnyView(expression)]
    }

    public static func buildBlock(_ components: [AnyView]...) -> [AnyView] {
        components.flatMap(\.self)
    }

    public static func buildOptional(_ component: [AnyView]?) -> [AnyView] {
        component ?? []
    }

    public static func buildEither(first component: [AnyView]) -> [AnyView] {
        component
    }

    public static func buildEither(second component: [AnyView]) -> [AnyView] {
        component
    }

    public static func buildArray(_ components: [[AnyView]]) -> [AnyView] {
        components.flatMap(\.self)
    }

    public static func buildLimitedAvailability(_ component: [AnyView]) -> [AnyView] {
        component
    }
}

public struct LuminareButtonRow: View {
    @Environment(\.luminareButtonComposeSpacing) private var spacing

    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded

    private let buttons: [AnyView]

    public init(
        @LuminareButtonBuilder _ buttons: () -> [AnyView]
    ) {
        self.buttons = buttons()
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                let button = buttons[index]
                let isFirst = index == 0
                let isLast = index == buttons.count - 1

                button
                    .luminareRoundingBehavior(
                        topLeading: isFirst ? topLeadingRounded : false,
                        topTrailing: isLast ? topTrailingRounded : false,
                        bottomLeading: isFirst ? bottomLeadingRounded : false,
                        bottomTrailing: isLast ? bottomTrailingRounded : false
                    )
            }
        }
        .buttonStyle(.luminare)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareButtonRow",
    traits: .sizeThatFitsLayout
) {
    LuminarePane {
        LuminareSection {
            LuminareButtonRow {
                Button {
                    print(1)
                } label: {
                    Text("Button 1")
                }

                Button {
                    print(2)
                } label: {
                    Text("Button 2")
                }

                Button {
                    print(3)
                } label: {
                    Text("Button 3")
                }
            }
            .luminareRoundingBehavior(top: true)

            Text("Other content ...")
                .foregroundStyle(.secondary)
        }
    }
}
