//
//  LuminareModalStyle.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public enum LuminareModalStyle {
    case sheet
    case popover(
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil
    )

    public static var popover: Self {
        .popover()
    }
}
