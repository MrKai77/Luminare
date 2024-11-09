# ``Luminare/LuminareList``

@Row {
    @Column {
        The list is based on a bordered ``LuminareSection``.
        An array of items and a set of selected items are required to create a list.
        
        It has a toolbar that reserves a position for the **remove** button, while its leading space is free to insert custom action buttons.
        The toolbar only hides when all of the provided buttons are `EmptyView`.
        
        > Slide actions are currently disabled on list items due to severe bugs.
    }
    
    @Column {
        ![LuminareList](LuminareList)
    }
}

Here's a practical usage with 2 custom action buttons and a named **remove** button:

```swift
LuminareList(
    "List Header", "List Footer",
    items: $items,
    selection: $selection,
    id: \.self,
    removeKey: .init("Remove")
) { value in
    // content
} emptyView: {
    Text("Empty")
        .foregroundStyle(.secondary)
} actions: {
    Button("Add") {
        withAnimation {
            add(&items)
        }
    }

    Button("Sort") {
        withAnimation {
            items.sort(by: <)
        }
    }
}
```
