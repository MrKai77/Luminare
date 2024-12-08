//
//  LuminareModalView.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public enum LuminareModalPresentationTarget: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case screen
    case window
    
    public var id: String { rawValue }
}

public enum LuminareModalPresentationAlignment: String, Equatable, Hashable, Identifiable, CaseIterable, Codable {
    case centered
    case origin
    
    public var id: String { rawValue }
}

public struct LuminareModalPresentation: Equatable, Hashable, Codable {
    var target: LuminareModalPresentationTarget
    var alignment: LuminareModalPresentationAlignment
    var offset: CGPoint
    
    init(
        _ alignment: LuminareModalPresentationAlignment = .centered,
        offset: CGPoint = .init(),
        relativeTo target: LuminareModalPresentationTarget = .window
    ) {
        self.target = target
        self.alignment = alignment
        self.offset = offset
    }
    
    public static var windowCenter: Self { .init() }
    
    public static var screenCenter: Self { .init(relativeTo: .screen) }
    
//    func origin(view: NSView) -> CGPoint {
//        let viewBounds = view.bounds
//        
//        switch target {
//        case .screen:
//            <#code#>
//        case .window:
//            guard let windowFrame = view.window?.frame else {
//                // fallback to screen center
//                return Self.screenCenter.origin(view: view)
//            }
//        }
//    }
}

struct LuminareModalView<Content>: View where Content: View {
    @EnvironmentObject private var floatingPanel: LuminareModal<Content>
    @Environment(\.luminareCornerRadius) private var cornerRadius

    @ViewBuilder private var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            content()
                .fixedSize()
                .background {
                    VisualEffectView(
                        material: .fullScreenUI,
                        blendingMode: .behindWindow
                    )
                }
                .clipShape(.rect(cornerRadius: cornerRadius))

                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size) { _ in
                                floatingPanel.updateShadow(for: 0.5)
                            }
                    }
                }
                .buttonStyle(.luminare)
                .ignoresSafeArea()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

private struct ModalContent: View {
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            Button("Toggle Expansion") {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .padding()
            .buttonStyle(.luminareCompact)
            
            if isExpanded {
                Text("Expanded Content")
                    .font(.title)
                    .padding()
            }
        }
    }
}

// preview as app
@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isPresented: Bool = false
    
    Button("Toggle Modal") {
        isPresented.toggle()
    }
    .luminareModal(isPresented: $isPresented) {
        ModalContent()
    }
    .frame(width: 500, height: 300)
}
