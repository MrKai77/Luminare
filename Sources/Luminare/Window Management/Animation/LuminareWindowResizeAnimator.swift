//
//  LuminareWindowResizeAnimator.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-09.
//

import SwiftUI

final class LuminareWindowResizeAnimator: NSObject {
    private struct SpringState {
        var position: CGFloat
        var velocity: CGFloat = 0
        var target: CGFloat
    }

    private let responseDuration: TimeInterval

    var onUpdate: ((CGSize) -> Void)?

    var hasNoTarget: Bool {
        widthState == nil || heightState == nil
    }

    private var widthState: SpringState?
    private var heightState: SpringState?
    private var timer: Timer?
    private var lastTimestamp: TimeInterval?

    private let positionThreshold: CGFloat = 0.5
    private let velocityThreshold: CGFloat = 3

    private var angularFrequency: CGFloat {
        4 / responseDuration
    }

    init(
        responseDuration: TimeInterval = 0.14
    ) {
        self.responseDuration = responseDuration
        super.init()
    }

    func snap(to size: CGSize) {
        widthState = .init(position: size.width, target: size.width)
        heightState = .init(position: size.height, target: size.height)
        stop()
    }

    func animate(to size: CGSize) {
        if widthState == nil || heightState == nil {
            snap(to: size)
            onUpdate?(size)
            return
        }

        retarget(&widthState, to: size.width)
        retarget(&heightState, to: size.height)
        startIfNeeded()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastTimestamp = nil
    }

    private func startIfNeeded() {
        guard timer == nil else {
            return
        }

        let timer = Timer(
            timeInterval: 1 / 120,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc
    private func timerFired() {
        tick()
    }

    private func tick() {
        guard var widthState, var heightState else {
            stop()
            return
        }

        let timestamp = ProcessInfo.processInfo.systemUptime
        let deltaTime = min(max(timestamp - (lastTimestamp ?? timestamp), 1 / 240), 1 / 30)
        lastTimestamp = timestamp

        step(&widthState, deltaTime: deltaTime)
        step(&heightState, deltaTime: deltaTime)

        self.widthState = widthState
        self.heightState = heightState

        let size = CGSize(
            width: widthState.position,
            height: heightState.position
        )
        onUpdate?(size)

        if isSettled(widthState), isSettled(heightState) {
            snap(to: CGSize(width: widthState.target, height: heightState.target))
            onUpdate?(CGSize(width: widthState.target, height: heightState.target))
        }
    }

    private func step(_ state: inout SpringState, deltaTime: TimeInterval) {
        let omega = angularFrequency
        let displacement = state.position - state.target
        let coefficient = state.velocity + displacement * omega
        let decay = exp(-omega * deltaTime)

        state.position = state.target + (displacement + coefficient * deltaTime) * decay
        state.velocity = (state.velocity - coefficient * omega * deltaTime) * decay
    }

    private func retarget(_ state: inout SpringState?, to target: CGFloat) {
        guard var currentState = state else {
            return
        }

        let newDisplacement = target - currentState.position
        if newDisplacement * currentState.velocity < 0 {
            currentState.velocity = 0
        }

        currentState.target = target
        state = currentState
    }

    private func isSettled(_ state: SpringState) -> Bool {
        abs(state.target - state.position) <= positionThreshold
            && abs(state.velocity) <= velocityThreshold
    }
}
