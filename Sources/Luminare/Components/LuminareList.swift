//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

// MARK: - List

/// A stylized list.
public struct LuminareList<Header, ContentA, ContentB, Actions, RemoveView, Footer, V, ID>: View where Header: View, ContentA: View, ContentB: View, Actions: View, RemoveView: View, Footer: View, V: Hashable, ID: Hashable { // swiftlint:disable:this line_length
    // MARK: Environments

    @Environment(\.luminareClickedOutside) private var luminareClickedOutside
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    @Binding private var items: [V]
    @Binding private var selection: Set<V>
    private let id: KeyPath<V, ID>
    private let actionsMaxHeight: CGFloat?

    @ViewBuilder private let content: (Binding<V>) -> ContentA, emptyView: () -> ContentB
    @ViewBuilder private let actions: () -> Actions, removeView: () -> RemoveView
    @ViewBuilder private let header: () -> Header, footer: () -> Footer

    @State private var firstItem: V?
    @State private var lastItem: V?

    @State private var canRefreshSelection = true
    @State private var eventMonitor: AnyObject?

    // MARK: Initializers

    /// Initializes a ``LuminareList``.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self._items = items
        self._selection = selection
        self.id = id
        self.actionsMaxHeight = actionsMaxHeight
        self.content = content
        self.emptyView = emptyView
        self.actions = actions
        self.removeView = removeView
        self.header = header
        self.footer = footer
    }

    /// Initializes a ``LuminareList`` whose header, footer and **remove** button's content are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) where ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            header: header,
            footer: footer
        )
    }

    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list, whose header,
    /// footer and **remove** button's content are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, ContentB == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a footer.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - header: the header.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: header,
            footer: {
                EmptyView()
            }
        )
    }

    /// Initializes a ``LuminareList`` without a footer, whose header and **remove** button's content are localized
    /// texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        headerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a footer and displays literally nothing when nothing is inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - header: the header.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header
    ) where ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            header: header
        )
    }

    /// Initializes a ``LuminareList`` without a footer and displays literally nothing when nothing is inside the list,
    /// whose header and **remove** button's content are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        headerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, ContentB == EmptyView, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - footer: the footer.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: {
                EmptyView()
            },
            footer: footer
        )
    }

    /// Initializes a ``LuminareList`` without a header, whose footer and **remove** button's content are localized
    /// texts.
    ///
    /// - Parameters:
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header and displays literally nothing when nothing is inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    ///   - footer: the footer.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView, ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            footer: footer
        )
    }

    /// Initializes a ``LuminareList`` without a header and displays literally nothing when nothing is inside the list,
    /// whose footer and **remove** button's content are localized texts.
    ///
    /// - Parameters:
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, ContentB == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header and a footer.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: {
                EmptyView()
            },
            footer: {
                EmptyView()
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header and a footer, whose **remove** button's content are localized
    /// texts.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header and a footer and displays literally nothing when nothing is
    /// inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    ///   - removeView: the view inside the **remove** button.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView
    ) where Header == EmptyView, ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView
        )
    }

    /// Initializes a ``LuminareList`` without a header and a footer and displays literally nothing when nothing is
    /// inside the list, whose **remove** button's content are localized texts.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - removeKey: the `LocalizedStringKey` to look up the text inside the **remove** button.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, ContentB == EmptyView, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            }
        )
    }

    /// Initializes a ``LuminareList`` without a header, a footer and a **remove** button.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    ///   - actions: the actions placed next to the **remove** button.
    ///   Typically buttons that manipulate the listed items.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, ContentB == EmptyView, RemoveView == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: {
                EmptyView()
            },
            header: {
                EmptyView()
            },
            footer: {
                EmptyView()
            }
        )
    }

    /// Initializes a ``LuminareList`` without a toolbar.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - actionsMaxHeight: the maximum height of the actions region.
    ///   - content: the content generator that accepts a value binding.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where Header == EmptyView, ContentB == EmptyView,
        Actions == EmptyView, RemoveView == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: {
                EmptyView()
            }
        )
    }

    // MARK: Body

    public var body: some View {
        LuminareSection(hasPadding: false) {
            let hasActions = Actions.self != EmptyView.self
            let hasRemoveView = RemoveView.self != EmptyView.self

            if hasActions || hasRemoveView {
                HStack(spacing: 2) {
                    if hasActions {
                        actions()
                            .buttonStyle(LuminareButtonStyle())
                    }

                    if hasRemoveView {
                        Button {
                            if !selection.isEmpty {
                                canRefreshSelection = false
                                items.removeAll(where: { selection.contains($0) })

                                selection = []

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    canRefreshSelection = true
                                }
                            }
                        } label: {
                            removeView()
                        }
                        .buttonStyle(LuminareDestructiveButtonStyle())
                        .disabled(selection.isEmpty)
                    }
                }
                .frame(maxHeight: actionsMaxHeight)
                .modifier(
                    LuminareCroppedSectionItem(
                        isFirstChild: true,
                        isLastChild: false
                    )
                )
                .padding(.vertical, 4)
                .padding(.bottom, 4)
                .padding([.top, .horizontal], 1)
            }

            if items.isEmpty {
                emptyView()
                    .frame(minHeight: 50)
            } else {
                List(selection: $selection) {
                    ForEach($items, id: id) { item in
                        let isDisabled = isDisabled(item.wrappedValue)
                        let tint = getTint(of: item.wrappedValue)

                        Group {
                            if #available(macOS 14.0, *) {
                                LuminareListItem(
                                    items: $items,
                                    selection: $selection,
                                    item: item,
                                    firstItem: $firstItem,
                                    lastItem: $lastItem,
                                    canRefreshSelection: $canRefreshSelection,
                                    content: content
                                )
                                .selectionDisabled(isDisabled)
                            } else {
                                LuminareListItem(
                                    items: $items,
                                    selection: $selection,
                                    item: item,
                                    firstItem: $firstItem,
                                    lastItem: $lastItem,
                                    canRefreshSelection: $canRefreshSelection,
                                    content: content
                                )
                            }
                        }
                        .disabled(isDisabled)
                        .animation(animation, value: isDisabled)
                        .overrideTint { tint }
                    }
                    .onMove { indices, newOffset in
                        withAnimation(animation) {
                            items.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -10)
                }
                .frame(height: CGFloat(items.count * 50))
                .padding(.top, 4)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .listStyle(.plain)
            }
        } header: {
            header()
        } footer: {
            footer()
        }
        .onChange(of: luminareClickedOutside) { _ in
            withAnimation(animation) {
                selection = []
            }
        }
        .onChange(of: selection) { _ in
            processSelection()

            if selection.isEmpty {
                removeEventMonitor()
            } else {
                addEventMonitor()
            }
        }
        .onAppear {
            if !selection.isEmpty {
                addEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    // MARK: Functions

    private func isDisabled(_ element: V) -> Bool {
        (element as? LuminareSelectionData)?.isSelectable == false
    }

    private func getTint(of element: V) -> Color {
        (element as? LuminareSelectionData)?.tint ?? tint()
    }

    private func processSelection() {
        if selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first(where: { selection.contains($0) })
            lastItem = items.last(where: { selection.contains($0) })
        }
    }

    private func addEventMonitor() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let kVK_Escape: CGKeyCode = 0x35 // swiftlint:disable:this identifier_name

            if event.keyCode == kVK_Escape {
                withAnimation(animation) {
                    selection = []
                }
                return nil
            }
            return event
        } as? NSObject
    }

    private func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

// MARK: - List Item

public struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    @Binding private var item: V
    @ViewBuilder private let content: (Binding<V>) -> Content

    @Binding private var items: [V]
    @Binding private var selection: Set<V>

    @Binding private var firstItem: V?
    @Binding private var lastItem: V?
    @Binding private var canRefreshSelection: Bool

    @State private var isHovering = false

    private let cornerRadius: CGFloat = 2
    private let maxLineWidth: CGFloat = 1.5
    @State private var lineWidth: CGFloat = .zero

    private let maxTintOpacity: CGFloat = 0.15
    @State private var tintOpacity: CGFloat = .zero

    // MARK: Initializers

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: Binding<V>,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>,
        canRefreshSelection: Binding<Bool>,
        @ViewBuilder content: @escaping (Binding<V>) -> Content
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self._firstItem = firstItem
        self._lastItem = lastItem
        self._canRefreshSelection = canRefreshSelection
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareItem, isHovering)
                    .foregroundStyle(isEnabled ? .primary : .secondary)
            }
            .tag(item)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }

            .background {
                ZStack {
                    if isEnabled {
                        itemBorder()
                        itemBackground()
                    }
                }
                .padding(.horizontal, 1)
                .padding(.leading, 1)
            }

            .overlay {
                if item != items.last {
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .padding(.trailing, -0.5)
                }
            }
            .onChange(of: selection) { newSelection in
                guard isEnabled else { return }
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        updateSelection(selection: newSelection)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        // initialize selection
                        updateSelection(selection: selection)
                        // reset hovering state
                        isHovering = false
                    }
                }
            }
    }

    @ViewBuilder private func itemBackground() -> some View {
        Group {
            tint()
                .opacity(tintOpacity)

            if isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
    }

    @ViewBuilder private func itemBorder() -> some View {
        if isFirstInSelection(), isLastInSelection() {
            singleSelectionPart(isBottomOfList: item == items.last)

        } else if isFirstInSelection() {
            firstItemPart()

        } else if isLastInSelection() {
            lastItemPart(isBottomOfList: item == items.last)

        } else if selection.contains(item) {
            doubleLinePart()
        }
    }

    @ViewBuilder private func firstItemPart() -> some View {
        VStack(spacing: 0) {
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius
                )
                .strokeBorder(.tint, lineWidth: lineWidth)

                VStack {
                    Color.clear
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                }
            }
            .compositingGroup()

            // --- bottom part ---

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)
        }
    }

    @ViewBuilder private func lastItemPart(isBottomOfList: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)

            // --- bottom part ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    topTrailingRadius: 0
                )
                .strokeBorder(.tint, lineWidth: lineWidth)

                VStack {
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                    Color.clear
                }
            }
            .compositingGroup()
        }
    }

    @ViewBuilder private func doubleLinePart() -> some View {
        HStack {
            Rectangle()
                .frame(width: lineWidth)

            Spacer()

            Rectangle()
                .frame(width: lineWidth)
        }
        .foregroundStyle(.tint)
    }

    @ViewBuilder private func singleSelectionPart(isBottomOfList: Bool) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .strokeBorder(.tint, lineWidth: lineWidth)
    }

    // MARK: Functions

    private func updateSelection(selection: Set<V>) {
        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
        lineWidth = selection.contains(item) ? maxLineWidth : .zero
    }

    private func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !selection.contains(items[firstIndex - 1]) {
            return true
        }

        return item == firstItem
    }

    private func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1,
           !selection.contains(items[firstIndex + 1]) {
            return true
        }

        return item == lastItem
    }
}

// MARK: - Preview

private struct ListPreview<V>: View where V: Hashable & Comparable {
    @State var items: [V]
    @State var selection: Set<V>
    let add: (inout [V]) -> ()

    var body: some View {
        LuminareList(
            "List Header", "List Footer",
            items: $items,
            selection: $selection,
            id: \.self,
            removeKey: .init("Remove")
        ) { value in
            Text("\(value.wrappedValue)")
                .contextMenu {
                    Button("Remove") {
                        withAnimation {
                            items.removeAll { selection.contains($0) || value.wrappedValue == $0 }
                        }
                    }
                }
                .swipeActions {
                    Button("Swipe me!") {}
                }
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
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareList",
    traits: .sizeThatFitsLayout
) {
    ListPreview(items: [37, 42, 1, 0], selection: [42]) { items in
        guard items.count < 100 else { return }
        let random = { Int.random(in: 0 ..< 100) }
        var new = random()
        while items.contains([new]) {
            new = random()
        }
        items.append(new)
    }
}
