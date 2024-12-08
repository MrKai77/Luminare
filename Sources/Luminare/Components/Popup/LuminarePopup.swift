//
//  LuminarePopup.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

// MARK: - Popup

public struct LuminarePopup<Content>: NSViewRepresentable where Content: View {
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    private let material: NSVisualEffectView.Material
    @Binding private var isPresented: Bool

    @ViewBuilder private var content: () -> Content

    public init(
        material: NSVisualEffectView.Material = .popover,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.material = material
        self._isPresented = isPresented
        self.content = content
    }

    public func makeNSView(context: Context) -> NSView {
        .init()
    }

    // !!! referencing `isPresented` in this function is necessary for triggering view update
    public func updateNSView(_ nsView: NSView, context: Context) {
        _ = isPresented
        DispatchQueue.main.async {
            context.coordinator.setVisible(isPresented, in: nsView)
        }
    }

    public func makeCoordinator() -> Coordinator<some View> {
        Coordinator(self) {
            content()
                .overrideTint(tint)
        }
    }

    // MARK: - Coordinator

    @MainActor
    public class Coordinator<InnerContent>: NSObject, NSWindowDelegate
    where InnerContent: View {
        private let view: LuminarePopup
        private var content: () -> InnerContent
        var panel: LuminarePopupPanel?

        private weak var window: NSWindow?
        private var dismissMonitor: Any?

        init(_ parent: LuminarePopup, content: @escaping () -> InnerContent) {
            self.view = parent
            self.content = content
            super.init()
        }

        // view is optional bevause it is not needed to close the popup
        func setVisible(_ isPresented: Bool, in view: NSView? = nil) {
            // if we're going to be closing the window
            guard isPresented else {
                panel?.close()
                return
            }

            guard let view else { return }
            window = view.window
            
            guard panel == nil else { return }

            initializePopup()
            guard let panel else { return }
            
            updatePosition(for: view.frame.size)
            panel.makeKeyAndOrderFront(nil)

            if dismissMonitor == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.dismissMonitor = NSEvent.addLocalMonitorForEvents(matching: [
                        .scrollWheel, .leftMouseDown, .rightMouseDown,
                        .otherMouseDown,
                    ]) { [weak self] event in
                        if event.window != self?.panel {
                            self?.setVisible(false)
                        }
                        return event
                    }
                }
            }
        }

        public func windowWillClose(_: Notification) {
            Task { @MainActor in
                if dismissMonitor != nil {
                    NSEvent.removeMonitor(dismissMonitor!)
                    dismissMonitor = nil
                }
                
                view.isPresented = false
                self.panel = nil
            }
        }

        private func initializePopup() {
            self.panel = .init()
            guard let panel else { return }

            panel.delegate = self
            
            let view = NSHostingView(
                rootView: Group {
                    content()
                        .fixedSize()
                        .background {
                            VisualEffectView(
                                material: self.view.material,
                                blendingMode: .behindWindow
                            )
                        }
                        .clipShape(.rect(cornerRadius: LuminarePopupPanel.cornerRadius))
                    
                        .buttonStyle(.luminare)
                        .ignoresSafeArea()
                        .environmentObject(panel)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            )
            panel.contentView = view
            
            view.postsFrameChangedNotifications = true
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(Coordinator.frameDidChange(_:)),
                name: NSView.frameDidChangeNotification,
                object: view
            )
        }
        
        private func updatePosition(for size: CGSize) {
            guard let panel, let window else { return }
            let windowFrame = window.frame
            let origin = NSPoint(x: windowFrame.midX - size.width / 2, y: windowFrame.midY - size.height / 2)
            
            panel.setFrameOrigin(origin)
        }
        
        @objc func frameDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSView else { return }
            updatePosition(for: view.frame.size)
        }
    }
}

// MARK: - Preview

private struct PopupContent: View {
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
            } else {
                
                Text("Normal Content")
                    .padding()
            }
        }
    }
}

// preview as app
@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isPresented: Bool = false
    
    Button("Toggle Popup") {
        isPresented.toggle()
    }
    .background {
        LuminarePopup(isPresented: $isPresented) {
            PopupContent()
        }
    }
    .padding()
    .frame(width: 500, height: 300)
}
