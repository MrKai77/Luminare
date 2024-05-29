//
//  VisualEffectView.swift
//  
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }

    // This change reduces memory by about 10mb in some cases, pretty nice
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        if visualEffectView.material != material {
            visualEffectView.material = material
        }
        if visualEffectView.blendingMode != blendingMode {
            visualEffectView.blendingMode = blendingMode
        }
    }
}
