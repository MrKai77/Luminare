//
//  ForceTouch.swift
//
//
//  Created by KrLite on 2024/10/29.
//

import SwiftUI
import AppKit

public enum ForceTouchGesture: Equatable {
    case inactive
    case active(Event)
    
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

// MARK: - Force Touxh

public struct ForceTouch<Content>: NSViewRepresentable where Content: View {
    private let configuration: NSPressureConfiguration
    private let threshold: CGFloat
    @Binding private var gesture: ForceTouchGesture
    
    @ViewBuilder private let content: () -> Content
    
    @State private var timestamp: Date?
    @State private var state: NSPressGestureRecognizer.State = .ended
    
    @State private var longPressTimer: Timer?
    @State private var monitor: Any?
    
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
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSHostingView(
            rootView: content()
        )
        view.translatesAutoresizingMaskIntoConstraints = false

        let recognizer = ForceTouchGestureRecognizer(
            configuration,
            threshold: threshold
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
            gesture = .active(ForceTouchGesture.Event(state, event: event))
        }
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .mouseMoved, .mouseExited]) { event in
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
        
        recognizer.allowedTouchTypes = .direct // enable pressure-sensitive events
        view.addGestureRecognizer(recognizer)
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {}
    
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
    private let threshold: CGFloat
    private let onStateChange: (NSPressGestureRecognizer.State) -> ()
    private let onPressureChange: (NSEvent) -> ()
    
    init(
        _ configuration: NSPressureConfiguration,
        threshold: CGFloat,
        onStateChange: @escaping (NSPressGestureRecognizer.State) -> (),
        onPressureChange: @escaping (NSEvent) -> ()
    ) {
        self.threshold = threshold
        self.onStateChange = onStateChange
        self.onPressureChange = onPressureChange
        
        super.init(target: nil, action: nil)
        self.pressureConfiguration = configuration
        self.target = self
        self.action = #selector(handlePressureChange)
    }
    
    required init?(coder: NSCoder) {
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
                case .active(let event):
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
