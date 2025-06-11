//
//  LuminareSlider.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public enum LuminareSliderLayout: Equatable, Hashable, Identifiable, Codable, Sendable {
    case regular
    case compact(textBoxWidth: CGFloat? = nil)

    public var id: Self { self }
}

public extension LuminareSliderLayout {
    static var compact: Self { .compact() }
}

// MARK: - Slider (Compose)

public struct LuminareSlider<Label, Content, V, F>: View
    where Label: View, Content: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint,
    F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
    private enum FocusedField {
        case textbox
    }

    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareSliderLayout) private var layout

    @FocusState private var focusedField: FocusedField?

    // MARK: Fields

    @Binding private var value: V
    @State private var lastValue: V
    private let range: ClosedRange<V>, step: V.Stride?
    private let format: F
    private let clampsUpper: Bool, clampsLower: Bool

    @ViewBuilder private var content: (AnyView) -> Content, label: () -> Label

    @State private var isTextBoxVisible: Bool = false
    @State private var isSliderHovering: Bool = false
    @State private var isSliderDebouncedHovering: Bool = false
    @State private var isSliderEditing: Bool = false

    private let id = UUID()

    // MARK: Initializers

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.lastValue = value.wrappedValue
        self.range = range
        self.step = step
        self.format = format
        self.clampsUpper = clampsUpper
        self.clampsLower = clampsLower

        self.content = content
        self.label = label
    }

    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            content: content
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            content: content
        ) {
            Text(titleKey)
        }
    }

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower
        ) { view in
            HStack(spacing: 0) {
                if let prefix {
                    prefix
                        .fontDesign(.monospaced)
                }

                view

                if let suffix {
                    suffix
                        .fontDesign(.monospaced)
                }
            }
        } label: {
            label()
        }
    }

    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix
        ) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        VStack {
            switch layout {
            case .regular:
                LuminareCompose(alignment: .top) {
                    textBoxView()
                        .fixedSize()
                } label: {
                    label()
                }
                .luminareComposeStyle(.inline)

                sliderView()
                    .padding(.horizontal, horizontalPadding)
            case let .compact(textBoxWidth):
                if let textBoxWidth {
                    LuminareCompose {
                        sliderView()

                        textBoxView()
                            .frame(width: textBoxWidth)
                    } label: {
                        label()
                    }
                    .luminareComposeStyle(.inline)
                } else {
                    let isAlternativeTextBoxVisible = isSliderDebouncedHovering || isSliderEditing

                    LuminareCompose {
                        sliderView()

                        if !isAlternativeTextBoxVisible {
                            textBoxView()
                                .fixedSize()
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    } label: {
                        if isAlternativeTextBoxVisible {
                            textBoxView()
                                .fixedSize()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            label()
                        }
                    }
                    .luminareComposeStyle(isAlternativeTextBoxVisible ? .regular : .inline)
                }
            }
        }
        .animation(animation, value: value)
        .animation(animation, value: isTextBoxVisible)
        .animation(animation, value: isSliderHovering)
        .animation(animation, value: isSliderDebouncedHovering)
        .animation(animation, value: isSliderEditing)
        .booleanThrottleDebounced(isSliderHovering) { debouncedValue in
            isSliderDebouncedHovering = debouncedValue
        }
    }

    private var totalRange: V {
        range.upperBound - range.lowerBound
    }

    private var countsDown: Bool {
        value > lastValue
    }

    @ViewBuilder private func sliderView() -> some View {
        let binding: Binding<V> = .init {
            value
        } set: { newValue in
            value = newValue
            isTextBoxVisible = false
        }

        Group {
            if let step {
                Slider(
                    value: binding,
                    in: range,
                    step: step
                ) { isEditing in
                    isSliderEditing = isEditing
                }
            } else {
                Slider(
                    value: binding,
                    in: range
                ) { isEditing in
                    isSliderEditing = isEditing
                }
            }
        }
        .onHover { isHovering in
            isSliderHovering = isHovering
        }
    }

    @ViewBuilder private func textBoxView() -> some View {
        HStack {
            let view = Group {
                if isTextBoxVisible {
                    let binding: Binding<V> = Binding {
                        value
                    } set: { newValue in
                        if clampsLower, clampsUpper {
                            value = newValue.clamped(to: range)
                        } else if clampsLower {
                            value = max(range.lowerBound, newValue)
                        } else if clampsUpper {
                            value = min(range.upperBound, newValue)
                        } else {
                            value = newValue
                        }
                    }

                    TextField(
                        value: binding,
                        format: format
                    ) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .onSubmit {
                        withAnimation(animationFast) {
                            isTextBoxVisible.toggle()
                        }
                    }
                    .focused($focusedField, equals: .textbox)
                    .multilineTextAlignment(.trailing)
                    .padding(.leading, -4)
                    .fontDesign(.monospaced)
                } else {
                    Button {
                        withAnimation(animationFast) {
                            isTextBoxVisible.toggle()
                            focusedField = .textbox
                        }
                    } label: {
                        Text(format.format(value))
                            .contentTransition(.numericText(countsDown: countsDown))
                            .multilineTextAlignment(.trailing)
                            .fontDesign(.monospaced)
                    }
                    .buttonStyle(.plain)
                }
            }

            content(.init(view))
        }
        .frame(maxWidth: .infinity)
        .padding(4)
        .padding(.horizontal, 4)
        .background {
            Capsule()
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .background {
            if isTextBoxVisible {
                Capsule()
                    .foregroundStyle(.quinary)
            } else {
                Capsule()
                    .foregroundStyle(.quinary.opacity(0.5))
            }
        }
        .clipShape(.capsule)
        .onChange(of: isTextBoxVisible) { _ in
            if isTextBoxVisible {
                addEventMonitor()
            } else {
                removeEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
        .opacity(isEnabled ? 1 : 0.5)
        .onChange(of: value) { value in
            DispatchQueue.main.async {
                lastValue = value
            }
        }
    }

    // MARK: Functions

    func addEventMonitor() {
        EventMonitorManager.shared.addLocalMonitor(
            for: id,
            matching: .keyDown
        ) { event in
            let downArrow: CGKeyCode = 0x7D
            let upArrow: CGKeyCode = 0x7E

            guard event.keyCode == downArrow || event.keyCode == upArrow else {
                return event
            }

            let isShiftDown = event.modifierFlags.contains(.shift) // x10
            let isOptionDown = event.modifierFlags.contains(.option) // x0.1
            let acceleration: V = if isShiftDown, isOptionDown {
                1
            } else if isShiftDown {
                10
            } else if isOptionDown {
                0.1
            } else {
                1
            }
            let step = V(step ?? 1)

            if event.keyCode == upArrow {
                value += step * acceleration
            }

            if event.keyCode == downArrow {
                value -= step * acceleration
            }

            if clampsLower, clampsUpper {
                value = value.clamped(to: range)
            } else if clampsLower {
                value = max(range.lowerBound, value)
            } else if clampsUpper {
                value = min(range.upperBound, value)
            } else {
                value = value
            }

            return nil
        }
    }

    func removeEventMonitor() {
        EventMonitorManager.shared.removeMonitor(for: id)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSlider",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var value: Double = 42

    LuminareSection {
        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            VStack(alignment: .leading) {
                Text("Slide to stride")

                Text("Composed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .luminareSliderLayout(.regular)

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            VStack(alignment: .leading) {
                Text("Slide to stride")

                Text("Composed, Compact")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        LuminareSlider(
            "2 Decimal Places",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100))

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            Text("With an info")
                .luminarePopover(attachedTo: .topTrailing) {
                    Text("Incididunt Lorem pariatur eiusmod laboris laboris.")
                        .padding()
                }
        }
    }
}
