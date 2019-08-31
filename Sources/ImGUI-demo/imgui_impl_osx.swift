//
//  imgui_impl_osx.swift
//  
//
//  Created by Christian Treffs on 31.08.19.
//

import ImGUI
import CImGUI
import AppKit

var g_Time: CFAbsoluteTime = 0.0

func ImGui_ImplOSX_Init() {
    let ioRef = igGetIO()!
    var io: ImGuiIO = ioRef.pointee

    io.BackendPlatformName = "imgui_metal_osx".cStrPtr()

    // Setup back-end capabilities flags
    // TODO: io.BackendFlags

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.

    // Load cursors. Some of them are undocumented.

    // Note that imgui.cpp also include default OSX clipboard handlers which can be enabled
    // by adding '#define IMGUI_ENABLE_OSX_DEFAULT_CLIPBOARD_FUNCTIONS' in imconfig.h and adding '-framework ApplicationServices' to your linker command-line.
    // Since we are already in ObjC land here, it is easy for us to add a clipboard handler using the NSPasteboard api.

}

func ImGui_ImplOSX_NewFrame(_ view: NSView) {
    // Setup display size
    let ioRef = igGetIO()!
    var io: ImGuiIO = ioRef.pointee

    io.DisplaySize = ImVec2(x: Float(view.bounds.size.width), y: Float(view.bounds.size.height))

    let dpi: Float = Float(view.window?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)
    io.DisplayFramebufferScale = ImVec2(x: dpi, y: dpi)

    // Setup time step
    if g_Time == 0.0 {
        g_Time = CFAbsoluteTimeGetCurrent()
    }
    let current_time: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    io.DeltaTime = Float(current_time - g_Time)
    g_Time = current_time

    ImGui_ImplOSX_UpdateMouseCursor()
}

func ImGui_ImplOSX_UpdateMouseCursor() {

}

@discardableResult func ImGui_ImplOSX_HandleEvent(_ event: NSEvent, _ view: NSView) -> Bool {
    return false
}
