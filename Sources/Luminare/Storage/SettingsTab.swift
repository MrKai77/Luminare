//
//  SettingsTab.swift
//  
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct SettingsTab: Identifiable, Equatable {
    public static func == (lhs: SettingsTab, rhs: SettingsTab) -> Bool {
        rhs.id == lhs.id
    }

    public var id: UUID = UUID()
    
    public let title: LocalizedStringKey
    public let icon: Image
    @ViewBuilder public let view: AnyView

    public init<Content: View>(_ title: LocalizedStringKey, _ icon: Image, _ view: Content) {
        self.title = title
        self.icon = icon
        self.view = AnyView(view)
    }

    @ViewBuilder func iconView() -> some View {
        Rectangle()
            .opacity(0)
            .overlay {
                self.icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
            .fixedSize()
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}
