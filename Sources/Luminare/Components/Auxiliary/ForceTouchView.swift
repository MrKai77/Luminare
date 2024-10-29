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
    @Binding private var state: GestureState
    @Binding private var pressure: CGFloat
    
    @ViewBuilder private let content: () -> Content
    
    public init(
        configuration: NSPressureConfiguration = .init(pressureBehavior: .primaryDefault),
        threshold: CGFloat = 0.5,
        state: Binding<GestureState>,
        pressure: Binding<CGFloat>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.configuration = configuration
        self.threshold = threshold
        self._state = state
        self._pressure = pressure
        self.content = content
    }
    
    public func makeNSView(context: Context) -> NSView {
        var view = NSHostingView(rootView: content())
        let gesture = ForceTouchGestureRecognizer(
            configuration,
            threshold: threshold
        ) { state in
            self.state = state
        } onPressureChange: { pressure in
            self.pressure = pressure
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
    private let onPressureChange: (CGFloat) -> ()
    
    init(
        _ configuration: NSPressureConfiguration,
        threshold: CGFloat,
        onStateChange: @escaping (NSPressGestureRecognizer.State) -> (),
        onPressureChange: @escaping (CGFloat) -> ()
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
        onPressureChange(CGFloat(event.pressure))
    }
}

private struct ForceTouchPreview<Content: View>: View {
    let threshold: CGFloat = 0.5
    @State var state: ForceTouchView.GestureState = .ended
    @State var pressure: CGFloat = 0
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ForceTouchView(threshold: threshold, state: $state, pressure: $pressure, content: content)
            .onChange(of: state) { state in
                print(state)
            }
            .onChange(of: pressure) { pressure in
                print(pressure)
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
