//
//  GlassySection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

//public struct GlassyForm<Content>: View where Content: View {
//    let outerPadding: CGFloat = 12
//
//    @ViewBuilder let content: () -> Content
//
//    public init(@ViewBuilder _ content: @escaping () -> Content) {
//        self.content = content
//    }
//
//    public var body: some View {
//        Form {
//            self.content()
//        }
//        .formStyle(.grouped)
//        .scrollContentBackground(.hidden)
//        .padding(-20) // Get rid of default padding
//        .padding(self.outerPadding)
//
//        .introspect(.form(style: .grouped), on: .macOS(.v13, .v14)) {
//            let subviews = $0.subviews
//            guard
//                let form = subviews.first,
//                let sub1 = form.subviews.first,
//                let sub2 = sub1.subviews.first
//            else {
//                return
//            }
//
//            let minWidth = form.bounds.width - 35 // This is approximate
//
//            // [0] is text1 (section title)
//            // [1] is section background
//            // [2] is text1
//            // [3] is divider
//            // [4] is box (or next element if that exists etc...)
//
//            // [5] is text2 (section title)
//            // [6] is background2
//            // [7] is text2
//            // [8] is divider
//            // [9] is box
//
//
//            for element in sub2.subviews where element.bounds.width >= minWidth {
//                print(element.fittingSize)
////                element.alphaValue = 0
////                element.layer?.contents = nil
////                element.layer?.borderWidth = 1
////                element.layer?.cornerRadius = 12
////                element.layer?.backgroundColor = NSColor(Color.secondary.opacity(0.075 / 2)).cgColor
////                element.layer?.borderColor = NSColor(Color.secondary.opacity(0.15 / 2)).cgColor
//            }
//
////            let target = sub2.subviews[4]
////            target.alphaValue = 0
////
////            // remove bottom padding: 1.5
////            let background = sub2.subviews[1]
////
////            background.layer?.contents = nil
////            background.layer?.borderWidth = 1
////            background.layer?.cornerRadius = 12
////            background.layer?.backgroundColor = NSColor(Color.secondary.opacity(0.075)).cgColor
////            background.layer?.borderColor = NSColor(Color.secondary.opacity(0.15)).cgColor
//
//        }
//    }
//}

public struct GlassySection<Content: View>: View {
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let outerPadding: CGFloat = 12

    let content: () -> Content

    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        DividedVStack {
            self.content()
        }
//        .clipShape(
//            .rect(
//                cornerRadius: self.cornerRadius - self.innerPadding,
//                style: .continuous
//            )
//        )
//        .padding(innerPadding)
        .frame(maxWidth: .infinity)
        .background(.quinary)
        .clipShape(
            .rect(
                cornerRadius: self.cornerRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: self.cornerRadius,
                style: .continuous
            )
            .strokeBorder(.quaternary, lineWidth: 1)
        }
        .padding(outerPadding)
    }
}

//  Thank you https://movingparts.io/variadic-views-in-swiftui
public struct DividedVStack<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(DividedVStackLayout()) {
            content
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let elementMinHeight: CGFloat = 40

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: self.innerPadding) {
            ForEach(children) { child in
                child
                    .mask {
                        if child.id == first {
                            UnevenRoundedRectangle(
                                topLeadingRadius: cornerRadius - innerPadding,
                                bottomLeadingRadius: innerPadding,
                                bottomTrailingRadius: innerPadding,
                                topTrailingRadius: cornerRadius - innerPadding,
                                style: .continuous
                            )
                        } else if child.id == last {
                            UnevenRoundedRectangle(
                                topLeadingRadius: innerPadding,
                                bottomLeadingRadius: cornerRadius - innerPadding,
                                bottomTrailingRadius: cornerRadius - innerPadding,
                                topTrailingRadius: innerPadding,
                                style: .continuous
                            )
                        } else {
                            UnevenRoundedRectangle(
                                topLeadingRadius: innerPadding,
                                bottomLeadingRadius: innerPadding,
                                bottomTrailingRadius: innerPadding,
                                topTrailingRadius: innerPadding,
                                style: .continuous
                            )
                        }
                    }
                    .padding(.horizontal, innerPadding) // already applied vertically with spacing
                    .frame(height: elementMinHeight)

                if child.id != last {
                    Divider()
                }
            }
        }
        .padding(.vertical, innerPadding)
    }
}
