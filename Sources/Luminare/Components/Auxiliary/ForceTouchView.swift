//
//  ForceTouchView.swift
//
//
//  Created by KrLite on 2024/10/29.
//

import SwiftUI
import AppKit

public struct ForceTouchView<Content: View>: NSViewRepresentable {
    public typealias GestureState = NSPressGestureRecognizer.State
    
    private let configuration: NSPressureConfiguration
    private let threshold: CGFloat
    private let onPressureChange: (NSEvent) -> ()
    @Binding private var state: GestureState
    
    @ViewBuilder private let content: () -> Content
    
    public init(
        configuration: NSPressureConfiguration = .init(pressureBehavior: .primaryDefault),
        threshold: CGFloat = 0.5,
        state: Binding<GestureState>,
        @ViewBuilder content: @escaping () -> Content,
        onPressureChange: @escaping (NSEvent) -> ()
    ) {
        self.configuration = configuration
        self.threshold = threshold
        self.onPressureChange = onPressureChange
        self._state = state
        self.content = content
    }
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSHostingView(rootView: content())
        view.translatesAutoresizingMaskIntoConstraints = false

        let gesture = ForceTouchGestureRecognizer(
            configuration,
            threshold: threshold
        ) { state in
            self.state = state
        } onPressureChange: { event in
            self.onPressureChange(event)
        }
        
        gesture.allowedTouchTypes = .direct // enable pressure-sensitive events
        view.addGestureRecognizer(gesture)
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
    }
}

class ForceTouchGestureRecognizer: NSPressGestureRecognizer {
    private let threshold: CGFloat
    private let onStateChange: (NSPressGestureRecognizer.State) -> ()
    private let onPressureChange: (NSEvent) -> ()
    
    init(
        _ configuration: NSPressureConfiguration,
        threshold: CGFloat,
        onStateChange: @escaping (NSPressGestureRecognizer.State) -> (),
        onPressureChange: @escaping (NSEvent) -> ()
    ) {
        self.threshold = threshold
        self.onStateChange = onStateChange
        self.onPressureChange = onPressureChange
        
        super.init(target: nil, action: nil)
        self.pressureConfiguration = configuration
        self.target = self
        self.action = #selector(handlePressureChange)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handlePressureChange(_ gesture: NSPressGestureRecognizer) {
        onStateChange(gesture.state)
    }
    
    override func pressureChange(with event: NSEvent) {
        onPressureChange(event)
    }
}

private struct ForceTouchPreview<Content: View>: View {
    let threshold: CGFloat = 0.5
    @State var state: ForceTouchView.GestureState = .ended
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ForceTouchView(threshold: threshold, state: $state, content: content) { event in
            print(event)
        }
    }
}

#Preview {
    ForceTouchPreview {
        Text("Touch me!")
            .padding()
            .background(.red)
    }
}
