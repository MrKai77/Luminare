//
//  SettingsTabGroup.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct SettingsTabGroup: Identifiable {
    public var id: UUID = UUID()

    public let title: String?
    public let tabs: [SettingsTab]

    public init(_ title: String, _ tabs: [SettingsTab]) {
        self.title = title
        self.tabs = tabs
    }

    public init(_ tabs: [SettingsTab]) {
        self.title = nil
        self.tabs = tabs
    }
}
