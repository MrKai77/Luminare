//
//  VisualEffectView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

/// Source: https://oskargroth.com/blog/reverse-engineering-nsvisualeffectview
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let blurStyle: LuminareBackgroundBlurStyle

    init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        blurStyle: LuminareBackgroundBlurStyle = .regular
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.blurStyle = blurStyle
    }

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.isEmphasized = true
        applyCustomBlurIfNeeded(to: visualEffectView)
        return visualEffectView
    }

    func updateNSView(_ view: NSVisualEffectView, context _: Context) {
        view.material = material
        view.blendingMode = blendingMode
        applyCustomBlurIfNeeded(to: view)
    }

    private func applyCustomBlurIfNeeded(to view: NSVisualEffectView) {
        guard case let .custom(radius) = blurStyle else {
            return
        }

        view.wantsLayer = true

        DispatchQueue.main.async {
            guard let backdropLayer = backdropLayer(in: view) else {
                return
            }

            backdropLayer.setValue(radius, forKeyPath: "filters.gaussianBlur.inputRadius")
        }
    }

    private func backdropLayer(in view: NSView) -> CALayer? {
        if let layer = backdropLayer(in: view.layer) {
            return layer
        }

        for subview in view.subviews {
            if let layer = backdropLayer(in: subview) {
                return layer
            }
        }

        return nil
    }

    private func backdropLayer(in layer: CALayer?) -> CALayer? {
        guard let layer else {
            return nil
        }

        if String(describing: type(of: layer)).contains("Backdrop") {
            return layer
        }

        for sublayer in layer.sublayers ?? [] {
            if let backdropLayer = backdropLayer(in: sublayer) {
                return backdropLayer
            }
        }

        return nil
    }
}
