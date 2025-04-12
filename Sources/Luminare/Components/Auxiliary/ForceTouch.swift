//
//  ForceTouch.swift
//  Luminare
//
//  Created by KrLite on 2024/10/29.
//

import AppKit
import SwiftUI

/// The gesture state of a ``ForceTouch``.
public enum ForceTouchGesture: Equatable {
    /// An inactive gesture.
    case inactive
    /// An active gesture with a ``Event``.
    case active(Event)

    /// The event context of a ``ForceTouchGesture``.
    public struct Event: Equatable {
        public var state: NSPressGestureRecognizer.State
        public var stage: Int
        public var stageTransition: CGFloat
        public var pressure: CGFloat
        public var pressureBehavior: NSEvent.PressureBehavior
        public var modifierFlags: NSEvent.ModifierFlags

        public init(
            state: NSPressGestureRecognizer.State,
            stage: Int,
            stageTransition: CGFloat,
            pressure: CGFloat,
            pressureBehavior: NSEvent.PressureBehavior,
            modifierFlags: NSEvent.ModifierFlags
        ) {
            self.state = state
            self.stage = stage
            self.stageTransition = stageTransition
            self.pressure = pressure
            self.pressureBehavior = pressureBehavior
            self.modifierFlags = modifierFlags
        }

        public init(_ state: NSPressGestureRecognizer.State, event: NSEvent) {
            self.init(
                state: state,
                stage: event.stage,
                stageTransition: event.stageTransition,
                pressure: CGFloat(event.pressure),
                pressureBehavior: event.pressureBehavior,
                modifierFlags: event.modifierFlags
            )
        }

        public init() {
            self.init(
                state: .ended,
                stage: 0,
                stageTransition: 0.0,
                pressure: 0.0,
                pressureBehavior: .primaryDefault,
                modifierFlags: []
            )
        }
    }
}

// MARK: - Force Touch

/// A force touch recognizer.
///
/// On devices with force touch trackpads (e.g., MacBook Pros), this view can be regularly triggered by force touch
/// gestures.
/// As an alternative for devices without force touch support, this view can also be triggered through long press
/// gestures.
///
/// However, the delegation of long press can automatically happen after failing to receive a force touch event after
/// a delay of **`threshold + 0.1` seconds,** even on devices that support force touch.
///
/// While long pressing, the ``ForceTouchGesture/Event/pressure`` will be increased by `0.1` every `0.1`
/// seconds, and the ``ForceTouchGesture/Event/stage`` will be increased by `1` every time the
/// ``ForceTouchGesture/Event/pressure`` overflows.
public struct ForceTouch<Content>: NSViewRepresentable where Content: View {
    private let configuration: NSPressureConfiguration
    private let threshold: CGFloat
    @Binding private var gesture: ForceTouchGesture

    @ViewBuilder private var content: () -> Content

    @State private var timestamp: Date?
    @State private var state: NSPressGestureRecognizer.State = .ended

    @State private var longPressTimer: Timer?

    private let id = UUID()

    /// Initializes a ``ForceTouch``.
    ///
    /// - Parameters:
    ///   - configuration: the `NSPressureConfiguration` that configures the force touch behavior.
    ///   - threshold: the minimum threshold before emitting the first gesture event.
    ///   As force touch gestures have many stages, this only applies to the first stage.
    ///   - gesture: the binding for the emitted ``ForceTouchGesture``.
    ///   This binding is get-only.
    ///   - content: the content to be force touched.
    public init(
        configuration: NSPressureConfiguration = .init(pressureBehavior: .primaryDefault),
        threshold: CGFloat = 0.5,
        gesture: Binding<ForceTouchGesture>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.configuration = configuration
        self.threshold = threshold
        self._gesture = gesture
        self.content = content
    }

    public func makeNSView(context _: Context) -> NSView {
        let view = NSHostingView(
            rootView: content()
        )
        view.translatesAutoresizingMaskIntoConstraints = false

        let recognizer = ForceTouchGestureRecognizer(
            configuration
        ) { state in
            self.state = state

            switch state {
            case .began:
                timestamp = .now
            case .ended, .cancelled, .failed:
                timestamp = nil
                gesture = .inactive
            default:
                break
            }
        } onPressureChange: { event in
            terminateLongPressDelegate()

            let isValid = event.stage > 0
            let isFirstStage = event.stage == 1
            let isOverThreshold = CGFloat(event.pressure) >= threshold

            gesture = if isValid, !isFirstStage || isOverThreshold {
                .active(ForceTouchGesture.Event(state, event: event))
            } else {
                .inactive
            }
        }

        EventMonitorManager.shared.addLocalMonitor(
            for: id,
            matching: [
                .leftMouseDown,
                .leftMouseUp,
                .mouseMoved,
                .mouseExited
            ]
        ) { event in
            let locationInView = view.convert(event.locationInWindow, from: nil)
            guard view.bounds.contains(locationInView) else { return event }

            switch event.type {
            case .leftMouseDown:
                prepareLongPressDelegate(event)
            case .leftMouseUp, .mouseMoved, .mouseExited:
                terminateLongPressDelegate()
                timestamp = nil
                gesture = .inactive
            default:
                break
            }
            return event
        }

        recognizer.allowedTouchTypes = .direct // Enables pressure-sensitive events
        view.addGestureRecognizer(recognizer)
        return view
    }

    public func updateNSView(_: NSView, context _: Context) {}

    private func prepareLongPressDelegate(_ event: NSEvent) {
        let modifierFlags = event.modifierFlags
        var event = ForceTouchGesture.Event()
        event.modifierFlags = modifierFlags

        longPressTimer = .scheduledTimer(withTimeInterval: threshold + 0.1, repeats: false) { _ in
            timestamp = .now
            event.stage = 1

            longPressTimer = .scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let pressure = event.pressure + 0.1
                let isOverflowing = pressure > 1

                event.pressure = pressure.truncatingRemainder(dividingBy: 1)
                if isOverflowing {
                    event.stage += 1
                }

                gesture = .active(event)
            }
        }
    }

    private func terminateLongPressDelegate() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}

// MARK: - Force Touch Gesture Recognizer

class ForceTouchGestureRecognizer: NSPressGestureRecognizer {
    private let onStateChange: (NSPressGestureRecognizer.State) -> ()
    private let onPressureChange: (NSEvent) -> ()

    init(
        _ configuration: NSPressureConfiguration,
        onStateChange: @escaping (NSPressGestureRecognizer.State) -> (),
        onPressureChange: @escaping (NSEvent) -> ()
    ) {
        self.onStateChange = onStateChange
        self.onPressureChange = onPressureChange

        super.init(target: nil, action: nil)
        self.pressureConfiguration = configuration
        self.target = self
        self.action = #selector(handlePressureChange)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handlePressureChange(_ gesture: NSPressGestureRecognizer) {
        onStateChange(gesture.state)
    }

    override func pressureChange(with event: NSEvent) {
        onPressureChange(event)
    }
}

// MARK: - Preview

private struct ForceTouchPreview<Content>: View where Content: View {
    let threshold: CGFloat = 0.5
    @State var gesture: ForceTouchGesture = .inactive
    @ViewBuilder let content: () -> Content

    var body: some View {
        ForceTouch(threshold: threshold, gesture: $gesture, content: content)
            .onChange(of: gesture) { gesture in
                print(gesture)
            }
            .background {
                switch gesture {
                case .inactive:
                    Color.clear
                case let .active(event):
                    Color.red.opacity(event.pressure)
                }
            }
    }
}

#Preview {
    ForceTouchPreview {
        Text("Touch me!")
            .padding()
    }
}
