//
//  main.swift
//  
//
//  Created by Christian Treffs on 30.08.19.
//

import AppKit

_ = NSApplication.shared
NSApp.setActivationPolicy(.regular)

if #available(OSX 10.11, *) {
    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate
} else {
    // Fallback on earlier versions
}

let menubar = NSMenu()
let appMenuItem = NSMenuItem()
menubar.addItem(appMenuItem)

NSApp.mainMenu = menubar

let appMenu = NSMenu()
let appName = ProcessInfo.processInfo.processName

let quitTitle = "Quit \(appName)"

let quitMenuItem = NSMenuItem(title: quitTitle,
                              action: #selector(NSApplication.shared.terminate(_:)),
                              keyEquivalent: "q")
appMenu.addItem(quitMenuItem)
appMenuItem.submenu = appMenu

let window: NSWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                                backing: .buffered,
                                defer: false)

window.center()
window.title = appName
window.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
