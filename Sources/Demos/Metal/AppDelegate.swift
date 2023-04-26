//
//  AppDelegate.swift
//
//
//  Created by Christian Treffs on 30.08.19.
//

import Cocoa

@available(OSX 10.11, *)
final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var window: NSWindow = NSApplication.shared.windows[0]
    let viewController: ViewController = .init()

    func applicationWillFinishLaunching(_: Notification) {
        let view = viewController.view
        window.contentView = view
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
