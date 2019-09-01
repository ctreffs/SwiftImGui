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

struct TupleArray<T> {
    var array: [T]

    init(_ tuple: (T, T)) {
        var tmp = tuple
        array = [T](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

    init(_ tuple: (T, T, T)) {
        var tmp = tuple
        array = [T](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

    init(_ tuple: (T, T, T, T)) {
        var tmp = tuple
        array = [T](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

    init(_ tuple: (T, T, T, T, T)) {
        var tmp = tuple
        array = [T](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

    init(_ tuple: (T, T, T, T, T, T)) {
        var tmp = tuple
        array = [T](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }

}

typealias MyTuple = (Bool, Bool, Bool, Bool, Bool)

let keyPath = \MyTuple.0

func set<T>(_ tuple: inout (T, T, T, T, T), value: T, at index: Int) {
     UnsafeMutableBufferPointer(start: &tuple.0, count: MemoryLayout.size(ofValue: tuple))[index] = value
}

func get<T>(value tuple: inout (T, T, T, T, T), at index: Int) -> T {
    let ptr = UnsafeMutableBufferPointer(start: &tuple.0, count: MemoryLayout.size(ofValue: tuple))
    return ptr[index]
}

@discardableResult func ImGui_ImplOSX_HandleEvent(_ event: NSEvent, _ view: NSView) -> Bool {
    var io = ImGui.GetIO()
    defer {
        ImGui.SetIO(to: &io)
    }

    if event.type == .leftMouseDown || event.type == .rightMouseDown || event.type == .otherMouseDown {
        let button = event.buttonNumber
        var mouseButtons = CArray(&io.MouseDown)
        if button >= 0 && button < mouseButtons.count {
            mouseButtons[button] = true
        }

        return io.WantCaptureMouse
    }

    if event.type == .leftMouseUp || event.type == .rightMouseUp || event.type == .otherMouseUp {
        let button = event.buttonNumber
        var mouseButtons = CArray(&io.MouseDown)
        if button >= 0 && button < mouseButtons.count {
            mouseButtons[button] = false
        }

        return io.WantCaptureMouse
    }

    if event.type == .mouseMoved || event.type == .leftMouseDragged {
        var mousePoint = event.locationInWindow
        mousePoint = view.convert(mousePoint, from: nil)
        mousePoint = NSPoint(x: mousePoint.x, y: view.bounds.size.height - mousePoint.y)
        io.MousePos = ImVec2(x: Float(mousePoint.x), y: Float(mousePoint.y))
    }

    // if (event.type == NSEventTypeScrollWheel)
    // {
    //     double wheel_dx = 0.0;
    //     double wheel_dy = 0.0;

    //     #if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    //     if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
    //     {
    //         wheel_dx = [event scrollingDeltaX];
    //         wheel_dy = [event scrollingDeltaY];
    //         if ([event hasPreciseScrollingDeltas])
    //         {
    //             wheel_dx *= 0.1;
    //             wheel_dy *= 0.1;
    //         }
    //     }
    //     else
    //     #endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    //     {
    //         wheel_dx = [event deltaX];
    //         wheel_dy = [event deltaY];
    //     }

    //     if (fabs(wheel_dx) > 0.0)
    //         io.MouseWheelH += wheel_dx * 0.1f;
    //     if (fabs(wheel_dy) > 0.0)
    //         io.MouseWheel += wheel_dy * 0.1f;
    //     return io.WantCaptureMouse;
    // }

    // // FIXME: All the key handling is wrong and broken. Refer to GLFW's cocoa_init.mm and cocoa_window.mm.
    // if (event.type == NSEventTypeKeyDown)
    // {
    //     NSString* str = [event characters];
    //     int len = (int)[str length];
    //     for (int i = 0; i < len; i++)
    //     {
    //         int c = [str characterAtIndex:i];
    //         if (!io.KeyCtrl && !(c >= 0xF700 && c <= 0xFFFF))
    //             io.AddInputCharacter((unsigned int)c);

    //         // We must reset in case we're pressing a sequence of special keys while keeping the command pressed
    //         int key = mapCharacterToKey(c);
    //         if (key != -1 && key < 256 && !io.KeyCtrl)
    //             resetKeys();
    //         if (key != -1)
    //             io.KeysDown[key] = true;
    //     }
    //     return io.WantCaptureKeyboard;
    // }

    // if (event.type == NSEventTypeKeyUp)
    // {
    //     NSString* str = [event characters];
    //     int len = (int)[str length];
    //     for (int i = 0; i < len; i++)
    //     {
    //         int c = [str characterAtIndex:i];
    //         int key = mapCharacterToKey(c);
    //         if (key != -1)
    //             io.KeysDown[key] = false;
    //     }
    //     return io.WantCaptureKeyboard;
    // }

    // if (event.type == NSEventTypeFlagsChanged)
    // {
    //     ImGuiIO& io = ImGui::GetIO();
    //     unsigned int flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;

    //     bool oldKeyCtrl = io.KeyCtrl;
    //     bool oldKeyShift = io.KeyShift;
    //     bool oldKeyAlt = io.KeyAlt;
    //     bool oldKeySuper = io.KeySuper;
    //     io.KeyCtrl      = flags & NSEventModifierFlagControl;
    //     io.KeyShift     = flags & NSEventModifierFlagShift;
    //     io.KeyAlt       = flags & NSEventModifierFlagOption;
    //     io.KeySuper     = flags & NSEventModifierFlagCommand;

    //     // We must reset them as we will not receive any keyUp event if they where pressed with a modifier
    //     if ((oldKeyShift && !io.KeyShift) || (oldKeyCtrl && !io.KeyCtrl) || (oldKeyAlt && !io.KeyAlt) || (oldKeySuper && !io.KeySuper))
    //         resetKeys();
    //     return io.WantCaptureKeyboard;
    // }

    return false
}
