//
//  imgui_impl_osx.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//  Updated by Junhao Wang on 30.12.21.
//

import AppKit
import Carbon
import GameController
import ImGui

// CHANGELOG
//  2021-12-30: Update functions as defined in v1.86. Add NSView parameter to ImGui_ImplOSX_Init().
//              Generally fix keyboard support. Using kVK_* codes for keyboard keys.
//              Add game controller and text clipboard support.
//     Earlier: Check the original backend file written in Objective-C in ocornut/imgui.

// Data
private var g_HostClockPeriod: Double = 0.0
private var g_Time: CFAbsoluteTime = 0.0 // Original approach uses: Double
private var g_MouseCursorHidden: Bool = false

private var g_MouseCursors: [NSCursor?] = .init(repeating: nil, count: Int(ImGuiMouseCursor_COUNT.rawValue))
private var g_MouseJustPressed: [Bool] = .init(repeating: false, count: Int(ImGuiMouseButton_COUNT.rawValue))
private var g_MouseDown: [Bool] = .init(repeating: false, count: Int(ImGuiMouseButton_COUNT.rawValue))

private var g_FocusObserver: ImFocusObserver?
private var g_KeyEventResponder: KeyEventResponder?

private var s_clipboard: UnsafeMutablePointer<CChar>?

// MARK: - Functions

@discardableResult
func ImGui_ImplOSX_Init(_ view: NSView) -> Bool {
    let io = ImGuiGetIO()!

    // io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DockingEnable.rawValue)
    // io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DpiEnableScaleViewports.rawValue)
    // io.pointee.ConfigFlags |= Int32(ImGuiConfigFlags_DpiEnableScaleFonts.rawValue)

    // Setup back-end capabilities flags
    io.pointee.BackendFlags |= Int32(ImGuiBackendFlags_HasMouseCursors.rawValue) // We can honor GetMouseCursor() values (optional)
    // io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)
    // io.BackendFlags |= ImGuiBackendFlags_PlatformHasViewports;    // We can create multi-viewports on the Platform side (optional)
    // io.BackendFlags |= ImGuiBackendFlags_HasMouseHoveredViewport; // We can set io.MouseHoveredViewport correctly (optional, not easy)
    "imgui_metal_osx".withCString {
        io.pointee.BackendPlatformName = $0
    }

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
    CArray<ImGuiKey>.write(&io.pointee.KeyMap) { keyMap in
        keyMap[Int(ImGuiKey_Tab.rawValue)] = ImGuiKey(kVK_Tab)
        keyMap[Int(ImGuiKey_LeftArrow.rawValue)] = ImGuiKey(kVK_LeftArrow)
        keyMap[Int(ImGuiKey_RightArrow.rawValue)] = ImGuiKey(kVK_RightArrow)
        keyMap[Int(ImGuiKey_UpArrow.rawValue)] = ImGuiKey(kVK_UpArrow)
        keyMap[Int(ImGuiKey_DownArrow.rawValue)] = ImGuiKey(kVK_DownArrow)
        keyMap[Int(ImGuiKey_PageUp.rawValue)] = ImGuiKey(kVK_PageUp)
        keyMap[Int(ImGuiKey_PageDown.rawValue)] = ImGuiKey(kVK_PageDown)
        keyMap[Int(ImGuiKey_Home.rawValue)] = ImGuiKey(kVK_Home)
        keyMap[Int(ImGuiKey_End.rawValue)] = ImGuiKey(kVK_End)
        keyMap[Int(ImGuiKey_Insert.rawValue)] = ImGuiKey(kVK_F13)
        keyMap[Int(ImGuiKey_Delete.rawValue)] = ImGuiKey(kVK_ForwardDelete)
        keyMap[Int(ImGuiKey_Backspace.rawValue)] = ImGuiKey(kVK_Delete)
        keyMap[Int(ImGuiKey_Space.rawValue)] = ImGuiKey(kVK_Space)
        keyMap[Int(ImGuiKey_Enter.rawValue)] = ImGuiKey(kVK_Return)
        keyMap[Int(ImGuiKey_Escape.rawValue)] = ImGuiKey(kVK_Escape)
        keyMap[Int(ImGuiKey_KeypadEnter.rawValue)] = ImGuiKey(kVK_ANSI_KeypadEnter)
        keyMap[Int(ImGuiKey_A.rawValue)] = ImGuiKey(kVK_ANSI_A)
        keyMap[Int(ImGuiKey_C.rawValue)] = ImGuiKey(kVK_ANSI_C)
        keyMap[Int(ImGuiKey_V.rawValue)] = ImGuiKey(kVK_ANSI_V)
        keyMap[Int(ImGuiKey_X.rawValue)] = ImGuiKey(kVK_ANSI_X)
        keyMap[Int(ImGuiKey_Y.rawValue)] = ImGuiKey(kVK_ANSI_Y)
        keyMap[Int(ImGuiKey_Z.rawValue)] = ImGuiKey(kVK_ANSI_Z)
    }

    // Load cursors. Some of them are undocumented.
    g_MouseCursorHidden = false

    g_MouseCursors[ImGuiMouseCursor_Arrow] = NSCursor.arrow
    g_MouseCursors[ImGuiMouseCursor_TextInput] = NSCursor.iBeam
    g_MouseCursors[ImGuiMouseCursor_ResizeAll] = NSCursor.closedHand
    g_MouseCursors[ImGuiMouseCursor_Hand] = NSCursor.pointingHand
    g_MouseCursors[ImGuiMouseCursor_NotAllowed] = NSCursor.operationNotAllowed
    g_MouseCursors[ImGuiMouseCursor_ResizeNS] = NSCursor.resizeUpDown
    g_MouseCursors[ImGuiMouseCursor_ResizeEW] = NSCursor.resizeLeftRight
    g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = NSCursor.closedHand
    g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = NSCursor.closedHand

    // Note that ImGuicpp also include default OSX clipboard handlers which can be enabled
    // by adding '#define IMGUI_ENABLE_OSX_DEFAULT_CLIPBOARD_FUNCTIONS' in imconfig.h and adding '-framework ApplicationServices' to your linker command-line.
    // Since we are already in ObjC land here, it is easy for us to add a clipboard handler using the NSPasteboard api.
    io.pointee.SetClipboardTextFn = { _, cStr in
        if let s = cStr {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(String(cString: s), forType: .string)
        }
    }

    io.pointee.GetClipboardTextFn = { _ -> UnsafePointer<CChar>? in
        let pasteboard = NSPasteboard.general
        let available = pasteboard.availableType(from: [.string])

        guard available != nil, available! == .string else {
            return nil
        }

        guard let string = pasteboard.string(forType: .string) else {
            return nil
        }

        /* Original code
         const char* string_c = (const char*)[string UTF8String];
         size_t string_len = strlen(string_c);
         static ImVector<char> s_clipboard;
         s_clipboard.resize((int)string_len + 1);
         strcpy(s_clipboard.Data, string_c);
         return s_clipboard.Data;
         */
        // https://stackoverflow.com/questions/55933537/create-a-string-buffer-in-swift-for-c-to-consume-and-free-later
        if let clipboard = s_clipboard {
            free(clipboard)
        }
        s_clipboard = strdup(string)
        return UnsafePointer<CChar>(s_clipboard)
    }

    g_FocusObserver = ImFocusObserver()
    NotificationCenter.default.addObserver(g_FocusObserver!,
                                           selector: #selector(g_FocusObserver!.onApplicationBecomeActive),
                                           name: NSApplication.didBecomeActiveNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(g_FocusObserver!,
                                           selector: #selector(g_FocusObserver!.onApplicationBecomeInactive),
                                           name: NSApplication.didResignActiveNotification,
                                           object: nil)

    // Add the NSTextInputClient to the view hierarchy,
    // to receive keyboard events and translate them to input text.

    g_KeyEventResponder = KeyEventResponder(frame: NSZeroRect)
    view.addSubview(g_KeyEventResponder!)

    return true
}

func ImGui_ImplOSX_Shutdown() {
    g_FocusObserver = nil

    if let clipboard = s_clipboard {
        free(clipboard)
    }
}

func ImGui_ImplOSX_NewFrame(_ view: NSView) {
    // Setup display size
    let ioRef = igGetIO()!
    var io: ImGuiIO = ioRef.pointee

    let dpi = Float(view.window?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)
    io.DisplaySize = ImVec2(x: Float(view.bounds.size.width), y: Float(view.bounds.size.height))
    io.DisplayFramebufferScale = ImVec2(x: dpi, y: dpi)

    // Setup time step
    if g_Time == 0.0 {
        g_Time = CFAbsoluteTimeGetCurrent()
    }
    let current_time: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

    /* Original approach
     if g_Time == 0.0 {
     InitHostClockPerioid()
     g_Time = GetMachAbsoluteTimeInSeconds()
     }
     let current_time: Double = GetMachAbsoluteTimeInSeconds()
     */

    io.DeltaTime = Float(current_time - g_Time)
    g_Time = current_time

    ImGui_ImplOSX_UpdateMouseCursorAndButtons()
    ImGui_ImplOSX_UpdateGamepads()
}

@discardableResult
func ImGui_ImplOSX_HandleEvent(_ event: NSEvent, _ view: NSView) -> Bool {
    let io = ImGuiGetIO()!

    if event.type == .leftMouseDown || event.type == .rightMouseDown || event.type == .otherMouseDown {
        let button = event.buttonNumber
        if button >= 0, button < g_MouseDown.count {
            g_MouseDown[Int(button)] = true
            g_MouseJustPressed[Int(button)] = true
        }
        return io.pointee.WantCaptureMouse
    }

    if event.type == .leftMouseUp || event.type == .rightMouseUp || event.type == .otherMouseUp {
        let button = event.buttonNumber
        if button >= 0, button < g_MouseDown.count {
            g_MouseDown[button] = false
        }
        return io.pointee.WantCaptureMouse
    }

    if event.type == .mouseMoved || event.type == .leftMouseDragged || event.type == .rightMouseDragged || event.type == .otherMouseDragged {
        var mousePoint = event.locationInWindow
        mousePoint = view.convert(mousePoint, from: nil)
        mousePoint = NSPoint(x: mousePoint.x, y: view.bounds.size.height - mousePoint.y)
        io.pointee.MousePos = ImVec2(x: Float(mousePoint.x), y: Float(mousePoint.y))
    }

    if event.type == .scrollWheel {
        /// Ignore canceled events.
        ///
        /// From macOS 12.1, scrolling with two fingers and then decelerating
        /// by tapping two fingers results in two events appearing:
        ///
        /// 1. A scroll wheel NSEvent, with a phase == NSEventPhaseMayBegin, when the user taps
        /// two fingers to decelerate or stop the scroll events.
        ///
        /// 2. A scroll wheel NSEvent, with a phase == NSEventPhaseCancelled, when the user releases the
        /// two-finger tap. It is this event that sometimes contains large values for scrollingDeltaX and
        /// scrollingDeltaY. When these are added to the current x and y positions of the scrolling view,
        /// it appears to jump up or down. It can be observed in Preview, various JetBrains IDEs and here.
        if event.phase == .cancelled {
            return false
        }

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

    if event.type == .keyDown || event.type == .keyUp {
        let code: UInt16 = event.keyCode
        CArray<Bool>.write(&io.pointee.KeysDown) { keyCodes in
            if code >= 0, code < keyCodes.count {
                keyCodes[Int(code)] = event.type == .keyDown
            }
        }
        let flags: NSEvent.ModifierFlags = event.modifierFlags
        io.pointee.KeyCtrl = flags.contains(.control)
        io.pointee.KeyShift = flags.contains(.shift)
        io.pointee.KeyAlt = flags.contains(.option)
        io.pointee.KeySuper = flags.contains(.command)
        return io.pointee.WantCaptureKeyboard
    }

    if event.type == .flagsChanged {
        let flags: NSEvent.ModifierFlags = event.modifierFlags.union(.deviceIndependentFlagsMask)

        let keyCode = Int(event.keyCode)

        switch keyCode {
        case kVK_Control:
            io.pointee.KeyCtrl = flags.contains(.control)
        case kVK_Shift:
            io.pointee.KeyShift = flags.contains(.shift)
        case kVK_Option:
            io.pointee.KeyAlt = flags.contains(.option)
        case kVK_Command:
            io.pointee.KeySuper = flags.contains(.command)
        default:
            return false
        }

        return io.pointee.WantCaptureKeyboard
    }

    return false
}

// MARK: - Fileprivate(static) functions

private func ImGui_ImplOSX_UpdateMouseCursorAndButtons() {
    // Update buttons
    let io = ImGuiGetIO()!

    CArray<Bool>.write(&io.pointee.MouseDown) { mouseButtons in
        // If a mouse press event came, always pass it as "mouse held this frame",
        // so we don't miss click-release events that are shorter than 1 frame.
        for n in 0 ..< mouseButtons.count {
            mouseButtons[n] = g_MouseJustPressed[n] || g_MouseDown[n]
            g_MouseJustPressed[n] = false
        }
    }

    guard io.pointee.ConfigFlags & Int32(ImGuiConfigFlags_NoMouseCursorChange.rawValue) != 0 else {
        return
    }

    let imgui_cursor: ImGuiMouseCursor = ImGuiGetMouseCursor()
    if io.pointee.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None.rawValue {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        if !g_MouseCursorHidden {
            g_MouseCursorHidden = true
            NSCursor.hide()
        }
    } else {
        let desired: NSCursor! = g_MouseCursors[Int(imgui_cursor)] ?? g_MouseCursors[ImGuiMouseCursor_Arrow]
        // -NSCursor.set generates measureable overhead if called unconditionally.
        if desired.isNotEqual(to: NSCursor.current) {
            desired.set()
        }
        if g_MouseCursorHidden {
            g_MouseCursorHidden = false
            NSCursor.unhide()
        }
    }
}

private func ImGui_ImplOSX_UpdateGamepads() {
    let io = ImGuiGetIO()!

    CArray<Float>.write(&io.pointee.NavInputs) { navInputs in
        for n in 0 ..< navInputs.count {
            navInputs[Int(n)] = 0.0
        }
    }

    guard (io.pointee.ConfigFlags & Int32(ImGuiConfigFlags_NavEnableGamepad.rawValue)) != 0 else {
        return
    }

    var controller: GCController?

    if #available(macOS 11.0, *) {
        controller = GCController.current
    } else {
        controller = GCController.controllers().first
    }

    guard let gp = controller?.extendedGamepad else {
        io.pointee.BackendFlags &= Int32(ImGuiBackendFlags_HasGamepad.rawValue)
        return
    }

    CArray<Float>.write(&io.pointee.NavInputs) { navInput in
        navInput[Int(ImGuiNavInput_Activate.rawValue)] = gp.buttonA.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_Cancel.rawValue)] = gp.buttonB.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_Menu.rawValue)] = gp.buttonX.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_Input.rawValue)] = gp.buttonY.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_DpadLeft.rawValue)] = gp.dpad.left.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_DpadRight.rawValue)] = gp.dpad.right.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_DpadUp.rawValue)] = gp.dpad.up.isPressed ? 1.0 : 0.0
        navInput[Int(ImGuiNavInput_DpadDown.rawValue)] = gp.dpad.down.isPressed ? 1.0 : 0.0

        navInput[Int(ImGuiNavInput_LStickLeft.rawValue)] = gp.leftThumbstick.left.value
        navInput[Int(ImGuiNavInput_LStickRight.rawValue)] = gp.leftThumbstick.right.value
        navInput[Int(ImGuiNavInput_LStickUp.rawValue)] = gp.leftThumbstick.up.value
        navInput[Int(ImGuiNavInput_LStickDown.rawValue)] = gp.leftThumbstick.down.value
    }

    io.pointee.BackendFlags |= Int32(ImGuiBackendFlags_HasGamepad.rawValue)
}

private func resetKeys() {
    let io = ImGuiGetIO()!

    CArray<Bool>.write(&io.pointee.KeysDown) { keysDown in
        for n in 0 ..< keysDown.count {
            keysDown[Int(n)] = false
        }
    }
}

private func InitHostClockPerioid() {
    var info = mach_timebase_info()
    mach_timebase_info(&info)

    // Period is the reciprocal of frequency.
    g_HostClockPeriod = 1e-9 * (Double(info.denom) / Double(info.numer))
}

private func GetMachAbsoluteTimeInSeconds() -> Double {
    Double(mach_absolute_time()) * g_HostClockPeriod
}

// MARK: - Extensions and Classes

/**
 KeyEventResponder implements the NSTextInputClient protocol as is required by the macOS text input manager.
 The macOS text input manager is invoked by calling the interpretKeyEvents method from the keyDown method.
 Keyboard events are then evaluated by the macOS input manager and valid text input is passed back via the
 insertText:replacementRange method.
 This is the same approach employed by other cross-platform libraries such as SDL2:
 https://github.com/spurious/SDL-mirror/blob/e17aacbd09e65a4fd1e166621e011e581fb017a8/src/video/cocoa/SDL_cocoakeyboard.m#L53
 and GLFW:
 https://github.com/glfw/glfw/blob/b55a517ae0c7b5127dffa79a64f5406021bf9076/src/cocoa_window.m#L722-L723
 */
class KeyEventResponder: NSView {}

extension KeyEventResponder: NSTextInputClient {
    override func viewDidMoveToWindow() {
        // Ensure self is a first responder to receive the input events.
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        // Call to the macOS input manager system.
        interpretKeyEvents([event])
    }

    func insertText(_ string: Any, replacementRange _: NSRange) {
        var characters: String?

        if let str = string as? NSAttributedString {
            characters = str.string
        } else {
            characters = string as? String
        }

        ImGuiIO_AddInputCharactersUTF8(ImGuiGetIO()!, characters)
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func doCommand(by _: Selector) {}

    func attributedSubstring(forProposedRange _: NSRange, actualRange _: NSRangePointer?) -> NSAttributedString? {
        nil
    }

    func characterIndex(for _: NSPoint) -> Int {
        0
    }

    func firstRect(forCharacterRange _: NSRange, actualRange _: NSRangePointer?) -> NSRect {
        NSZeroRect
    }

    func hasMarkedText() -> Bool {
        false
    }

    func markedRange() -> NSRange {
        NSMakeRange(NSNotFound, 0)
    }

    func selectedRange() -> NSRange {
        NSMakeRange(NSNotFound, 0)
    }

    func setMarkedText(_: Any, selectedRange _: NSRange, replacementRange _: NSRange) {}

    func unmarkText() {}

    func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        []
    }
}

class ImFocusObserver: NSObject {
    @objc func onApplicationBecomeActive(_: Notification) {
        ImGuiIO_AddFocusEvent(ImGuiGetIO()!, true)
    }

    @objc func onApplicationBecomeInactive(_: Notification) {
        ImGuiIO_AddFocusEvent(ImGuiGetIO()!, false)

        // Unfocused applications do not receive input events, therefore we must manually
        // release any pressed keys when application loses focus, otherwise they would remain
        // stuck in a pressed state. https://github.com/ocornut/imgui/issues/3832
        resetKeys()
    }
}

private extension ImGuiKey {
    init(_ int: Int) {
        self.init(rawValue: UInt32(int))
    }
}
