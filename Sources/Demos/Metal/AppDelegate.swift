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
    let viewController: ViewController = ViewController()

    func applicationWillFinishLaunching(_ notification: Notification) {
        let view = viewController.view
        window.contentView = view
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
