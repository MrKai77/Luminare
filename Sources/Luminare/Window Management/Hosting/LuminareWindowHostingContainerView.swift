//
//  LuminareWindowHostingContainerView.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-10.
//

import AppKit

final class LuminareWindowHostingContainerView: NSView {
    private let hostedView: NSView

    init(hostedView: NSView) {
        self.hostedView = hostedView
        super.init(frame: .zero)
        addSubview(hostedView)

        hostedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
