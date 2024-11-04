//
//  NSTableView+Extensions.swift
//  
//
//  Created by KrLite on 2024/11/4.
//

import AppKit

extension NSTableView {
    override open func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
    }
}