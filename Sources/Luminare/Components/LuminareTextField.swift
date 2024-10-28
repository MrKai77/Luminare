//
//  LuminareTextField.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public struct LuminareTextField<F>: View
where F: ParseableFormatStyle, F.FormatOutput == String {
    @Environment(\.luminareAnimationFast) private var animationFast
    
    private let elementMinHeight: CGFloat
    private let horizontalPadding: CGFloat
    private let cornerRadius: CGFloat
    private let borderless: Bool
    
    @Binding private var value: F.FormatInput?
    private let format: F
    private let placeholder: LocalizedStringKey

    @State private var monitor: Any?
    @State private var isHovering: Bool = false

    public init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        borderless: Bool = true
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.borderless = borderless
        self._value = value
        self.format = format
        self.placeholder = placeholder
    }

    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        borderless: Bool = true
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: .init(text), format: StringFormatStyle(),
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            borderless: borderless
        )
    }

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: elementMinHeight)
            .textFieldStyle(.plain)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .background {
                if isHovering {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.quaternary, lineWidth: 1)
                } else if borderless {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.clear, lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.quaternary.opacity(0.7), lineWidth: 1)
                }
            }
            .background {
                if isHovering {
                    Rectangle()
                        .foregroundStyle(.quinary)
                } else {
                    Rectangle()
                        .foregroundStyle(.clear)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onAppear {
                guard monitor != nil else { return }

                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window.animationBehavior == .documentWindow {
                        window.keyDown(with: event)

                        // fixes cmd+w to close window.
                        let wKey = 13
                        if event.keyCode == wKey, event.modifierFlags.contains(.command) {
                            return nil
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }
                monitor = nil
            }
    }
}

#Preview {
    LuminareSection {
        LuminareTextField("Text Field", text: .constant("Borderless"))
        
        LuminareTextField("Text Field", text: .constant("Bordererd"), borderless: false)
    }
    .padding()
}
