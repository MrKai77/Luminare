//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public enum LuminarePaneLayout: Equatable, Hashable, Codable, Sendable {
    case none
    @available(macOS 15.0, *)
    case form
    case stacked(spacing: CGFloat = 15)

    public static var stacked: Self { .stacked() }
}

// MARK: - Pane

/// A stylized pane that well distributes its content to cooperate with the ``LuminareWindow``.
public struct LuminarePane<Header, Content>: View where Header: View, Content: View {
    @Environment(\.luminarePaneLayout) private var layout
    @Environment(\.luminareTitleBarHeight) private var titleBarHeight

    // MARK: Fields

    @ViewBuilder private var content: () -> Content, header: () -> Header

    @State private var luminareClickedOutside = false

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
            header()
                .buttonStyle(TabHeaderButtonStyle())
                .padding(.horizontal, 10)
                .padding(.trailing, 5)
                .frame(height: titleBarHeight, alignment: .leading)

            Divider()

            Group {
                switch layout {
                case .none:
                    content()
                case .form:
                    if #available(macOS 15.0, *) {
                        Form {
                            content()
                        }
                        .formStyle(.luminare)
                        .clipped()
                    }
                case let .stacked(spacing):
                    AutoScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: spacing) {
                            content()
                        }
                        .padding(12)
                    }
                    .clipped()
                }
            }
            .environment(\.luminareClickedOutside, luminareClickedOutside)
            .background {
                Color.white.opacity(0.0001)
                    .onTapGesture {
                        luminareClickedOutside.toggle()
                    }
                    .ignoresSafeArea()
            }
        }
        .luminareListFixedHeight(until: .infinity)
        .luminareBackground()
    }
}

// MARK: - Button Style (Tab Header)

struct TabHeaderButtonStyle: ButtonStyle {
    @Environment(\.luminareAnimationFast) private var animationFast

    @State var isHovering: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isHovering ? .primary : .secondary)
            .onHover { isHovering in
                withAnimation(animationFast) {
                    self.isHovering = isHovering
                }
            }
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
    .luminarePaneLayout(.form)
}
