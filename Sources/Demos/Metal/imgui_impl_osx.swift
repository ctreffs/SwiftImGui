//
//  imgui_impl_osx.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

import ImGui
import AppKit

var g_Time: CFAbsoluteTime = 0.0
var g_MouseCursors: [NSCursor?] = [NSCursor?](repeating: nil,
                                              count: Int(ImGuiMouseCursor_COUNT.rawValue))
var g_MouseCursorHidden: Bool = false

func ImGui_ImplOSX_Init() {
    let io = ImGuiGetIO()!
    
    io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DockingEnable.rawValue)
    io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DpiEnableScaleFonts.rawValue)
    io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DpiEnableScaleViewports.rawValue)
    //io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_ViewportsEnable.rawValue)
    
    // Setup back-end capabilities flags
    io.pointee.BackendFlags |= Int32(ImGuiBackendFlags_HasMouseCursors.rawValue)         // We can honor GetMouseCursor() values (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)
    //io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;    // We can create multi-viewports on the Platform side (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasMouseHoveredViewport; // We can set io.MouseHoveredViewport correctly (optional, not easy)
    "imgui_metal_osx".withCString {
        io.pointee.BackendPlatformName = $0
    }
    
    // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
    let offset_for_function_keys: Int32 = 256 - 0xF700
    
    CArray<ImGuiKey>.write(&io.pointee.KeyMap) { keyMap in
        keyMap[Int(ImGuiKey_Tab.rawValue)]             = Int32(Character("\t").asciiValue!)
        keyMap[Int(ImGuiKey_LeftArrow.rawValue)]       = Int32(NSLeftArrowFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_RightArrow.rawValue)]      = Int32(NSRightArrowFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_UpArrow.rawValue)]         = Int32(NSUpArrowFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_DownArrow.rawValue)]       = Int32(NSDownArrowFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_PageUp.rawValue)]          = Int32(NSPageUpFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_PageDown.rawValue)]        = Int32(NSPageDownFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_Home.rawValue)]            = Int32(NSHomeFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_End.rawValue)]             = Int32(NSEndFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_Insert.rawValue)]          = Int32(NSInsertFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_Delete.rawValue)]          = Int32(NSDeleteFunctionKey) + offset_for_function_keys
        keyMap[Int(ImGuiKey_Backspace.rawValue)]       = 127
        keyMap[Int(ImGuiKey_Space.rawValue)]           = 32
        keyMap[Int(ImGuiKey_Enter.rawValue)]           = 13
        keyMap[Int(ImGuiKey_Escape.rawValue)]          = 27
        keyMap[Int(ImGuiKey_KeyPadEnter.rawValue)]     = 13
        keyMap[Int(ImGuiKey_A.rawValue)]               = Int32(Character("A").asciiValue!)
        keyMap[Int(ImGuiKey_C.rawValue)]               = Int32(Character("C").asciiValue!)
        keyMap[Int(ImGuiKey_V.rawValue)]               = Int32(Character("V").asciiValue!)
        keyMap[Int(ImGuiKey_X.rawValue)]               = Int32(Character("X").asciiValue!)
        keyMap[Int(ImGuiKey_Y.rawValue)]               = Int32(Character("Y").asciiValue!)
        keyMap[Int(ImGuiKey_Z.rawValue)]               = Int32(Character("Z").asciiValue!)
    }
    
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
    
    // Note that ImGuicpp also include default OSX clipboard handlers which can be enabled
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
    let io = ImGuiGetIO()!
    
    
    if io.pointee.ConfigFlags == ImGuiConfigFlags(ImGuiConfigFlags_NoMouseCursorChange.rawValue) {
        return
    }
    
    let imgui_cursor: ImGuiMouseCursor = ImGuiGetMouseCursor()
    if (io.pointee.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None.rawValue) {
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

func set<T>(_ tuple: inout (T, T, T, T, T), value: T, at index: Int) {
    withUnsafeMutablePointer(to: &tuple.0) {
        $0[index] = value
    }
}

func get<T>(value tuple: inout (T, T, T, T, T), at index: Int) -> T {
    return withUnsafeMutablePointer(to: &tuple.0) {
        return $0[index]
    }
}

@discardableResult func ImGui_ImplOSX_HandleEvent(_ event: NSEvent, _ view: NSView) -> Bool {
    let io = ImGuiGetIO()!
    
    if event.type == .leftMouseDown || event.type == .rightMouseDown || event.type == .otherMouseDown {
        let button = event.buttonNumber
        CArray<Bool>.write(&io.pointee.MouseDown) { mouseButtons in
            if button >= 0 && button < mouseButtons.count {
                mouseButtons[Int(button)] = true
            }
        }
        return io.pointee.WantCaptureMouse
    }
    
    if event.type == .leftMouseUp || event.type == .rightMouseUp || event.type == .otherMouseUp {
        let button = event.buttonNumber
        CArray<Bool>.write(&io.pointee.MouseDown) { mouseButtons in
            if button >= 0 && button < mouseButtons.count {
                mouseButtons[button] = false
            }
        }
        return io.pointee.WantCaptureMouse
    }
    
    if event.type == .mouseMoved || event.type == .leftMouseDragged {
        var mousePoint = event.locationInWindow
        mousePoint = view.convert(mousePoint, from: nil)
        mousePoint = NSPoint(x: mousePoint.x, y: view.bounds.size.height - mousePoint.y)
        io.pointee.MousePos = ImVec2(x: Float(mousePoint.x), y: Float(mousePoint.y))
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
            io.pointee.MouseWheelH += wheel_dx * 0.1
        }
        
        if abs(wheel_dy) > 0.0 {
            io.pointee.MouseWheel += wheel_dy * 0.1
        }
        return io.pointee.WantCaptureMouse
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
        
        let oldKeyCtrl = io.pointee.KeyCtrl
        let oldKeyShift = io.pointee.KeyShift
        let oldKeyAlt = io.pointee.KeyAlt
        let oldKeySuper = io.pointee.KeySuper
        
        io.pointee.KeyCtrl = flags.contains(.control)
        io.pointee.KeyShift = flags.contains(.shift)
        io.pointee.KeyAlt = flags.contains(.option)
        io.pointee.KeySuper = flags.contains(.command)
        
        // We must reset them as we will not receive any keyUp event if they where pressed with a modifier
        if (oldKeyCtrl && !io.pointee.KeyCtrl) || (oldKeyShift && !io.pointee.KeyShift) || (oldKeyAlt && !io.pointee.KeyAlt) || (oldKeySuper && !io.pointee.KeySuper) {
            resetKeys()
        }
        return io.pointee.WantCaptureKeyboard
    }
    
    return false
}

func resetKeys() {
    let io = ImGuiGetIO()!
   
    CArray<Bool>.write(&io.pointee.KeysDown) { keysDown in
        for n in 0..<keysDown.count {
            keysDown[Int(n)] = false
        }
    }
    
}
