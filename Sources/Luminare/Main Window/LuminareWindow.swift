//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: NSWindow {
    private lazy var trafficLightButtons: [NSButton] = [
        .closeButton,
        .miniaturizeButton,
        .zoomButton
    ].compactMap { type in
        standardWindowButton(type)
    }

    private var trafficLightsOrigin: CGPoint? = .init(x: 18.5, y: 18.5)

    /// Initializes a ``LuminareWindow``.
    ///
    /// - Parameters:
    ///   - content: the content view of the window, wrapped in a ``LuminareView``.
    public init(content: @escaping () -> some View) {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )

        // Wrapping the NSHostingView in a parent NSView allows us to reposition the traffic lights, since NSHostingViews cannot have subviews directly.
        let view = NSView()
        let luminareView = NSHostingView(rootView: LuminareView(content: content))
        view.addSubview(luminareView)

        luminareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            luminareView.topAnchor.constraint(equalTo: view.topAnchor),
            luminareView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            luminareView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            luminareView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        contentView = view
        titlebarAppearsTransparent = true
        layoutIfNeeded()
        center()
    }

    // MARK: Overrides & window customization

    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
        relocateTrafficLights()
    }

    @objc dynamic var _cornerRadius: CGFloat {
        if #available(macOS 26, *) {
            24
        } else {
            12
        }
    }

    func relocateTrafficLights() {
        guard let contentView, let trafficLightsOrigin else {
            return
        }

        relocateTrafficLightButtons(trafficLightsOrigin: trafficLightsOrigin)
        refreshTrafficLightTrackingAreas()
    }

    private func relocateTrafficLightButtons(trafficLightsOrigin: CGPoint) {
        guard let contentView else {
            return
        }

        let buttonAreaWidth = (trafficLightButtons.last?.frame.minX ?? 0) - (trafficLightButtons.first?.frame.minX ?? 0)
        let buttonSpacingX = buttonAreaWidth / CGFloat(trafficLightButtons.count - 1)

        for (index, button) in trafficLightButtons.enumerated() {
            if button.superview != contentView {
                button.removeFromSuperview()
                contentView.addSubview(button)

                let xPosition: CGFloat = if windowTitlebarLayoutDirection == .leftToRight {
                    trafficLightsOrigin.x + CGFloat(index) * buttonSpacingX
                } else {
                    trafficLightsOrigin.x + (buttonAreaWidth - CGFloat(index) * buttonSpacingX)
                }

                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: trafficLightsOrigin.y),
                    button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition)
                ])
            }
        }
    }

    // Reference: https://github.com/Automattic/simplenote-macos/blob/7b1d6d736e337ec99fb8f3c5e2ab973040b2ac9b/Simplenote/Window.swift#L148
    private func refreshTrafficLightTrackingAreas() {
        guard let themeView = contentView?.superview else {
            return
        }

        themeView.viewWillStartLiveResize()
        themeView.viewDidEndLiveResize()
    }

    override public var canBecomeKey: Bool {
        true
    }

    override public var canBecomeMain: Bool {
        true
    }
}
