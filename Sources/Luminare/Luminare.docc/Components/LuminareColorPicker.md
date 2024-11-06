# ``Luminare/LuminareColorPicker``

@Row {
    @Column {
        A simple color picker designed to match the Luminare design system.
        
        The textfield provides an input for a hex color code, while RGB color codes can be inputted from inside the color picker modal.
    }

    @Column {
        ![`LuminareColorPicker`](LuminareColorPicker)
    }
}
    
@Row {
    @Column {
        Here is an example of its typical usage:
        
        ```swift
        LuminareColorPicker(
            "Done",
            color: $color,
            parseStrategy: .hex(.lowercasedWithWell),
            colorNames: (
                red: Text("Red"),
                green: Text("Green"),
                blue: Text("Blue")
            )
        )
        ```
        
        If using `format` rather than `parseStrategy`, see ``StringFormatStyle`` for more formatting options for the hex color code.
    }
}

## Topics

### Formatting the Color Code

- ``StringFormatStyle``
