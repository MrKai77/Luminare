//
//  LuminareButtonStyle+Previews.swift
//
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
                    HStack {
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
                .buttonStyle(LuminareCosmeticButtonStyle {
                    Image(systemName: "star.fill")
                })
                .frame(height: 72)

                Button {} label: {
                    HStack {
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
                .buttonStyle(LuminareCosmeticButtonStyle(isHovering: true) {
                    Image(systemName: "star.fill")
                })
                .frame(height: 72)
            }

            LuminareSection {
                HStack {
                    Button("Prominent Tinted") {}
                        .buttonStyle(LuminareProminentButtonStyle())
                        .tint(.purple)

                    Button("Prominent Tinted") {}
                        .buttonStyle(LuminareProminentButtonStyle())
                        .tint(.teal)

                    Button("Prominent") {}
                        .buttonStyle(LuminareProminentButtonStyle())
                }
                .frame(height: 40)

                HStack {
                    Button("Normal") {}
                        .buttonStyle(LuminareButtonStyle())

                    Button("Destructive") {}
                        .buttonStyle(LuminareDestructiveButtonStyle())
                }
                .frame(height: 40)
            }

            LuminareSection {
                HStack {
                    Button("Compact") {}
                        .buttonStyle(LuminareCompactButtonStyle())
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
        LuminareSection {
            Button("Click me!") {}
                .buttonStyle(LuminareButtonStyle())
                .frame(height: 40)
        }
    }
#endif

// MARK: - LuminareDestructiveButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareDestructiveButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        LuminareSection {
            Button("Click me!") {}
                .buttonStyle(LuminareDestructiveButtonStyle())
                .frame(height: 40)
        }
    }
#endif

// MARK: - LuminareProminentButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareProminentButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        LuminareSection {
            Button("Click me!") {}
                .buttonStyle(LuminareProminentButtonStyle())
                .frame(height: 40)
        }
    }
#endif

// MARK: - LuminareCosmeticButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareCosmeticButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        LuminareSection {
            Button {} label: {
                HStack {
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
            .buttonStyle(LuminareCosmeticButtonStyle {
                Image(systemName: "star.fill")
            })
            .frame(height: 72)

            Button {} label: {
                HStack {
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
            .buttonStyle(LuminareCosmeticButtonStyle(isHovering: true) {
                Image(systemName: "star.fill")
            })
            .frame(height: 72)
        }
    }
#endif

// MARK: - LuminareCompactButtonStyle

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareCompactButtonStyle",
        traits: .sizeThatFitsLayout
    ) {
        LuminareSection {
            Button("Click me!") {}
                .buttonStyle(LuminareCompactButtonStyle())
                .frame(height: 40)
        }
    }
#endif

// MARK: - LuminareBordered

#if DEBUG
    @available(macOS 15.0, *)
    #Preview(
        "LuminareBordered",
        traits: .sizeThatFitsLayout
    ) {
        Text("Anything with a border")
            .fixedSize()
            .padding(8)
            .modifier(LuminareBordered())
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
        VStack {
            Text("Not bordered")
                .fixedSize()
                .modifier(LuminareHoverable())

            Text("Bordered")
                .fixedSize()
                .modifier(LuminareHoverable(isBordered: true))

            Text("Hovering")
                .fixedSize()
                .modifier(LuminareHoverable(isHovering: true))
        }
    }
#endif
