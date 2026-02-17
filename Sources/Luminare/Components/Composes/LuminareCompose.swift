//
//  LuminareCompose.swift
//  Luminare
//
//  Created by KrLite on 2024/10/25.
//

import SwiftUI

public enum LuminareComposeControlSize: String, Equatable, Hashable, Identifiable, CaseIterable, Codable, Sendable {
    case automatic
    @available(macOS 14.0, *)
    case extraLarge
    case large
    case regular
    case small
    case mini

    public static var allCases: [LuminareComposeControlSize] {
        if #available(macOS 14.0, *) {
            [.automatic, .extraLarge, .large, .regular, .small, .mini]
        } else {
            [.automatic, .large, .regular, .small, .mini]
        }
    }

    public var id: Self { self }

    public var proposal: ControlSize? {
        if #available(macOS 14.0, *) {
            switch self {
            case .extraLarge: .extraLarge
            case .large: .large
            case .regular: .regular
            case .small: .small
            case .mini: .mini
            default: nil
            }
        } else {
            switch self {
            case .large: .large
            case .regular: .regular
            case .small: .small
            case .mini: .mini
            default: nil
            }
        }
    }
}

// MARK: - Compose

/// A stylized view that composes a content with a label.
public struct LuminareCompose<Label, Content>: View
    where Label: View, Content: View {
    // MARK: Environments

    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareSectionHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareComposeControlSize) private var controlSize

    // MARK: Fields

    private let alignment: VerticalAlignment
    private let spacing: CGFloat?

    @State private var ignoreSafeAreaEdgesKey: Edge.Set?
    @ViewBuilder private var content: () -> Content, label: () -> Label

    // MARK: Initializers

    /// Initializes a ``LuminareCompose``.
    ///
    /// - Parameters:
    ///   - alignment: the vertical alignment of the elements.
    ///   - spacing: the spacing between the label and the content.
    ///   - content: the content.
    ///   - label: the label.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.label = label
        self.content = content
    }

    /// Initializes a ``LuminareCompose`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - title: the label text.
    ///   - alignment: the vertical alignment of the elements.
    ///   - spacing: the spacing between the label and the content.
    ///   - content: the content.
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(
            alignment: alignment,
            spacing: spacing,
            content: content
        ) {
            Text(title)
        }
    }

    /// Initializes a ``LuminareCompose`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - titleKey: the `LocalizedStringKey` to look up the label text.
    ///   - alignment: the vertical alignment of the elements.
    ///   - spacing: the spacing between the label and the content.
    ///   - content: the content.
    public init(
        _ titleKey: LocalizedStringKey,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(
            alignment: alignment,
            spacing: spacing,
            content: content
        ) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            if Label.self != EmptyView.self {
                HStack(alignment: alignment, spacing: spacing) {
                    label()
                }
                .layoutPriority(1)
                .padding(labelInsets)

                Spacer()
            } else {
                Spacer(minLength: 0)
            }

            wrappedContent()
        }
        .readPreference(
            LuminareComposeIgnoreSafeAreaEdgesKey.self,
            to: $ignoreSafeAreaEdgesKey
        )
        .padding(enclosingInsets)
        .frame(maxWidth: .infinity, minHeight: minHeight)
    }

    private var enclosingInsets: EdgeInsets {
        .init(
            top: 0,
            leading: ignoreSafeAreaEdgesKey?.contains(.leading) == true ? 0 : horizontalPadding,
            bottom: 0,
            trailing: ignoreSafeAreaEdgesKey?.contains(.trailing) == true ? 0 : horizontalPadding
        )
    }

    private var labelInsets: EdgeInsets {
        .init(
            top: ignoreSafeAreaEdgesKey?.contains(.top) == true ? 0 : horizontalPadding / 2,
            leading: 0,
            bottom: ignoreSafeAreaEdgesKey?.contains(.bottom) == true ? 0 : horizontalPadding / 2,
            trailing: 0
        )
    }

    private func wrappedContent() -> some View {
        content()
            .controlSize(controlSize.proposal ?? .regular)
    }
}

// MARK: - Preference Key

struct LuminareComposeIgnoreSafeAreaEdgesKey: PreferenceKey {
    typealias Value = Edge.Set?
    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareCompose",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareCompose("Label") {
            Button {} label: {
                Text("Button")
            }
        }

        LuminareCompose("Label") {
            Button {} label: {
                Text("Button")
            }
        }
        .disabled(true)
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareCompose (Constrained)",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareCompose("Label") {
            Text("Normal Content")
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(.red)
        }

        LuminareCompose("Culpa nisi sint reprehenderit sit.") {
            Text("Ignores safe area insets")
                .ignoresSafeArea()
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(.red)
        }

        LuminareCompose("Eu duis ipsum cupidatat tempor nisi aliquip et sint ea reprehenderit Lorem ad dolor sint.") {
            Text("A very wide content")
                .frame(width: 200, height: 30)
                .background(.red)
        }
    }
    .frame(width: 400)
}
