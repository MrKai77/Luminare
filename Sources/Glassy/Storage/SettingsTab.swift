//
//  SettingsTab.swift
//  
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct SettingsTab<Content>: Identifiable, Equatable {
    public static func == (lhs: SettingsTab<Content>, rhs: SettingsTab<Content>) -> Bool {
        rhs.id == lhs.id
    }

    public var id: UUID = UUID()
    
    public let title: String
    public let icon: Image
    public let view: () -> Content

    public init(_ title: String, _ icon: Image, @ViewBuilder _ view: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.view = view
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
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}
