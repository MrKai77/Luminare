//
//  LuminareModalView.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public enum LuminareModalPresentationTarget: String, Equatable, Hashable,
    Identifiable, CaseIterable, Codable
{
    case screen
    case window

    public var id: String { rawValue }
}

public enum LuminareModalPresentationAlignment: String, Equatable, Hashable,
    Identifiable, CaseIterable, Codable
{
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

    func origin(of view: NSView, for size: CGSize) -> CGPoint {
        let viewOrigin = view.convert(view.frame.origin, to: nil)
        let globalFrame = CGRect(origin: viewOrigin, size: size)

        switch target {
        case .screen:
            guard let screenFrame = NSScreen.main?.frame else { return .zero }

            return switch alignment {
            case .centered:
                .init(
                    x: screenFrame.midX - globalFrame.width / 2 + offset.x,
                    y: screenFrame.origin.y - globalFrame.height / 2 + offset.y)
            case .origin:
                .init(
                    x: globalFrame.origin.x + offset.x,
                    y: globalFrame.origin.y + offset.y)
            }
        case .window:
            guard let window = NSApp.mainWindow else {
                // fallback to screen center
                return Self.screenCenter.origin(of: view, for: size)
            }

            let windowFrame = window.frame
            
            return switch alignment {
            case .centered:
                .init(
                    x: windowFrame.midX - globalFrame.width / 2 + offset.x,
                    y: windowFrame.midY - globalFrame.height / 2 + offset.y)
            case .origin:
                .init(
                    x: windowFrame.origin.x + offset.x,
                    y: windowFrame.origin.y + offset.y)
            }
        }
    }
}

// MARK: - Modal View

struct LuminareModalView<Content>: View where Content: View {
    @EnvironmentObject private var floatingPanel: LuminareModalWindow<Content>

    @Environment(\.luminareModalCornerRadius) private var cornerRadius

    private let edge: Edge
    @ViewBuilder private var content: () -> Content

    init(
        edge: Edge = .top,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.edge = edge
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
        .frame(
            maxWidth: .infinity, maxHeight: .infinity, alignment: edge.alignment
        )
    }
}

// MARK: - Modal Modifier

struct LuminareModalModifier<ModalContent>: ViewModifier
where ModalContent: View {
    @Environment(\.luminareModalPresentation) private var presentation

    @State private var panel: LuminareModalWindow<ModalContent>?

    @Binding var isPresented: Bool
    var isMovableByWindowBackground: Bool = false
    var closesOnDefocus: Bool = false
    @ViewBuilder var content: () -> ModalContent

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    present()
                } else {
                    close()
                }
            }
            .onDisappear {
                isPresented = false
                close()
            }
    }

    private func present() {
        guard panel == nil else { return }
        panel = LuminareModalWindow(
            isPresented: $isPresented,
            isMovableByWindowBackground: isMovableByWindowBackground,
            closesOnDefocus: closesOnDefocus,
            presentation: presentation,
            content: content
        )

        DispatchQueue.main.async {
            panel?.orderFrontRegardless()
            panel?.makeKey()
        }
    }

    private func close() {
        panel?.close()
        panel = nil
    }
}

// MARK: - Preview

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
    
    VStack {
        Spacer()
        
        Button("Toggle Modal") {
            isPresented.toggle()
        }
        .luminareModal(isPresented: $isPresented) {
            ModalContent()
        }
    }
    .padding()
    .frame(width: 500, height: 300)
}
