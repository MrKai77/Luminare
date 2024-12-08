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
        offset: CGPoint = .zero,
        relativeTo target: LuminareModalPresentationTarget = .window
    ) {
        self.target = target
        self.alignment = alignment
        self.offset = offset
    }

    public static var windowCenter: Self { .init() }

    public static var screenCenter: Self { .init(relativeTo: .screen) }
    
    public func offset(_ offset: CGPoint) -> Self {
        .init(
            alignment,
            offset: .init(x: self.offset.x + offset.x, y: self.offset.y + offset.y),
            relativeTo: target
        )
    }
    
    public func offset(x: CGFloat, y: CGFloat) -> Self {
        offset(.init(x: x, y: y))
    }

    func origin(of frame: CGRect) -> CGPoint {
        switch target {
        case .screen:
            guard let screenFrame = NSScreen.main?.frame else { return .zero }

            return switch alignment {
            case .centered:
                .init(
                    x: screenFrame.midX - frame.width / 2 + offset.x,
                    y: screenFrame.midY - frame.height / 2 + offset.y)
            case .origin:
                .init(
                    x: frame.origin.x + offset.x,
                    y: frame.origin.y + offset.y)
            }
        case .window:
            guard let window = NSApp.mainWindow else {
                // fallback to screen center
                return Self.screenCenter.origin(of: frame)
            }

            let windowFrame = window.frame
            
            return switch alignment {
            case .centered:
                .init(
                    x: windowFrame.midX - frame.width / 2 + offset.x,
                    y: windowFrame.midY - frame.height / 2 + offset.y)
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

    @ViewBuilder private var content: () -> Content

    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
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
            maxWidth: .infinity, maxHeight: .infinity, alignment: .top
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
    @Previewable @State var isPresented1: Bool = false
    @Previewable @State var isPresented2: Bool = false
    
    @Previewable @State var offsetX: Double = .zero
    @Previewable @State var offsetY: Double = .zero
    
    VStack {
        Spacer()
        
        HStack {
            TextField("Offset X", value: $offsetX, format: .number)
            
            TextField("Offset Y", value: $offsetY, format: .number)
            
            Button("Reset") {
                offsetX = .zero
                offsetY = .zero
            }
        }
        
        HStack {
            Button("Toggle Modal (Screen Center)") {
                isPresented1.toggle()
            }
            .luminareModal(isPresented: $isPresented1) {
                ModalContent()
                    .frame(width: 400)
            }
            .luminareModalPresentation(.screenCenter.offset(x: CGFloat(offsetX), y: CGFloat(offsetY)))
            
            Button("Toggle Modal (Window Center)") {
                isPresented2.toggle()
            }
            .luminareModal(isPresented: $isPresented2) {
                ModalContent()
                    .frame(width: 400)
            }
            .luminareModalPresentation(.windowCenter.offset(x: CGFloat(offsetX), y: CGFloat(offsetY)))
        }
    }
    .padding()
    .frame(width: 500, height: 300)
}
