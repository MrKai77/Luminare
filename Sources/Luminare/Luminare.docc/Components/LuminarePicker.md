# ``Luminare/LuminarePicker``

@Row {
    @Column {
        A picker that differs from the native SwiftUI `Picker`.
        It displays selectable values in a grid with appearances that thoroughly conforms to ``Luminare``'s design language.
        
        However, due to layout limitations, you must explicitly provide a sequence of seletable values to choose from.
        
        ```swift
        LuminarePicker(
            elements: [...],
            selection: $selection
        ) { element in
            // Content
        }
        ```
        
        Elements can conform to ``LuminareSelectionData`` for more precise controls on selection behaviors.
    }
    
    @Column {
        ![LuminarePicker](LuminarePicker)
    }
}
