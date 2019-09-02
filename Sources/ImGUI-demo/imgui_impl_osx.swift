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
var g_MouseCursors: [NSCursor?] = [NSCursor?](repeating: nil,
                                              count: Int(ImGuiMouseCursor_COUNT.rawValue))
var g_MouseCursorHidden: Bool = false

func ImGui_ImplOSX_Init() {
    let ioRef = igGetIO()!
    var io: ImGuiIO = ioRef.pointee

    // Setup back-end capabilities flags
    io.BackendFlags |= Int32(ImGuiBackendFlags_HasMouseCursors.rawValue)         // We can honor GetMouseCursor() values (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)
    //io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;    // We can create multi-viewports on the Platform side (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasMouseHoveredViewport; // We can set io.MouseHoveredViewport correctly (optional, not easy)
    io.BackendPlatformName = "imgui_metal_osx".cStrPtr()

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
    let offset_for_function_keys: Int32 = 256 - 0xF700
    var keyMap = CArray(&io.KeyMap)

    keyMap[ImGuiKey_Tab]             = Int32(Character("\t").asciiValue!)
    keyMap[ImGuiKey_LeftArrow]       = Int32(NSLeftArrowFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_RightArrow]      = Int32(NSRightArrowFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_UpArrow]         = Int32(NSUpArrowFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_DownArrow]       = Int32(NSDownArrowFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_PageUp]          = Int32(NSPageUpFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_PageDown]        = Int32(NSPageDownFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_Home]            = Int32(NSHomeFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_End]             = Int32(NSEndFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_Insert]          = Int32(NSInsertFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_Delete]          = Int32(NSDeleteFunctionKey) + offset_for_function_keys
    keyMap[ImGuiKey_Backspace]       = 127
    keyMap[ImGuiKey_Space]           = 32
    keyMap[ImGuiKey_Enter]           = 13
    keyMap[ImGuiKey_Escape]          = 27
    keyMap[ImGuiKey_KeyPadEnter]     = 13
    keyMap[ImGuiKey_A]               = Int32(Character("A").asciiValue!)
    keyMap[ImGuiKey_C]               = Int32(Character("C").asciiValue!)
    keyMap[ImGuiKey_V]               = Int32(Character("V").asciiValue!)
    keyMap[ImGuiKey_X]               = Int32(Character("X").asciiValue!)
    keyMap[ImGuiKey_Y]               = Int32(Character("Y").asciiValue!)
    keyMap[ImGuiKey_Z]               = Int32(Character("Z").asciiValue!)

    // Load cursors. Some of them are undocumented.
    g_MouseCursorHidden = false
    g_MouseCursors[ImGuiMouseCursor_Arrow] = NSCursor.arrow
    g_MouseCursors[ImGuiMouseCursor_TextInput] = NSCursor.iBeam
    g_MouseCursors[ImGuiMouseCursor_ResizeAll] = NSCursor.closedHand
    g_MouseCursors[ImGuiMouseCursor_Hand] = NSCursor.pointingHand
    g_MouseCursors[ImGuiMouseCursor_ResizeNS] = NSCursor.resizeUpDown
    //[NSCursor respondsToSelector:@selector(_windowResizeNorthSouthCursor)] ? [NSCursor _windowResizeNorthSouthCursor] : [NSCursor resizeUpDownCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeEW] = NSCursor.resizeLeftRight
    //[NSCursor respondsToSelector:@selector(_windowResizeEastWestCursor)] ? [NSCursor _windowResizeEastWestCursor] : [NSCursor resizeLeftRightCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = NSCursor.closedHand
    //[NSCursor respondsToSelector:@selector(_windowResizeNorthEastSouthWestCursor)] ? [NSCursor _windowResizeNorthEastSouthWestCursor] : [NSCursor closedHandCursor];
    g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = NSCursor.closedHand
    //[NSCursor respondsToSelector:@selector(_windowResizeNorthWestSouthEastCursor)] ? [NSCursor _windowResizeNorthWestSouthEastCursor] : [NSCursor closedHandCursor];

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
    var io = ImGui.GetIO()
    defer {
        ImGui.SetIO(to: &io)
    }

    if io.ConfigFlags == Int32(ImGuiConfigFlags_NoMouseCursorChange.rawValue) {
        return
    }

    let imgui_cursor: ImGuiMouseCursor = ImGui.GetMouseCursor()
    if (io.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None.rawValue) {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        if !g_MouseCursorHidden {
            g_MouseCursorHidden = true
            NSCursor.hide()
        }
    } else {
        // Show OS mouse cursor
        let index: Int = g_MouseCursors[Int(imgui_cursor)] == nil ? Int(imgui_cursor) : Int(ImGuiMouseCursor_Arrow.rawValue)
        g_MouseCursors[index]!.set()
        if g_MouseCursorHidden {
            g_MouseCursorHidden = false
            NSCursor.unhide()
        }
    }
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

    if event.type == .scrollWheel {
        var wheel_dx: Float = 0.0
        var wheel_dy: Float = 0.0

        wheel_dx = Float(event.scrollingDeltaX)
        wheel_dy = Float(event.scrollingDeltaY)

        if event.hasPreciseScrollingDeltas {
            wheel_dx *= 0.1
            wheel_dy *= 0.1
        }

        if abs(wheel_dx) > 0.0 {
            io.MouseWheelH += wheel_dx * 0.1
        }

        if abs(wheel_dy) > 0.0 {
            io.MouseWheel += wheel_dy * 0.1
        }
        return io.WantCaptureMouse
    }

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

    if event.type == .flagsChanged {
        let flags: NSEvent.ModifierFlags = event.modifierFlags.union(.deviceIndependentFlagsMask)

        let oldKeyCtrl = io.KeyCtrl
        let oldKeyShift = io.KeyShift
        let oldKeyAlt = io.KeyAlt
        let oldKeySuper = io.KeySuper

        io.KeyCtrl = flags.contains(.control)
        io.KeyShift = flags.contains(.shift)
        io.KeyAlt = flags.contains(.option)
        io.KeySuper = flags.contains(.command)

        // We must reset them as we will not receive any keyUp event if they where pressed with a modifier
        if (oldKeyCtrl && !io.KeyCtrl) || (oldKeyShift && !io.KeyShift) || (oldKeyAlt && !io.KeyAlt) || (oldKeySuper && !io.KeySuper) {
            resetKeys()
        }
        return io.WantCaptureKeyboard
    }

    return false
}

func resetKeys() {
    var io = ImGui.GetIO()
    defer {
        ImGui.SetIO(to: &io)
    }
    var keysDown = CArray(&io.KeysDown)
    for n in 0..<keysDown.count {
        keysDown[n] = false
    }
}
