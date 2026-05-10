//
//  LuminareModalPresentation.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public enum LuminareModalPresentationTarget: String, Equatable, Hashable,
    Identifiable, CaseIterable, Codable, Sendable {
    case screen
    case window

    public var id: Self { self }
}

public enum LuminareModalPresentationAlignment: String, Equatable, Hashable,
    Identifiable, CaseIterable, Codable, Sendable {
    case centered
    case origin

    public var id: Self { self }
}

public struct LuminareModalPresentation: Equatable, Hashable, Codable, Sendable {
    let target: LuminareModalPresentationTarget
    let alignment: LuminareModalPresentationAlignment
    let offset: CGPoint

    init(
        _ alignment: LuminareModalPresentationAlignment = .centered,
        offset: CGPoint = .zero,
        relativeTo target: LuminareModalPresentationTarget = .window
    ) {
        self.target = target
        self.alignment = alignment
        self.offset = offset
    }

    public static var windowCenter: Self { .init() }

    public static var screenCenter: Self { .init(relativeTo: .screen) }

    public func offset(_ offset: CGPoint) -> Self {
        .init(
            alignment,
            offset: .init(x: self.offset.x + offset.x, y: self.offset.y + offset.y),
            relativeTo: target
        )
    }

    public func offset(x: CGFloat, y: CGFloat) -> Self {
        offset(.init(x: x, y: y))
    }

    @MainActor
    func origin(of frame: CGRect) -> CGPoint {
        switch target {
        case .screen:
            guard let screenFrame = NSScreen.main?.frame else { return .zero }

            return switch alignment {
            case .centered:
                .init(
                    x: screenFrame.midX - frame.width / 2 + offset.x,
                    y: screenFrame.midY - frame.height / 2 + offset.y
                )
            case .origin:
                .init(
                    x: frame.origin.x + offset.x,
                    y: frame.origin.y + offset.y
                )
            }
        case .window:
            guard let window = NSApp.mainWindow else {
                return Self.screenCenter.origin(of: frame)
            }

            let windowFrame = window.frame

            return switch alignment {
            case .centered:
                .init(
                    x: windowFrame.midX - frame.width / 2 + offset.x,
                    y: windowFrame.midY - frame.height / 2 + offset.y
                )
            case .origin:
                .init(
                    x: windowFrame.origin.x + offset.x,
                    y: windowFrame.origin.y + offset.y
                )
            }
        }
    }
}
