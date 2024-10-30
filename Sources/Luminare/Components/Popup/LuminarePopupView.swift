//
//  LuminarePopupView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public struct LuminarePopupView<Content: View>: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    @Binding private var isPresented: Bool
    
    @ViewBuilder private let content: () -> Content

    public init(
        material: NSVisualEffectView.Material = .popover,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.material = material
        self._isPresented = isPresented
        self.content = content
    }

    public func makeNSView(context _: Context) -> NSView {
        .init()
    }
    
    // !!! referencing `isPresented` in this function is necessary for triggering view update
    public func updateNSView(_ nsView: NSView, context: Context) {
        let _ = isPresented
        DispatchQueue.main.async {
            context.coordinator.setVisible(isPresented, in: nsView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, content: content)
    }

    @MainActor
    public class Coordinator: NSObject, NSWindowDelegate {
        private let view: LuminarePopupView
        private var content: () -> Content
        private var originalYPoint: CGFloat?
        var popover: LuminarePopupPanel?
        
        private var monitor: Any?

        init(_ parent: LuminarePopupView, content: @escaping () -> Content) {
            self.view = parent
            self.content = content
            super.init()
        }

        // view is optional bevause it is not needed to close the popup
        func setVisible(_ isPresented: Bool, in view: NSView? = nil) {
            // if we're going to be closing the window
            guard isPresented else {
                popover?.close()
                return
            }
            
            guard let view else { return }
            
            guard popover == nil else { return }
            
            initializePopup()
            guard let popover else { return }
            
            // popover size
            let targetSize = NSSize(width: 300, height: 300)
            let extraPadding: CGFloat = 10
            
            // get coordinates to place popopver
            guard let windowFrame = view.window?.frame else { return }
            let viewBounds = view.bounds
            var targetPoint = view.convert(viewBounds, to: nil).origin // convert to window coordinates
            originalYPoint = targetPoint.y
            
            // correct popover position
            targetPoint.y += windowFrame.minY
            targetPoint.x += windowFrame.minX
            targetPoint.y -= targetSize.height + extraPadding
            
            // set position and show popover
            popover.setContentSize(targetSize)
            popover.setFrameOrigin(targetPoint)
            popover.makeKeyAndOrderFront(nil)
            
            if monitor == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.monitor = NSEvent.addLocalMonitorForEvents(matching: [
                        .scrollWheel, .leftMouseDown, .rightMouseDown, .otherMouseDown
                    ]) { [weak self] event in
                        if event.window != self?.popover {
                            self?.setVisible(false)
                        }
                        return event
                    }
                }
            }
        }

        public func windowWillClose(_: Notification) {
            Task { @MainActor in
                removeMonitor()
                view.isPresented = false
                self.popover = nil
            }
        }

        func initializePopup() {
            self.popover = .init()
            guard let popover else { return }

            popover.delegate = self
            popover.contentViewController = NSHostingController(
                rootView: content()
                    .background(VisualEffectView(material: view.material, blendingMode: .behindWindow))
                    .overlay {
                        UnevenRoundedRectangle(
                            topLeadingRadius: LuminarePopupPanel.cornerRadius,
                            bottomLeadingRadius: LuminarePopupPanel.cornerRadius,
                            bottomTrailingRadius: LuminarePopupPanel.cornerRadius,
                            topTrailingRadius: LuminarePopupPanel.cornerRadius
                        )
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: LuminarePopupPanel.cornerRadius,
                            bottomLeadingRadius: LuminarePopupPanel.cornerRadius,
                            bottomTrailingRadius: LuminarePopupPanel.cornerRadius,
                            topTrailingRadius: LuminarePopupPanel.cornerRadius
                        )
                    )
                    .ignoresSafeArea()
                    .environmentObject(popover)
            )
        }

        func removeMonitor() {
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
                monitor = nil
            }
        }
    }
}

public extension View {
    @ViewBuilder func luminarePopup(
        material: NSVisualEffectView.Material = .popover,
        isPresented: Binding<Bool>
    ) -> some View {
        LuminarePopupView(
            material: material,
            isPresented: isPresented
        ) {
            self
        }
    }
}

private struct PopupPreview<Label, Content>: View where Label: View, Content: View {
    @State var isPresented: Bool = false
    
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            label()
        }
        .background {
            Color.clear
                .background {
                    LuminarePopupView(isPresented: $isPresented) {
                        content()
                    }
                }
        }
    }
}

// preview as app
#Preview {
    PopupPreview {
        Text("Test")
            .padding()
            .frame(width: 75, height: 175)
    } label: {
        Text("Toggle Popup")
            .padding()
    }
    .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
    .padding()
}
