//
//  ColorizedProgressView.swift
//  SwiftUIColorizedControlExample
//
//  Edited by Kai Azim on 2024-04-14.
//

import SwiftUI

struct ColorizedToggleButton: NSViewRepresentable {

    @Binding private var value: Bool
    @Binding private var indicatorColor: NSColor

    init(isOn value: Binding<Bool>, color: Binding<NSColor>) {
        self._value = value
        self._indicatorColor = color
    }

    private func applyState(in view: NSSwitch) {
        view.state = self.value ? .on : .off
        view.controlSize = .small

        if let color = self.indicatorColor.usingColorSpace(.displayP3),
           let filter = CIFilter.colorCube(for: color) {
            view.contentFilters = [filter]
        }
    }

    func makeNSView(context: Context) -> NSSwitch {
        let view = NSSwitch()
        self.applyState(in: view)
        return view
    }

    func updateNSView(_ nsView: NSSwitch, context: Context) {
        self.applyState(in: nsView)
    }
}
