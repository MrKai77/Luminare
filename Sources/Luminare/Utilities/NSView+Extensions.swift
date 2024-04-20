//
//  NSView+Extensions.swift
//  SwiftUIColorizedControlExample
//
//  Edited by Kai Azim on 2024-04-14.
//

import SwiftUI
//
//extension NSView {
//    @objc func xxx_updateLayer() {
//        // This calls the original implementation so all other NSWidgetViews will have the right look
//        self.xxx_updateLayer()
//
//        guard self.window?.identifier == LuminareSettingsWindow.identifier else {
//            return
//        }
//
//        let tintColor = LuminareSettingsWindow.tint
//
//        guard
//            let dictionary = self.value(forKey: "widgetDefinition") as? [String: Any],
//            let widget = dictionary["widget"] as? String,
//            let value = (dictionary["value"] as? NSNumber)?.intValue
//        else {
//            return
//        }
//
//        // If we're specifically dealing with this case, change the colors and remove the contents which are set in the enabled switch case
//        if widget == "kCUIWidgetSwitchFill" {
//            layer?.contents = nil;
//            if value == 0 {
//                layer?.backgroundColor = NSColor.clear.cgColor
//            } else {
//                layer?.backgroundColor = NSColor(tintColor).cgColor
//            }
//        }
//    }
//}
