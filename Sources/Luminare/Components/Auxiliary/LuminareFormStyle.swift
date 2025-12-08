//
//  LuminareFormStyle.swift
//  Luminare
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI
import VariadicViews

@available(macOS 15.0, *)
public struct LuminareFormStyle: FormStyle {
    @Environment(\.luminareFormSpacing) private var spacing

    public func makeBody(configuration: Configuration) -> some View {
        AutoScrollView {
            LazyVStack(alignment: .leading, spacing: spacing) {
                ForEach(sections: configuration.content) { section in
                    FormSection(section: section)
                }
            }
            .padding(12)
        }
    }

    struct FormSection: View {
        var section: SectionConfiguration

        var body: some View {
            LuminareSection {
                section.content
            } header: {
                section.header
            } footer: {
                section.footer
            }
            .toggleStyle(.switch)
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareFormStyle",
    traits: .sizeThatFitsLayout
) {
    Form {
        Section("General") {
            LuminareToggle(
                "Launch at login",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Hide menu bar icon",
                isOn: .constant(true)
            )

            LuminareSliderPicker(
                "Animation speed",
                ["Instant", "Fast", "Smooth"],
                selection: .constant("Fast")
            ) { speed in
                Text(speed)
                    .monospaced()
            }
        }

        Section("Window") {
            LuminareButton(
                "Debug",
                "Reset Window Frame"
            ) {}

            LuminareToggle(
                "Restore window frame on drag",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Include padding",
                isOn: .constant(true)
            )
        }

        Section("Cursor") {
            LuminareToggle(
                "Use screen with cursor",
                isOn: .constant(true)
            )

            LuminareToggle(
                "Move cursor with window",
                isOn: .constant(true)
            )
        }
    }
    .formStyle(.luminare)
}
