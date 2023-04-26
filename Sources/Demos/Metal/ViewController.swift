//
//  ViewController.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

import AppKit
import Metal
import MetalKit

@available(OSX 10.11, *)
final class ViewController: NSViewController {
    let mtkView = MTKView()
    lazy var renderer = Renderer(mtkView)

    override func loadView() {
        mtkView.wantsLayer = true
        mtkView.layer!.backgroundColor = .black
        view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = renderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.bounds.size)

        // Add a tracking area in order to receive mouse events whenever the mouse is within the bounds of our view
        let trackingArea = NSTrackingArea(rect: .zero,
                                          options: [.mouseMoved, .inVisibleRect, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        view.addTrackingArea(trackingArea)

        // If we want to receive key events, we either need to be in the responder chain of the key view,
        // or else we can install a local monitor. The consequence of this heavy-handed approach is that
        // we receive events for all controls, not just Dear ImGui widgets. If we had native controls in our
        // window, we'd want to be much more careful than just ingesting the complete event stream, though we
        // do make an effort to be good citizens by passing along events when Dear ImGui doesn't want to capture.
        let eventMask: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]
        NSEvent.addLocalMonitorForEvents(matching: eventMask) { [unowned self] event -> NSEvent? in
            ImGui_ImplOSX_HandleEvent(event, view)
            return event
        }

        ImGui_ImplOSX_Init(view)
    }

    deinit {
        ImGui_ImplOSX_Shutdown()
    }

    override func mouseMoved(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, view)
    }

    override func mouseDown(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, view)
    }

    override func mouseUp(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, view)
    }

    override func mouseDragged(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, view)
    }

    override func scrollWheel(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, view)
    }
}
