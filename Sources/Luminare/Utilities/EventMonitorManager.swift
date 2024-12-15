//
//  EventMonitorManager.swift
//  Luminare
//
//  Created by KrLite on 2024/12/15.
//

import AppKit

public final class EventMonitorManager {
    static let shared = EventMonitorManager()
    private var monitors: [AnyHashable: NSObject] = [:]

    func addLocalMonitor(
        for id: AnyHashable,
        matching mask: NSEvent.EventTypeMask,
        handler: @escaping (NSEvent) -> NSEvent?
    ) {
        removeMonitor(for: id)

        monitors[id] = NSEvent.addLocalMonitorForEvents(
            matching: mask,
            handler: { [weak self] event in
                guard self != nil else { return nil }
                return handler(event)
            }
        ) as? NSObject
    }

    func addGlobalMonitor(
        for id: AnyHashable,
        matching mask: NSEvent.EventTypeMask,
        handler: @escaping (NSEvent) -> ()
    ) {
        removeMonitor(for: id)

        monitors[id] = NSEvent.addGlobalMonitorForEvents(
            matching: mask,
            handler: { [weak self] event in
                guard self != nil else { return }
                handler(event)
            }
        ) as? NSObject
    }

    func removeMonitor(for id: AnyHashable) {
        guard let monitor = monitors.removeValue(forKey: id) else { return }
        NSEvent.removeMonitor(monitor)
    }

    func removeAllMonitors() {
        monitors.forEach { NSEvent.removeMonitor($0.value) }
        monitors.removeAll()
    }
}
