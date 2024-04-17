//
//  NSHostingViewSuppressingSafeArea.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

// From https://stackoverflow.com/questions/75166625/have-a-fullsizecontentview-nswindow-taking-the-size-of-a-swiftui-view
class NSHostingViewSuppressingSafeArea<T : View>: NSHostingView<T> {
    required init(rootView: T) {
        super.init(rootView: rootView)

        addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])
    }

    private lazy var layoutGuide = NSLayoutGuide()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var safeAreaRect: NSRect {
        print ("super.safeAreaRect \(super.safeAreaRect)")
        return frame
    }

    override var safeAreaInsets: NSEdgeInsets {
        print ("super.safeAreaInsets \(super.safeAreaInsets)")
        return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override var safeAreaLayoutGuide: NSLayoutGuide {
        print ("super.safeAreaLayoutGuide \(super.safeAreaLayoutGuide)")
        return layoutGuide
    }

    override var additionalSafeAreaInsets: NSEdgeInsets {
        get {
            print ("super.additionalSafeAreaInsets \(super.additionalSafeAreaInsets)")
            return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        set {
            print("additionalSafeAreaInsets.set \(newValue)")
        }
    }
}
