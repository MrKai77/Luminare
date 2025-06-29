//
//  LuminareWindowAnimator.swift
//  Luminare
//
//  Created by Kai Azim on 2025-06-28.
//

import AppKit

@MainActor
class LuminareWindowAnimator {
    private(set) var task: Task<(), any Error>?
    private var startTime: CFTimeInterval = 0
    private var duration: TimeInterval = 0.5
    private var curve: (Double) -> Double = { $0 }
    private var targetFrame: NSRect = .zero
    private var startFrame: NSRect = .zero
    private weak var window: NSWindow?

    init(window: NSWindow) {
        self.window = window
    }

    func animate(
        to targetFrame: NSRect,
        duration: TimeInterval = 0.5,
        curve: @escaping (Double) -> Double = { $0 } // linear by default
    ) {
        task?.cancel() // cancel previous animation

        guard let window else { return }

        self.targetFrame = targetFrame
        self.duration = duration
        self.curve = curve
        startFrame = window.frame
        startTime = CACurrentMediaTime()

        let fpsInterval = 1.0 / 60.0

        task = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let now = CACurrentMediaTime()
                let elapsed = now - startTime
                let progress = min(elapsed / self.duration, 1)
                let eased = self.curve(progress)

                let currentFrame = NSRect(
                    x: startFrame.origin.x + (self.targetFrame.origin.x - startFrame.origin.x) * eased,
                    y: startFrame.origin.y + (self.targetFrame.origin.y - startFrame.origin.y) * eased,
                    width: startFrame.width + (self.targetFrame.width - startFrame.width) * eased,
                    height: startFrame.height + (self.targetFrame.height - startFrame.height) * eased
                )

                self.window?.setFrame(currentFrame, display: false)

                if progress >= 1 {
                    break
                }

                try await Task.sleep(nanoseconds: UInt64(fpsInterval * 1_000_000_000))
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
