# ``Luminare/LuminareSliderPickerCompose``

@Row {
    @Column {
        It has a composed label and uses a slider to expose all selectable discrete values.
        However, only the content of selection will be visible.
        
        To use a ``LuminareSliderPickerCompose``, you must explicitly pass in all the available options.
    }
    
    @Column {
        ![LuminareSliderPickerCompose](LuminareSliderPickerCompose)
    }
}

If context awareness is required (e.g., grouping several non-related options), it's recommended to use segmented ``LuminareCompactPicker`` instead.
