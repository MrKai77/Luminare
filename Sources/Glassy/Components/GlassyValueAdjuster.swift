//
//  GlassyValueAdjuster.swift
//  
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct GlassyValueAdjuster<V>: View where V: Strideable, V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    let elementHeight: CGFloat = 80
    let horizontalPadding: CGFloat = 12

    let formatter: NumberFormatter
    var totalRange: V.Stride {
        V.Stride(sliderRange.upperBound) - V.Stride(sliderRange.lowerBound)
    }

    let title: String
    let description: String?
    @Binding var value: V
    let sliderRange: ClosedRange<V>
    let postscript: String?
    var step: V.Stride
    let upperClamp: Bool
    let lowerClamp: Bool

    public init(
        _ title: String,
        description: String? = nil,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        postscript: String? = nil,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false
    ) {
        self.title = title
        self.description = description
        self._value = value
        self.sliderRange = sliderRange
        self.postscript = postscript
        self.lowerClamp = lowerClamp
        self.upperClamp = upperClamp

        self.formatter = NumberFormatter()
        self.formatter.maximumFractionDigits = 2

        if let step = step {
            self.step = V.Stride(step)
        } else {
            self.step = 0   // Initialize first
            self.step = totalRange / 10
        }
    }

    public var body: some View {
        VStack {
            HStack {
                Text(self.title)

                Spacer()

                self.stepperView()
            }

            Slider(value: self.$value, in: self.sliderRange)
        }
        .padding(.horizontal, 12)
        .frame(height: elementHeight)
    }

    @ViewBuilder
    func stepperView() -> some View {
        HStack {
            HStack {
                TextField(
                    .init(""),
                    value: Binding(
                        get: {
                            self.value
                        },
                        set: {
                            if lowerClamp && upperClamp {
                                self.value = $0.clamped(to: sliderRange)
                            } else if lowerClamp {
                                self.value = max(self.sliderRange.lowerBound, $0)
                            } else if upperClamp {
                                self.value = min(self.sliderRange.upperBound, $0)
                            } else {
                                self.value = $0
                            }
                        }
                    ),
                    formatter: formatter
                )
                .labelsHidden()
                .textFieldStyle(.plain)
                .padding(.trailing, -8)

                if let postfix = postscript {
                    Text(postfix)
                }
            }
            .padding(4)
            .padding(.horizontal, 4)
            .background {
                ZStack {
                    Capsule(style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)

                    Capsule(style: .continuous)
                        .foregroundStyle(.quinary.opacity(0.5))
                }
            }
//            .padding(4)
//            .padding(.trailing, 12)
//            .background {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 6)
//                        .foregroundStyle(.background)
//                    RoundedRectangle(cornerRadius: 6)
//                        .strokeBorder(
//                            .tertiary.opacity(0.5),
//                            lineWidth: 1
//                        )
//                }
//            }
//            .frame(minWidth: 20, maxWidth: 500)
//            .overlay {
//                HStack {
//                    Spacer()
//
//                    Stepper(
//                        .init(""),
//                        value: Binding(
//                            get: {
//                                self.value
//                            },
//                            set: {
//                                if lowerClamp && upperClamp {
//                                    self.value = $0.clamped(to: sliderRange)
//                                } else if lowerClamp {
//                                    self.value = max(self.sliderRange.lowerBound, $0)
//                                } else if upperClamp {
//                                    self.value = min(self.sliderRange.upperBound, $0)
//                                } else {
//                                    self.value = $0
//                                }
//                            }
//                        ),
//                        step: step
//                    )
//                    .labelsHidden()
//                }
//                .padding(.horizontal, 1)
//            }
            .fixedSize()
//            .padding(.vertical, -10)
        }
    }
}

extension Comparable {
    fileprivate func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
