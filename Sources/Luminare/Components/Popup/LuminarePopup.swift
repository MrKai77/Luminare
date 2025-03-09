//
//  LuminarePopup.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

// MARK: - Popup

public struct LuminarePopup<Content>: NSViewRepresentable where Content: View {
    @Environment(\.luminarePopupCornerRadii) private var cornerRadii
    @Environment(\.luminarePopupPadding) private var padding
    @Environment(\.luminareSheetClosesOnDefocus) private var sheetClosesOnDefocus

    @Binding private var isPresented: Bool
    private let alignment: Alignment
    private let material: NSVisualEffectView.Material

    @ViewBuilder private var content: () -> Content

    public init(
        isPresented: Binding<Bool>,
        alignment: Alignment = .bottom,
        material: NSVisualEffectView.Material = .popover,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.alignment = alignment
        self.material = material
        self.content = content
    }

    public func makeNSView(context _: Context) -> NSView {
        .init()
    }

    // !!! Referencing `isPresented` in this function is necessary for triggering view update
    public func updateNSView(_ nsView: NSView, context: Context) {
        _ = isPresented
        DispatchQueue.main.async {
            context.coordinator.setVisible(isPresented, relativeTo: nsView)
        }
    }

    public func makeCoordinator() -> Coordinator<some View> {
        Coordinator(self) {
            content()
        }
    }

    // MARK: - Coordinator

    @MainActor
    public class Coordinator<InnerContent>: NSObject, NSWindowDelegate
        where InnerContent: View {
        private let parent: LuminarePopup
        private var content: () -> InnerContent
        var panel: LuminarePopupPanel?

        private weak var parentView: NSView?

        private let id = UUID()

        init(_ parent: LuminarePopup, content: @escaping () -> InnerContent) {
            self.parent = parent
            self.content = content
            super.init()
        }

        // View is optional bevause it is not needed to close the popup
        func setVisible(
            _ isPresented: Bool, relativeTo parentView: NSView? = nil
        ) {
            // If we're going to be closing the window
            guard isPresented else {
                panel?.close()
                return
            }

            self.parentView = parentView
            guard panel == nil else { return }

            initializePopup()
            guard let panel else { return }

            panel.makeKeyAndOrderFront(nil)

            EventMonitorManager.shared.addLocalMonitor(
                for: id,
                matching: [
                    .scrollWheel,
                    .leftMouseDown,
                    .rightMouseDown,
                    .otherMouseDown
                ]
            ) { [weak self] event in
                guard let self else { return event }
                if event.window != self.panel {
                    setVisible(false)
                }
                return event
            }
        }

        public func windowWillClose(_: Notification) {
            Task { @MainActor in
                EventMonitorManager.shared.removeMonitor(for: id)

                parent.isPresented = false
                panel = nil
            }
        }

        private func initializePopup() {
            self.panel = .init(
                closesOnDefocus: parent.sheetClosesOnDefocus
            )
            guard let panel else { return }

            panel.delegate = self

            let view = NSHostingView(
                rootView: VStack {
                    ZStack {
                        backgroundWindow()
                        content()
                        windowBorder()
                    }
                    .buttonStyle(.luminare)
                    .environmentObject(panel)
                    .fixedSize()
                    .onGeometryChange(for: CGSize.self, of: \.size, action: panel.setSize(_:))
                    .frame(minWidth: 12, minHeight: 12, alignment: .top)

                    Spacer(minLength: 0)
                }
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: parent.alignment.negate
                )
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

        func backgroundWindow() -> some View {
            VisualEffectView(
                material: parent.material,
                blendingMode: .behindWindow,
                state: .active
            )
            .clipShape(.rect(cornerRadii: parent.cornerRadii))
        }

        func windowBorder() -> some View {
            ZStack {
                UnevenRoundedRectangle(cornerRadii: parent.cornerRadii)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)

                UnevenRoundedRectangle(cornerRadii: parent.cornerRadii)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .mask(alignment: .top) {
                        LinearGradient(
                            colors: [
                                .white,
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 30)
                    }
            }
        }

        private func updatePosition(for size: CGSize) {
            guard let panel, let parentView else { return }
            guard let window = parentView.window else { return }

            let windowFrame = window.frame
            let parentSize = parentView.frame.size
            let parentOrigin = parentView.convert(
                parentView.frame.origin, to: nil
            )
            let globalFrame = CGRect(
                origin: .init(
                    x: windowFrame.origin.x + parentOrigin.x,
                    y: windowFrame.origin.y + parentOrigin.y
                ),
                size: parentSize
            )

            let origin: CGPoint =
                switch parent.alignment {
                case .top:
                    .init(
                        x: globalFrame.midX - size.width / 2,
                        y: globalFrame.maxY + parent.padding
                    )
                case .leading:
                    .init(
                        x: globalFrame.minX - size.width - parent.padding,
                        y: globalFrame.midY - size.height / 2
                    )
                case .bottom:
                    .init(
                        x: globalFrame.midX - size.width / 2,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                case .trailing:
                    .init(
                        x: globalFrame.maxX + parent.padding,
                        y: globalFrame.midY - size.height / 2
                    )
                case .topLeading:
                    .init(
                        x: globalFrame.minX - size.width - parent.padding,
                        y: globalFrame.maxY + parent.padding
                    )
                case .topTrailing:
                    .init(
                        x: globalFrame.maxX + parent.padding,
                        y: globalFrame.maxY + parent.padding
                    )
                case .leadingLastTextBaseline:
                    .init(
                        x: globalFrame.minX,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                case .bottomLeading:
                    .init(
                        x: globalFrame.minX - size.width - parent.padding,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                case .trailingLastTextBaseline:
                    .init(
                        x: globalFrame.maxX - size.width,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                case .bottomTrailing:
                    .init(
                        x: globalFrame.maxX + parent.padding,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                case .center:
                    .init(
                        x: globalFrame.midX - size.width / 2,
                        y: globalFrame.midY - size.height / 2
                    )
                default: // Same as leadingLastTextBaseline
                    .init(
                        x: globalFrame.minX,
                        y: globalFrame.minY - size.height - parent.padding
                    )
                }

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
                withAnimation(.smooth(duration: 0.2)) {
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

// Preview as app
@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isPresented = false

    Button("Toggle Popup") {
        isPresented.toggle()
    }
    .luminarePopup(isPresented: $isPresented, edge: .leading) {
        PopupContent()
    }
    .padding()
    .frame(width: 500, height: 300)
}
