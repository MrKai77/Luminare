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
            Button {} label: {
                HStack(spacing: 4) {
                    Image(systemName: "app.gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cosmetic")
                            .fontWeight(.medium)

                        Text("Custom Layout")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(8)
            }
            .buttonStyle(.luminareCosmetic(icon: Image(systemName: "star.fill")))
            .luminareRoundingBehavior(top: true)
            .frame(height: 72)

            Button {} label: {
                HStack(spacing: 4) {
                    Image(systemName: "app.gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cosmetic Hovering")
                            .fontWeight(.medium)

                        Text("Custom Layout")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(8)
            }
            .buttonStyle(.luminareCosmetic(icon: Image(systemName: "star.fill")))
            .luminareRoundingBehavior(bottom: true)
            .frame(height: 72)
        }

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
                    .buttonStyle(.luminare)
                    .luminareRoundingBehavior(bottomLeading: true)

                Button("Destructive", role: .destructive) {}
                    .buttonStyle(.luminare)
                    .luminareRoundingBehavior(bottomTrailing: true)
            }
            .frame(height: 40)
        }

        LuminareSection {
            HStack {
                Button("Compact") {}
                    .buttonStyle(.luminareCompact)
                    .luminareAspectRatio(contentMode: .fill, hasFixedHeight: false)
                    .luminareRoundingBehavior(top: true, bottom: true)
            }
            .frame(height: 40)
        }
    }
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

// MARK: - LuminareCosmeticButtonStyle

#if DEBUG
@available(macOS 15.0, *)
#Preview(
    "LuminareCosmeticButtonStyle",
    traits: .sizeThatFitsLayout
) {
    Button {} label: {
        HStack(spacing: 4) {
            Image(systemName: "app.gift.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)

            VStack(alignment: .leading, spacing: 2) {
                Text("Cosmetic")
                    .fontWeight(.medium)

                Text("Custom Layout")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(8)
    }
    .buttonStyle(
        .luminareCosmetic(icon: Image(systemName: "star.fill"))
    )
    .frame(height: 72)

    Button {} label: {
        HStack(spacing: 4) {
            Image(systemName: "app.gift.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)

            VStack(alignment: .leading, spacing: 2) {
                Text("Cosmetic Hovering")
                    .fontWeight(.medium)

                Text("Custom Layout")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(8)
    }
    .buttonStyle(.luminareCosmetic(icon: Image(systemName: "star.fill")))
    .frame(height: 72)
}
#endif

// MARK: - LuminareCompactButtonStyle

#if DEBUG
@available(macOS 15.0, *)
#Preview(
    "LuminareCompactButtonStyle",
    traits: .sizeThatFitsLayout
) {
    Button("Click Me!") {}
        .buttonStyle(.luminareCompact)
        .luminareAspectRatio(contentMode: .fill, hasFixedHeight: false)
        .frame(height: 40)
}
#endif

// MARK: - LuminareBordered

#if DEBUG
@available(macOS 15.0, *)
#Preview(
    "LuminareBordered",
    traits: .sizeThatFitsLayout
) {
    Text("Anything with a Border")
        .fixedSize()
        .padding(8)
        .modifier(LuminareBorderedModifier())
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
