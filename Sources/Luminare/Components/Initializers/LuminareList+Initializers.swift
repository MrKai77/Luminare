//
//  LuminareList+Initializers.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

//public extension LuminareList {
//    /// Initializes a ``LuminareList`` whose header and footer are localized texts.
//    ///
//    /// - Parameters:
//    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
//    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        _ headerKey: LocalizedStringKey,
//        _ footerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions
//    ) where Header == Text, Footer == Text {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            header: {
//                Text(headerKey)
//            },
//            footer: {
//                Text(footerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    ///   - header: the header.
//    ///   - footer: the footer.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions,
//        @ViewBuilder header: @escaping () -> Header,
//        @ViewBuilder footer: @escaping () -> Footer
//    ) where ContentB == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: {
//                EmptyView()
//            },
//            actions: actions,
//            header: header,
//            footer: footer
//        )
//    }
//
//    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list, whose header and
//    /// footer are localized texts.
//    ///
//    /// - Parameters:
//    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
//    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        _ headerKey: LocalizedStringKey,
//        _ footerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions
//    )
//        where
//        Header == Text, ContentB == EmptyView,
//        Footer == Text {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            actions: actions,
//            header: {
//                Text(headerKey)
//            },
//            footer: {
//                Text(footerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a footer.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    ///   - header: the header.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions,
//        @ViewBuilder header: @escaping () -> Header
//    ) where Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            header: header,
//            footer: {
//                EmptyView()
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a footer, whose header is a localized text.
//    ///
//    /// - Parameters:
//    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        headerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions
//    ) where Header == Text, Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            header: {
//                Text(headerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a footer and displays literally nothing when nothing is inside the list.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    ///   - header: the header.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions,
//        @ViewBuilder header: @escaping () -> Header
//    ) where ContentB == EmptyView, Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: {
//                EmptyView()
//            },
//            actions: actions,
//            header: header
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a footer and displays literally nothing when nothing is inside the list,
//    /// whose header is a localized text.
//    ///
//    /// - Parameters:
//    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        headerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions
//    )
//        where
//        Header == Text, ContentB == EmptyView,
//        Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            actions: actions,
//            header: {
//                Text(headerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    ///   - footer: the footer.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions,
//        @ViewBuilder footer: @escaping () -> Footer
//    ) where Header == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            header: {
//                EmptyView()
//            },
//            footer: footer
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header, whose footer is a localized text.
//    ///
//    /// - Parameters:
//    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        footerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions
//    ) where Header == EmptyView, Footer == Text {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            footer: {
//                Text(footerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header and displays literally nothing when nothing is inside the list.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    ///   - footer: the footer.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions,
//        @ViewBuilder footer: @escaping () -> Footer
//    ) where Header == EmptyView, ContentB == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: {
//                EmptyView()
//            },
//            actions: actions,
//            footer: footer
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header and displays literally nothing when nothing is inside the list,
//    /// whose footer is a localized text.
//    ///
//    /// - Parameters:
//    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        footerKey: LocalizedStringKey,
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions
//    )
//        where
//        Header == EmptyView, ContentB == EmptyView,
//        Footer == Text {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            actions: actions,
//            footer: {
//                Text(footerKey)
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header and a footer.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - emptyView: the view to display when nothing is inside the list.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder emptyView: @escaping () -> ContentB,
//        @ViewBuilder actions: @escaping () -> Actions
//    ) where Header == EmptyView, Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: emptyView,
//            actions: actions,
//            header: {
//                EmptyView()
//            },
//            footer: {
//                EmptyView()
//            }
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without a header and a footer and displays literally nothing when nothing is
//    /// inside the list.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    ///   - actions: the actions pinned to the top of the list.
//    ///   Typically buttons that manipulate the listed items.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
//        @ViewBuilder actions: @escaping () -> Actions
//    ) where Header == EmptyView, ContentB == EmptyView, Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            emptyView: {
//                EmptyView()
//            },
//            actions: actions
//        )
//    }
//
//    /// Initializes a ``LuminareList`` without any actions.
//    ///
//    /// - Parameters:
//    ///   - items: the binding of the listed items.
//    ///   - selection: the binding of the set of selected items.
//    ///   - id: the key path for the identifiers of each element.
//    ///   - content: the content generator that accepts a value binding.
//    init(
//        items: Binding<[V]>,
//        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
//        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
//    )
//        where
//        Header == EmptyView, ContentB == EmptyView,
//        Actions == EmptyView, Footer == EmptyView {
//        self.init(
//            items: items,
//            selection: selection, id: id,
//            content: content,
//            actions: {
//                EmptyView()
//            }
//        )
//    }
//}
