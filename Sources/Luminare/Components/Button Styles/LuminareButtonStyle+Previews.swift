//
//  LuminareButtonStyle+Previews.swift
//  Luminare
//
//  Created by KrLite on 2024/11/4.
//

import SwiftUI

// MARK: - All

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareButtonStyles",
        traits: .sizeThatFitsLayout
    ) {
        VStack {
            LuminareSection {
                HStack(spacing: 4) {
                    Button("Prominent") {}
                        .buttonStyle(.luminare(tinted: true))
                        .tint(.purple)
                        .luminareRoundingBehavior(topLeading: true)

                    Button("Prominent") {}
                        .buttonStyle(.luminare(tinted: true))
                        .tint(.teal)
                        .luminareRoundingBehavior(topTrailing: true)
                }
                .frame(height: 40)

                HStack(spacing: 4) {
                    Button("Normal") {}
                        .luminareRoundingBehavior(bottomLeading: true)

                    Button("Destructive", role: .destructive) {}
                        .luminareRoundingBehavior(bottomTrailing: true)
                }
                .frame(height: 40)
            }

            LuminareSection {
                HStack {
                    Button("Plateau") {}
                        .luminareRoundingBehavior(top: true, bottom: true)
                }
                .frame(height: 40)
            }
        }
        .buttonStyle(.luminare)
    }
#endif

// MARK: - LuminareButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        Button("Click Me!") {}
            .buttonStyle(.luminare)
            .frame(height: 40)
    }
#endif

// MARK: - LuminareProminentButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareProminentButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        Button("Click Me!") {}
            .buttonStyle(.luminare(tinted: true))
            .frame(height: 40)

        Button("My Role is Destructive", role: .destructive) {}
            .buttonStyle(.luminare)
            .frame(height: 40)
    }
#endif

// MARK: - LuminareHoverable

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareHoverable",
        traits: .sizeThatFitsLayout
    ) {
        Text("Not Bordered")
            .fixedSize()
            .modifier(LuminareHoverableModifier())
            .luminareBorderedStates(.none)

        Text("Bordered")
            .fixedSize()
            .modifier(LuminareHoverableModifier())

        Text("Bordered, Hovering")
            .fixedSize()
            .modifier(LuminareHoverableModifier(isHovering: true))

        Text("Bordered, Pressed")
            .fixedSize()
            .modifier(LuminareHoverableModifier(isPressed: true))
    }
#endif
