//
//  BooleanThrottleDebouncedModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/5/3.
//

import SwiftUI

public struct BooleanThrottleDebouncedModifier: ViewModifier {
    private let value: Bool
    private let flipOnDelay: TimeInterval
    private let flipOffDelay: TimeInterval
    private let throttleDelay: TimeInterval
    private let initial: Bool
    private let action: (Bool) -> ()

    @State private var updatedValue: Bool // IMPORTANT: refer to this instead of `value`
    @State private var debouncedValue: Bool

    @State private var timer: Timer?

    public init(
        _ value: Bool,
        flipOnDelay: TimeInterval = 0.5,
        flipOffDelay: TimeInterval = .zero,
        throttleDelay: TimeInterval = 0.25,
        initial: Bool = false,
        action: @escaping (Bool) -> ()
    ) {
        self.value = value
        self.updatedValue = value
        self.debouncedValue = value
        self.flipOnDelay = flipOnDelay
        self.flipOffDelay = flipOffDelay
        self.throttleDelay = throttleDelay
        self.initial = initial
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                if initial {
                    action(debouncedValue)
                }
            }
            .onChange(of: value) { newValue in
                updatedValue = newValue
                if newValue {
                    flipOn()
                } else {
                    flipOff()
                }
            }
            .onChange(of: debouncedValue) { newValue in
                action(newValue)
            }
    }

    private func flipOn() {
        if debouncedValue {
            // Cancels the flip off action when the delay is not met
            timer?.invalidate()
            timer = nil
        } else if timer == nil {
            if flipOnDelay > .zero {
                // Schedules to flip on
                timer = .scheduledTimer(withTimeInterval: flipOnDelay, repeats: false) { _ in
                    debouncedValue = true
                    timer?.invalidate()

                    if throttleDelay > .zero {
                        // In case immediately receives a flip off signal
                        timer = .scheduledTimer(withTimeInterval: throttleDelay, repeats: false) { _ in
                            debouncedValue = updatedValue
                            timer?.invalidate()
                            timer = nil
                        }
                    } else {
                        timer = nil
                    }
                }
            } else {
                debouncedValue = true
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func flipOff() {
        if !debouncedValue {
            // Cancels the flip on when the delay is not met
            timer?.invalidate()
            timer = nil
        } else if timer == nil {
            if flipOffDelay > .zero {
                // Schedules to flip off
                timer = .scheduledTimer(withTimeInterval: flipOffDelay, repeats: false) { _ in
                    debouncedValue = false
                    timer?.invalidate()

                    if throttleDelay > .zero {
                        // In case immediately receives a flip on signal
                        timer = .scheduledTimer(withTimeInterval: throttleDelay, repeats: false) { _ in
                            debouncedValue = updatedValue
                            timer?.invalidate()
                            timer = nil
                        }
                    } else {
                        timer = nil
                    }
                }
            } else {
                debouncedValue = false
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isHovering = false
    @Previewable @State var debouncedIsHovering = false

    Color.white
        .onHover { isHovering = $0 }
        .booleanThrottleDebounced(isHovering, flipOnDelay: 0.5, flipOffDelay: 0.5, throttleDelay: 2) {
            debouncedIsHovering = $0
        }
        .colorMultiply(debouncedIsHovering ? Color.red : Color.blue)
}
