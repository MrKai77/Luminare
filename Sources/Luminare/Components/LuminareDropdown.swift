//
//  LuminareDropdown.swift
//  Luminare
//
//  Created by Kyan De Sutter on 23/6/24.
//

import SwiftUI

public struct LuminareDropdown<Content, V>: View where Content: View, V: Equatable {
    @Environment(\.tintColor) var tintColor
    let title: LocalizedStringKey
    
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 8
    
    let elements: [V]
    let rowsIndex: Int
    
    @Binding var selectedItem: V
    @State private var isExpanded: Bool = false
    
    let roundTop: Bool
    let roundBottom: Bool
    let content: (V) -> Content
    
    public init(
        elements: [V],
        selection: Binding<V>,
        roundTop: Bool = true,
        roundBottom: Bool = true,
        title: LocalizedStringKey,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements = elements
        self.rowsIndex = elements.count - 1
        self.roundTop = roundTop
        self.roundBottom = roundBottom
        self.content = content
        self.title = title
        
        self._selectedItem = selection
    }
    
    var isCompact: Bool {
        rowsIndex == 0
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title) // Displaying the title
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        content(selectedItem)
                            .foregroundColor(.primary) // Ensure text color is primary
                        
                        Image(systemName: "chevron.down") // Chevron icon
                            .rotationEffect(.degrees(isExpanded ? 180 : 0)) // Rotate if expanded
                            .foregroundColor(tintColor()) // Chevron color
                    }
                    .padding(10) // Adjust padding as needed
                }
                .buttonStyle(
                    LuminareDropdownStyle()
                ) // Use PlainButtonStyle to avoid default button styles
            }
            .padding(.leading, horizontalPadding)
            .frame(minHeight: elementMinHeight)
        }
        //.overlay(
        //VStack {
        if isExpanded {
            VStack(spacing: 2) { // Use VStack to display dropdown items
                ForEach(0...rowsIndex, id: \.self) { i in
                    if let element = getElement(i: i) {
                        Button {
                            guard !isDisabled(element) else { return }
                            selectedItem = element
                            withAnimation {
                                isExpanded = false
                            }
                        } label: {
                            ZStack {
                                let isActive = selectedItem == element
                                getShape(isActive: isActive, index: i)
                                    .foregroundStyle(isActive ? tintColor().opacity(0.15) : .clear)
                                    .overlay {
                                        getShape(isActive: isActive, index: i)
                                            .strokeBorder(
                                                tintColor(),
                                                lineWidth: isActive ? 1.5 : 0
                                            )
                                    }
                                
                                content(element)
                                    .foregroundStyle(isDisabled(element) ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(8)
                            }
                        }
                    } else {
                        getShape(isActive: false, index: i)
                            .strokeBorder(.quaternary, lineWidth: 1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .transition(.move(edge: .top))
            
            //.shadow(radius: 4) // Shadow to give floating effect
            //.padding(.top, (elementMinHeight + horizontalPadding)+15) // Space between the button and dropdown
            //}
        }
        //.offset(y: elementMinHeight + horizontalPadding) // Position dropdown below the button
        // )
    }
    
    func getShape(isActive: Bool, index: Int) -> some InsettableShape {
        if index == 0 && !isExpanded, roundTop { // Top, and not expanded
            return UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: isActive ? innerCornerRadius : cornerRadius - innerPadding,
                bottomTrailingRadius: isActive ? innerCornerRadius : cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if index == rowsIndex, roundBottom { // Bottom
            return UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: roundBottom ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: roundBottom ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        } else { // Middle
            return UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
    }
    
    func isDisabled(_ element: V) -> Bool {
        (element as? LuminarePickerData)?.selectable == false
    }
    
    func getElement(i: Int) -> V? {
        guard i < elements.count else { return nil }
        return elements[i]
    }
}

public struct LuminareDropdownStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundForState(isPressed: configuration.isPressed))
            .onHover { hover in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hover
                }
            }
            .animation(.easeOut(duration: 0.1), value: isHovering)
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }

    private func backgroundForState(isPressed: Bool) -> some View {
        Group {
            if isPressed, isEnabled {
                Rectangle().foregroundStyle(.quaternary)
            } else if isHovering, isEnabled {
                Rectangle().foregroundStyle(.quaternary.opacity(0.7))
            } else {
                Rectangle().foregroundStyle(.quinary)
            }
        }
    }
}
