//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized pane that well distributes its content to cooperate with the ``LuminareWindow``.
public struct LuminarePane<Header, Content>: View where Header: View, Content: View {
    @Environment(\.luminareTitleBarHeight) private var titleBarHeight

    // MARK: Fields

    @ViewBuilder private var content: () -> Content, header: () -> Header

    // MARK: Initializers

    /// Initializes a ``LuminarePane``.
    ///
    /// - Parameters:
    ///   - content: the content view.
    ///   - header: the header that is located at the titleBar's position.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.content = content
        self.header = header
    }

    /// Initializes a ``LuminarePane`` where the header is a localized text.
    ///
    /// - Parameters:
    ///   - header: the header text.
    ///   - content: the content view.
    @_disfavoredOverload
    public init(
        _ header: some StringProtocol,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text {
        self.init(content: content) {
            Text(header)
        }
    }

    /// Initializes a ``LuminarePane`` where the header is a localized text.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - content: the content view.
    public init(
        _ headerKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text {
        self.init(content: content) {
            Text(headerKey)
        }
    }

    /// Initializes a ``LuminarePane`` where there is no header.
    ///
    /// - Parameters:
    ///   - content: the content view.
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView {
        self.init(content: content, header: { EmptyView() })
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 0) {
            wrappedHeader

            Divider()

            content()
        }
        .luminareListFixedHeight(until: .infinity)
        .luminareBackground()
    }

    private var wrappedHeader: some View {
        header()
            .luminareCornerRadius(8)
            .luminareMinHeight(26)
            .padding(.horizontal, 12)
            .frame(height: titleBarHeight, alignment: .leading)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminarePane",
    traits: .sizeThatFitsLayout
) {
    LuminarePane("Luminare") {
        Section("General") {
            LuminareToggle(
                "Launch at login",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Hide menu bar icon",
                isOn: .constant(true)
            )

            LuminareSliderPicker(
                "Animation speed",
                ["Instant", "Fast", "Smooth"],
                selection: .constant("Fast")
            ) { speed in
                Text(speed)
                    .monospaced()
            }
        }

        Section("Window") {
            LuminareButton(
                "Debug",
                "Reset Window Frame"
            ) {}

            LuminareToggle(
                "Restore window frame on drag",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Include padding",
                isOn: .constant(true)
            )
        }

        Section("Cursor") {
            LuminareToggle(
                "Use screen with cursor",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Move cursor with window",
                isOn: .constant(true)
            )
        }
    }
    .luminareFormLayout(.form)
}
