//
//  NSBezierPath+Extensions.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import Cocoa

// https://gist.github.com/usagimaru/7bf5f68ebc40ee8bf2ad15de3e40b0f2
extension NSBezierPath {
    convenience init(smoothRoundedRect rect: NSRect, cornerRadius: CGFloat) {
        self.init()

        // Original code is this PaintCode's blog post and the Objective-C category:
        // https://www.paintcodeapp.com/news/code-for-ios-7-rounded-rectangles

        let limitedRadius = min(cornerRadius, min(rect.size.width, rect.size.height) / 2.0 / 1.52866483)

        func topLeft(x: CGFloat, y: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + x * limitedRadius, y: rect.origin.y + y * limitedRadius)
        }
        func topRight(x: CGFloat, y: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + rect.size.width - x * limitedRadius, y: rect.origin.y + y * limitedRadius)
        }
        func bottomLeft(x: CGFloat, y: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + x * limitedRadius, y: rect.origin.y + rect.size.height - y * limitedRadius)
        }
        func bottomRight(x: CGFloat, y: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + rect.size.width - x * limitedRadius, y: rect.origin.y + rect.size.height - y * limitedRadius)
        }
        func top(y: CGFloat) -> NSPoint {
            NSPoint(x: rect.midX, y: rect.origin.y + y * rect.size.width)
        }
        func bottom(y: CGFloat) -> NSPoint {
            NSPoint(x: rect.midX, y: rect.origin.y + rect.size.height - y * limitedRadius)
        }
        func left(x: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + x * rect.size.height, y: rect.midY)
        }
        func right(x: CGFloat) -> NSPoint {
            NSPoint(x: rect.origin.x + rect.size.width - x * limitedRadius, y: rect.midY)
        }

        func addSmoothRoundedRect1() {
            move(to: topLeft(x: 1.52866483, y: 0))
            line(to: topRight(x: 1.52866471, y: 0))
            curve(to: topRight(x: 0.66993427, y: 0.06549600), controlPoint1: topRight(x: 1.08849323, y: 0), controlPoint2: topRight(x: 0.86840689, y: 0))
            line(to: topRight(x: 0.63149399, y: 0.07491100))
            curve(to: topRight(x: 0.07491176, y: 0.63149399), controlPoint1: topRight(x: 0.37282392, y: 0.16905899), controlPoint2: topRight(x: 0.16906013, y: 0.37282401))
            curve(to: topRight(x: 0, y: 1.52866483), controlPoint1: topRight(x: 0, y: 0.86840701), controlPoint2: topRight(x: 0, y: 1.08849299))
            line(to: bottomRight(x: 0, y: 1.52866471))
            curve(to: bottomRight(x: 0.06549569, y: 0.66993493), controlPoint1: bottomRight(x: 0, y: 1.08849323), controlPoint2: bottomRight(x: 0, y: 0.86840689))
            line(to: bottomRight(x: 0.07491111, y: 0.63149399))
            curve(to: bottomRight(x: 0.63149399, y: 0.07491111), controlPoint1: bottomRight(x: 0.16905883, y: 0.37282392), controlPoint2: bottomRight(x: 0.37282392, y: 0.16905883))
            curve(to: bottomRight(x: 1.52866471, y: 0), controlPoint1: bottomRight(x: 0.86840689, y: 0), controlPoint2: bottomRight(x: 1.08849323, y: 0))
            line(to: bottomLeft(x: 1.52866483, y: 0))
            curve(to: bottomLeft(x: 0.66993397, y: 0.06549569), controlPoint1: bottomLeft(x: 1.08849299, y: 0), controlPoint2: bottomLeft(x: 0.86840701, y: 0))
            line(to: bottomLeft(x: 0.63149399, y: 0.07491111))
            curve(to: bottomLeft(x: 0.07491100, y: 0.63149399), controlPoint1: bottomLeft(x: 0.37282401, y: 0.16905883), controlPoint2: bottomLeft(x: 0.16906001, y: 0.37282392))
            curve(to: bottomLeft(x: 0, y: 1.52866471), controlPoint1: bottomLeft(x: 0, y: 0.86840689), controlPoint2: bottomLeft(x: 0, y: 1.08849323))
            line(to: topLeft(x: 0, y: 1.52866483))
            curve(to: topLeft(x: 0.06549600, y: 0.66993397), controlPoint1: topLeft(x: 0, y: 1.08849299), controlPoint2: topLeft(x: 0, y: 0.86840701))
            line(to: topLeft(x: 0.07491100, y: 0.63149399))
            curve(to: topLeft(x: 0.63149399, y: 0.07491100), controlPoint1: topLeft(x: 0.16906001, y: 0.37282401), controlPoint2: topLeft(x: 0.37282401, y: 0.16906001))
            curve(to: topLeft(x: 1.52866483, y: 0), controlPoint1: topLeft(x: 0.86840701, y: 0), controlPoint2: topLeft(x: 1.08849299, y: 0))
            close()
        }

        func addSmoothRoundedRect2a() {
            move(to: topLeft(x: 2.00593972, y: 0))
            line(to: NSPoint(x: rect.origin.x + rect.size.width - 1.52866483 * cornerRadius, y: rect.origin.y + 0 * cornerRadius))
            curve(to: topRight(x: 0.99544263, y: 0.10012127), controlPoint1: topRight(x: 1.63527834, y: 0), controlPoint2: topRight(x: 1.29884040, y: 0))
            line(to: topRight(x: 0.93667978, y: 0.11451437))
            curve(to: topRight(x: 0.00000051, y: 1.45223188), controlPoint1: topRight(x: 0.37430558, y: 0.31920183), controlPoint2: topRight(x: 0.00000051, y: 0.85376567))
            curve(to: right(x: 0), controlPoint1: right(x: 0), controlPoint2: right(x: 0))
            line(to: right(x: 0))
            curve(to: right(x: 0), controlPoint1: right(x: 0), controlPoint2: right(x: 0))
            line(to: bottomRight(x: 0, y: 1.45223165))
            curve(to: bottomRight(x: 0.93667978, y: 0.11451438), controlPoint1: bottomRight(x: 0, y: 0.85376561), controlPoint2: bottomRight(x: 0.37430558, y: 0.31920174))
            curve(to: bottomRight(x: 2.30815363, y: 0), controlPoint1: bottomRight(x: 1.29884040, y: 0), controlPoint2: bottomRight(x: 1.63527834, y: 0))
            line(to: NSPoint(x: rect.origin.x + 1.52866483 * cornerRadius, y: rect.origin.y + rect.size.height - 0 * limitedRadius))
            curve(to: bottomLeft(x: 0.99544257, y: 0.10012124), controlPoint1: bottomLeft(x: 1.63527822, y: 0), controlPoint2: bottomLeft(x: 1.29884040, y: 0))
            line(to: bottomLeft(x: 0.93667972, y: 0.11451438))
            curve(to: bottomLeft(x: -0.00000001, y: 1.45223176), controlPoint1: bottomLeft(x: 0.37430549, y: 0.31920174), controlPoint2: bottomLeft(x: -0.00000007, y: 0.85376561))
            curve(to: left(x: 0), controlPoint1: left(x: 0), controlPoint2: left(x: 0))
            line(to: left(x: 0))
            curve(to: left(x: 0), controlPoint1: left(x: 0), controlPoint2: left(x: 0))
            line(to: topLeft(x: -0.00000001, y: 1.45223153))
            curve(to: topLeft(x: 0.93667978, y: 0.11451436), controlPoint1: topLeft(x: 0.00000004, y: 0.85376537), controlPoint2: topLeft(x: 0.37430561, y: 0.31920177))
            curve(to: topLeft(x: 2.30815363, y: 0), controlPoint1: topLeft(x: 1.29884040, y: 0), controlPoint2: topLeft(x: 1.63527822, y: 0))
            line(to: NSPoint(x: rect.origin.x + 1.52866483 * cornerRadius, y: rect.origin.y + 0 * cornerRadius))
            line(to: topLeft(x: 2.00593972, y: 0))
            close()
        }

        func addSmoothRoundedRect2b() {
            move(to: top(y: 0))
            line(to: top(y: 0))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: topRight(x: 1.45223153, y: 0))
            curve(to: topRight(x: 0.11451442, y: 0.93667936), controlPoint1: topRight(x: 0.85376573, y: 0.00000001), controlPoint2: topRight(x: 0.31920189, y: 0.37430537))
            curve(to: topRight(x: 0, y: 2.30815387), controlPoint1: topRight(x: 0, y: 1.29884040), controlPoint2: topRight(x: 0, y: 1.63527822))
            line(to: NSPoint(x: rect.origin.x + rect.size.width - 0 * cornerRadius, y: rect.origin.y + rect.size.height - 1.52866483 * cornerRadius))
            curve(to: bottomRight(x: 0.10012137, y: 0.99544269), controlPoint1: bottomRight(x: 0, y: 1.63527822), controlPoint2: bottomRight(x: 0, y: 1.29884028))
            line(to: bottomRight(x: 0.11451442, y: 0.93667972))
            curve(to: bottomRight(x: 1.45223165, y: 0), controlPoint1: bottomRight(x: 0.31920189, y: 0.37430552), controlPoint2: bottomRight(x: 0.85376549, y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottom(y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottomLeft(x: 1.45223141, y: 0))
            curve(to: bottomLeft(x: 0.11451446, y: 0.93667972), controlPoint1: bottomLeft(x: 0.85376543, y: 0), controlPoint2: bottomLeft(x: 0.31920192, y: 0.37430552))
            curve(to: bottomLeft(x: 0, y: 2.30815387), controlPoint1: bottomLeft(x: 0, y: 1.29884028), controlPoint2: bottomLeft(x: 0, y: 1.63527822))
            line(to: NSPoint(x: rect.origin.x + 0 * cornerRadius, y: rect.origin.y + 1.52866483 * cornerRadius))
            curve(to: topLeft(x: 0.10012126, y: 0.99544257), controlPoint1: topLeft(x: 0, y: 1.63527822), controlPoint2: topLeft(x: 0, y: 1.29884040))
            line(to: topLeft(x: 0.11451443, y: 0.93667966))
            curve(to: topLeft(x: 1.45223153, y: 0), controlPoint1: topLeft(x: 0.31920189, y: 0.37430552), controlPoint2: topLeft(x: 0.85376549, y: 0))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: top(y: 0))
            close()
        }

        func addSmoothRoundedRect3() {
            move(to: top(y: 0))
            line(to: top(y: 0))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: top(y: 0))
            curve(to: topRight(x: 0, y: 1.52866483), controlPoint1: topRight(x: 0.68440646, y: 0.00000001), controlPoint2: topRight(x: 0, y: 0.68440658))
            curve(to: topRight(x: 0, y: 1.52866507), controlPoint1: topRight(x: 0, y: 1.52866495), controlPoint2: topRight(x: 0, y: 1.52866495))
            curve(to: topRight(x: 0, y: 1.52866483), controlPoint1: topRight(x: 0, y: 1.52866483), controlPoint2: topRight(x: 0, y: 1.52866483))
            line(to: right(x: 0))
            curve(to: bottomRight(x: 0, y: 1.52866471), controlPoint1: bottomRight(x: 0, y: 1.52866471), controlPoint2: bottomRight(x: 0, y: 1.52866471))
            line(to: bottomRight(x: 0, y: 1.52866471))
            curve(to: bottom(y: 0), controlPoint1: bottomRight(x: 0, y: 0.68440646), controlPoint2: bottomRight(x: 0.68440646, y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottom(y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottom(y: 0))
            curve(to: bottomLeft(x: 0, y: 1.52866471), controlPoint1: bottomLeft(x: 0.68440646, y: 0), controlPoint2: bottomLeft(x: -0.00000004, y: 0.68440646))
            curve(to: bottomLeft(x: 0, y: 1.52866495), controlPoint1: bottomLeft(x: 0, y: 1.52866471), controlPoint2: bottomLeft(x: 0, y: 1.52866495))
            curve(to: bottomLeft(x: 0, y: 1.52866471), controlPoint1: bottomLeft(x: 0, y: 1.52866471), controlPoint2: bottomLeft(x: 0, y: 1.52866471))
            line(to: left(x: 0))
            curve(to: topLeft(x: 0, y: 1.52866483), controlPoint1: topLeft(x: 0, y: 1.52866483), controlPoint2: topLeft(x: 0, y: 1.52866483))
            line(to: topLeft(x: 0, y: 1.52866471))
            curve(to: top(y: 0), controlPoint1: topLeft(x: 0.00000007, y: 0.68440652), controlPoint2: topLeft(x: 0.68440658, y: -0.00000001))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: top(y: 0))
            close()
        }

        func addSmoothRoundedRect3a() {
            move(to: top(y: 0))
            line(to: top(y: 0))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: top(y: 0))
            curve(to: topRight(x: 0, y: 1.52866483), controlPoint1: topRight(x: 0.68440646, y: 0.00000001), controlPoint2: topRight(x: 0, y: 0.68440658))
            curve(to: topRight(x: 0, y: 1.52866507), controlPoint1: topRight(x: 0, y: 1.52866495), controlPoint2: topRight(x: 0, y: 1.52866495))
            curve(to: topRight(x: 0, y: 1.52866483), controlPoint1: topRight(x: 0, y: 1.52866483), controlPoint2: topRight(x: 0, y: 1.52866483))
            line(to: right(x: 0))
            curve(to: bottomRight(x: 0, y: 1.52866471), controlPoint1: bottomRight(x: 0, y: 1.52866471), controlPoint2: bottomRight(x: 0, y: 1.52866471))
            line(to: bottomRight(x: 0, y: 1.52866471))
            curve(to: bottom(y: 0), controlPoint1: bottomRight(x: 0, y: 0.68440646), controlPoint2: bottomRight(x: 0.68440646, y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottom(y: 0))
            curve(to: bottom(y: 0), controlPoint1: bottom(y: 0), controlPoint2: bottom(y: 0))
            line(to: bottom(y: 0))
            curve(to: bottomLeft(x: 0, y: 1.52866471), controlPoint1: bottomLeft(x: 0.68440646, y: 0), controlPoint2: bottomLeft(x: -0.00000004, y: 0.68440646))
            curve(to: bottomLeft(x: 0, y: 1.52866495), controlPoint1: bottomLeft(x: 0, y: 1.52866471), controlPoint2: bottomLeft(x: 0, y: 1.52866495))
            curve(to: bottomLeft(x: 0, y: 1.52866471), controlPoint1: bottomLeft(x: 0, y: 1.52866471), controlPoint2: bottomLeft(x: 0, y: 1.52866471))
            line(to: left(x: 0))
            curve(to: topLeft(x: 0, y: 1.52866483), controlPoint1: topLeft(x: 0, y: 1.52866483), controlPoint2: topLeft(x: 0, y: 1.52866483))
            line(to: topLeft(x: 0, y: 1.52866471))
            curve(to: top(y: 0), controlPoint1: topLeft(x: 0.00000007, y: 0.68440652), controlPoint2: topLeft(x: 0.68440658, y: -0.00000001))
            curve(to: top(y: 0), controlPoint1: top(y: 0), controlPoint2: top(y: 0))
            line(to: top(y: 0))
            close()
        }

        func addSmoothRoundedRect3b() {
            move(to: top(y: 0))
            line(to: top(y: 0))
            curve(to: topRight(x: 1.52866495, y: 0), controlPoint1: topRight(x: 1.52866495, y: 0), controlPoint2: topRight(x: 1.52866495, y: 0))
            line(to: topRight(x: 1.52866495, y: 0))
            curve(to: right(x: 0), controlPoint1: topRight(x: 0.68440676, y: 0.00000001), controlPoint2: topRight(x: 0, y: 0.68440658))
            curve(to: right(x: 0), controlPoint1: right(x: 0), controlPoint2: right(x: 0))
            curve(to: right(x: 0), controlPoint1: right(x: 0), controlPoint2: right(x: 0))
            line(to: right(x: 0))
            curve(to: right(x: 0), controlPoint1: right(x: 0), controlPoint2: right(x: 0))
            line(to: right(x: 0))
            curve(to: bottomRight(x: 1.52866495, y: 0), controlPoint1: bottomRight(x: 0, y: 0.68440652), controlPoint2: bottomRight(x: 0.68440676, y: 0))
            curve(to: bottomRight(x: 1.52866495, y: 0), controlPoint1: bottomRight(x: 1.52866495, y: 0), controlPoint2: bottomRight(x: 1.52866495, y: 0))
            curve(to: bottomRight(x: 1.52866495, y: 0), controlPoint1: bottomRight(x: 1.52866495, y: 0), controlPoint2: bottomRight(x: 1.52866495, y: 0))
            line(to: bottom(y: 0))
            curve(to: bottomLeft(x: 1.52866483, y: 0), controlPoint1: bottomLeft(x: 1.52866483, y: 0), controlPoint2: bottomLeft(x: 1.52866483, y: 0))
            line(to: bottomLeft(x: 1.52866471, y: 0))
            curve(to: left(x: 0), controlPoint1: bottomLeft(x: 0.68440646, y: 0), controlPoint2: bottomLeft(x: -0.00000004, y: 0.68440676))
            curve(to: left(x: 0), controlPoint1: left(x: 0), controlPoint2: left(x: 0))
            curve(to: left(x: 0), controlPoint1: left(x: 0), controlPoint2: left(x: 0))
            line(to: left(x: 0))
            curve(to: left(x: 0), controlPoint1: left(x: 0), controlPoint2: left(x: 0))
            line(to: left(x: 0))
            curve(to: topLeft(x: 1.52866483, y: 0), controlPoint1: topLeft(x: 0.00000007, y: 0.68440652), controlPoint2: topLeft(x: 0.68440664, y: -0.00000001))
            curve(to: topLeft(x: 1.52866483, y: 0), controlPoint1: topLeft(x: 1.52866483, y: 0), controlPoint2: topLeft(x: 1.52866483, y: 0))
            line(to: top(y: 0))
            close()
        }

        let r = 1.52866495 * 2 * cornerRadius

        if rect.size.width > r, rect.size.height > r {
            addSmoothRoundedRect1()
        } else if rect.size.width > r {
            addSmoothRoundedRect2a()
        } else if rect.size.height > r {
            addSmoothRoundedRect2b()
        } else if rect.size.height > rect.size.width {
            addSmoothRoundedRect3a()
        } else {
            addSmoothRoundedRect3b()
        }
    }
}
