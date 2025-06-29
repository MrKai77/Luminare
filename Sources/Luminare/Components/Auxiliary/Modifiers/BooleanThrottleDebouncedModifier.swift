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

    @State private var timerTask: Task<(), Never>? = nil

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
                flip(to: newValue)
            }
            .onChange(of: debouncedValue) { newValue in
                action(newValue)
            }
    }

    private func flip(to newValue: Bool) {
        if newValue ? debouncedValue : !debouncedValue {
            // Cancels the flip off action when the delay is not met
            timerTask?.cancel()
            timerTask = nil
        } else if timerTask == nil {
            if flipOnDelay > .zero {
                timerTask = Task {
                    try? await Task.sleep(for: .seconds(newValue ? flipOnDelay : flipOffDelay))
                    guard !Task.isCancelled else { return }

                    debouncedValue = newValue
                    timerTask?.cancel()
                    timerTask = nil

                    if throttleDelay > .zero {
                        // In case immediately receives a flip signal
                        timerTask = Task {
                            try? await Task.sleep(for: .seconds(throttleDelay))
                            guard !Task.isCancelled else { return }

                            debouncedValue = updatedValue
                            timerTask?.cancel()
                            timerTask = nil
                        }
                    }
                }
            } else {
                debouncedValue = newValue
                timerTask?.cancel()
                timerTask = nil
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
        .booleanThrottleDebounced(
            isHovering,
            flipOnDelay: 0.5,
            flipOffDelay: 0.5,
            throttleDelay: 2.0
        ) {
            debouncedIsHovering = $0
        }
        .colorMultiply(debouncedIsHovering ? Color.red : Color.blue)
        .overlay {
            Text(debouncedIsHovering ? "Hovering" : "Not Hovering")
        }
}
