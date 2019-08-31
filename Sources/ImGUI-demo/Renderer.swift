//
//  Renderer.swift
//  
//
//  Created by Christian Treffs on 31.08.19.
//

import ImGUI
import CImGUI
import Metal
import MetalKit

@available(OSX 10.11, *)
final class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    init(_ view: MTKView) {
        self.device = view.device!
        commandQueue = device.makeCommandQueue()!

        precondition(!ImGui.DebugCheckVersionAndDataLayout())

        ImGui.CreateContext()
        ImGui.StyleColorsDark()

        ImGui_ImplMetal_Init(device)
    }
}

@available(OSX 10.11, *)
extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {

    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function, size)
    }

}
