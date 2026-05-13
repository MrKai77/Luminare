//
//  LuminareForm.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-13.
//

import SwiftUI

public enum LuminareFormLayout: Equatable, Hashable, Codable, Sendable {
    case none
    @available(macOS 15.0, *)
    case form
    case stacked
}

public struct LuminareForm<Content>: View where Content: View {
    @Environment(\.luminareFormLayout) private var layout
    @Environment(\.luminareFormSpacing) private var spacing
    @Environment(\.luminareIsInsideModal) private var isInsideModal
    
    @ViewBuilder private var content: () -> Content
    
    @State private var luminareClickedOutside = false
    
    /// Initializes a ``LuminareForm``.
    ///
    /// - Parameters:
    ///   - content: the content view.
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }


    public var body: some View {
        Group {
            switch layout {
            case .none:
                content()
            case .form:
                if #available(macOS 15.0, *) {
                    Form {
                        content()
                    }
                    .formStyle(.luminare)
                    .clipped()
                }
            case let .stacked:
                AutoScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: spacing) {
                        content()
                    }
                    .padding(isInsideModal ? 16 : 12)
                    .background(content: clickedOutsideObserver)
                }
                .clipped()
            }
        }
        .environment(\.luminareClickedOutside, luminareClickedOutside)
        .background(content: clickedOutsideObserver)
    }
    
    
    private func clickedOutsideObserver() -> some View {
        Color.white.opacity(0.0001)
            .onTapGesture {
                luminareClickedOutside.toggle()
            }
            .ignoresSafeArea()
    }
}
