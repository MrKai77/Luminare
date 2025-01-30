# ``Luminare/LuminareSidebarSection``

@Row {
    @Column(size: 2) {
        You can organize sizebar tabs using ``LuminareSidebarSection``.
        It can display an optional label.
        
        ```swift
        LuminareSidebarSection(selection: $selection, items: [...])
        LuminareSidebarSection("Settings Graph", selection: $selection, items: [...])
        LuminareSidebarSection("Application", selection: $selection, items: [...])
        ```
    }
    
    @Column {
        ![LuminareSidebarSection](LuminareSidebarSection)
        
        > Due to some unexpected behaviors in **Xcode Previews,** this screenshot is manually captured.
    }
}

## Topics

### Related Views

- ``LuminareSidebarTab``
