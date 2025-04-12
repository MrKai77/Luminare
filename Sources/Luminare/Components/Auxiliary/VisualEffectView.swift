//
//  VisualEffectView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State = .followsWindowActiveState
    var isEmphasized: Bool = true

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = state
        visualEffectView.isEmphasized = isEmphasized
        return visualEffectView
    }

    func updateNSView(_: NSVisualEffectView, context _: Context) {}
}
