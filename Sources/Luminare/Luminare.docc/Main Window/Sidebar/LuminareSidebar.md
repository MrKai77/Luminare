# ``Luminare/LuminareSidebar``

@Row {
    @Column(size: 2) {
        Typically, the content is consisted of multiple ``LuminareSidebarTab`` organized by ``LuminareSidebarSection``:
        
        ```swift
        LuminareSidebar {
            LuminareSidebarSection("Application", selection: $selection, items: [...])
            LuminareSidebarSection("About", selection: $selection, items: [...])
            ...
        }
        ```

        It uses an ``AutoScrollView`` to automatically switch between static and scrollable depending on the content size.
    }
    
    @Column {
        ![LuminareSidebar](LuminareSidebar)
    }
}

 ## Topics

 ### Related Views

 - ``LuminareSidebarSection``
 - ``LuminareSidebarTab``
