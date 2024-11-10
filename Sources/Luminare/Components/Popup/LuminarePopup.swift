//
//  LuminarePopup.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

// MARK: - Popup

public struct LuminarePopup<Content: View>: NSViewRepresentable {
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    
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
        _ = isPresented
        DispatchQueue.main.async {
            context.coordinator.setVisible(isPresented, in: nsView)
        }
    }

    public func makeCoordinator() -> Coordinator<some View> {
        Coordinator(self) {
            content()
                .environment(\.luminareAnimation, animation)
                .environment(\.luminareAnimationFast, animationFast)
                .overrideTint(tint)
        }
    }

    // MARK: - Coordinator

    @MainActor
    public class Coordinator<InnerContent>: NSObject, NSWindowDelegate where InnerContent: View {
        private let view: LuminarePopup
        private var content: () -> InnerContent
        private var originalYPoint: CGFloat?
        var panel: LuminarePopupPanel?

        private var monitor: Any?

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

            guard panel == nil else { return }

            initializePopup()
            guard let panel else { return }

            // panel size
            let targetSize = NSSize(width: 300, height: 300)
            let extraPadding: CGFloat = 10

            // get coordinates to place popopver
            guard let windowFrame = view.window?.frame else { return }
            let viewBounds = view.bounds
            var targetPoint = view.convert(viewBounds, to: nil).origin // convert to window coordinates
            originalYPoint = targetPoint.y

            // correct panel position
            targetPoint.y += windowFrame.minY
            targetPoint.x += windowFrame.minX
            targetPoint.y -= targetSize.height + extraPadding

            // set position and show panel
            panel.setContentSize(targetSize)
            panel.setFrameOrigin(targetPoint)
            panel.makeKeyAndOrderFront(nil)

            if monitor == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.monitor = NSEvent.addLocalMonitorForEvents(matching: [
                        .scrollWheel, .leftMouseDown, .rightMouseDown, .otherMouseDown
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
                removeMonitor()
                view.isPresented = false
                self.panel = nil
            }
        }

        func initializePopup() {
            self.panel = .init()
            guard let panel else { return }

            panel.delegate = self
            panel.contentViewController = NSHostingController(
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
                    .environmentObject(panel)
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

// MARK: - Preview

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
                    LuminarePopup(isPresented: $isPresented) {
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
