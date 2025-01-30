//
//  LuminareTextEditor.swift
//  Luminare
//
//  Created by KrLite on 2024/12/18.
//

import SwiftUI

// MARK: - Text Editor

public struct LuminareTextEditor: View {
    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.font) private var font
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding

    // MARK: Fields

    @Binding private var text: String
    @Binding private var selection: Any? // Handle os versions below macOS 15.0

    @State private var isHovering: Bool = false
    @State private var containerSize: CGSize = .zero

    // MARK: Initializers

    public init(
        text: Binding<String>
    ) {
        self._text = text
        self._selection = .constant(nil)
    }

    @available(macOS 15.0, *)
    public init(
        text: Binding<String>,
        selection: Binding<TextSelection?>
    ) {
        self._text = text
        self._selection = Binding {
            selection.wrappedValue
        } set: { newValue in
            if let newValue = newValue as? TextSelection? {
                selection.wrappedValue = newValue
            } else {
                selection.wrappedValue = nil
            }
        }
    }

    // MARK: Body

    public var body: some View {
        ScrollView {
            Group {
                if #available(macOS 15.0, *) {
                    TextEditor(text: $text, selection: strongTypedSelection)
                        .textEditorStyle(.plain)
                } else if #available(macOS 14.0, *) {
                    TextEditor(text: $text)
                        .textEditorStyle(.plain)
                } else {
                    TextEditor(text: $text)
                }
            }
            .scrollDisabled(true)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 14)
            .frame(minHeight: max(minHeight, containerSize.height))
        }
        .scrollContentBackground(.hidden)
        .font(font ?? .body)
        .modifier(LuminareHoverable())
        .luminareAspectRatio(unapplying: true)
        .luminareHorizontalPadding(0)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            containerSize = newValue
        }
    }

    @available(macOS 15.0, *)
    private var strongTypedSelection: Binding<TextSelection?> {
        Binding {
            if let value = selection as? TextSelection? {
                value
            } else {
                nil
            }
        } set: { newValue in
            selection = newValue
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareTextEditor",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var text = ""
    @Previewable @State var selection: TextSelection? = .none

    LuminareTextEditor(text: $text)

//    LuminareTextEditor(text: $text, selection: $selection)
//
//    LuminareTextEditor(text: $text, selection: $selection)
//        .disabled(true)
}
