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
        self.view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = self.renderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.bounds.size)

        // Add a tracking area in order to receive mouse events whenever the mouse is within the bounds of our view
        let trackingArea: NSTrackingArea = NSTrackingArea(rect: .zero,
                                                          options: [.mouseMoved, .inVisibleRect, .activeAlways],
                                                          owner: self,
                                                          userInfo: nil)
        view.addTrackingArea(trackingArea)

        // If we want to receive key events, we either need to be in the responder chain of the key view,
        // or else we can install a local monitor. The consequence of this heavy-handed approach is that
        // we receive events for all controls, not just Dear ImGui widgets. If we had native controls in our
        // window, we'd want to be much more careful than just ingesting the complete event stream, though we
        // do make an effort to be good citizens by passing along events when Dear ImGui doesn't want to capture.
        let eventMask: NSEvent.EventTypeMask = [ .keyDown, .keyUp, .flagsChanged, .scrollWheel ]
        NSEvent.addLocalMonitorForEvents(matching: eventMask) { [unowned self](event) -> NSEvent? in
            let wantsCapture: Bool = ImGui_ImplOSX_HandleEvent(event, self.view)
            if event.type == .keyDown && wantsCapture {
                return nil
            } else {
                return event
            }
        }

        ImGui_ImplOSX_Init()
    }

    override func mouseMoved(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, self.view)
    }

    override func mouseDown(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, self.view)
    }

    override func mouseUp(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, self.view)
    }

    override func mouseDragged(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, self.view)
    }

    override func scrollWheel(with event: NSEvent) {
        ImGui_ImplOSX_HandleEvent(event, self.view)
    }
}
