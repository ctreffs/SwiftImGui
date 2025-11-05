// Minimal AppKit backend target for Dear ImGui (modern input API)
// Target name: ImGuiOSXBackend
// Platform: macOS 13+
// Depends on: SwiftImGui product "ImGui"

import AppKit
import ImGui

// MARK: - Concurrency-safe global state

@MainActor private var gMouseCursorHidden = false
@MainActor private var gMouseCursors: [NSCursor?] = .init(repeating: nil, count: 10)

// MARK: - Public facade

public enum ImGuiOSXBackend {
  @MainActor
  @discardableResult
  public static func `init`(view: NSView) -> Bool {
    // Initialize IO flags and cursors
    guard let io = igGetIO() else { return false }
    io.pointee.BackendPlatformName = UnsafePointer(strdup("imgui_impl_osx_swiftim"))
    io.pointee.BackendFlags |= Int32(ImGuiBackendFlags_HasMouseCursors.rawValue)

    gMouseCursorHidden = false
    gMouseCursors = Array(repeating: nil, count: 10)
    gMouseCursors[Int(ImGuiMouseCursor_Arrow.rawValue)] = .arrow
    gMouseCursors[Int(ImGuiMouseCursor_TextInput.rawValue)] = .iBeam
    gMouseCursors[Int(ImGuiMouseCursor_Hand.rawValue)] = .pointingHand
    gMouseCursors[Int(ImGuiMouseCursor_ResizeNS.rawValue)] = .resizeUpDown
    gMouseCursors[Int(ImGuiMouseCursor_ResizeEW.rawValue)] = .resizeLeftRight
    return true
  }

  @MainActor
  public static func newFrame(view: NSView) {
    guard let io = igGetIO() else { return }
    let scale = view.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
    let size = view.bounds.size
    io.pointee.DisplaySize = ImVec2(x: Float(size.width), y: Float(size.height))
    io.pointee.DisplayFramebufferScale = ImVec2(x: Float(scale), y: Float(scale))
  }

  @MainActor
  public static func shutdown() {
    // Nothing to release (backed by AppKit)
  }

  @MainActor
  @discardableResult
  public static func handleEvent(_ event: NSEvent, in view: NSView) -> Bool {
    guard let io = igGetIO() else { return false }
    switch event.type {
    case .leftMouseDown, .rightMouseDown, .otherMouseDown:
      let button = mapButton(event)
      igAddMouseButtonEvent(button, true)
      return io.pointee.WantCaptureMouse
    case .leftMouseUp, .rightMouseUp, .otherMouseUp:
      let button = mapButton(event)
      igAddMouseButtonEvent(button, false)
      return io.pointee.WantCaptureMouse
    case .mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
      let pt = view.convert(event.locationInWindow, from: nil)
      igAddMousePosEvent(Float(pt.x), Float(pt.y))
      return io.pointee.WantCaptureMouse
    case .scrollWheel:
      igAddMouseWheelEvent(0, Float(event.scrollingDeltaY))
      return io.pointee.WantCaptureMouse
    case .flagsChanged, .keyDown, .keyUp:
      if let chars = event.charactersIgnoringModifiers { igIOAddInputCharactersUTF8(io, chars) }
      return io.pointee.WantCaptureKeyboard
    default:
      return false
    }
  }
}

// MARK: - Helpers

@MainActor
private func mapButton(_ e: NSEvent) -> Int32 {
  switch e.buttonNumber {
  case 0: return 0
  case 1: return 1
  case 2: return 2
  default: return Int32(e.buttonNumber)
  }
}

