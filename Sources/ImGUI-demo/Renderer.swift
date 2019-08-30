//
//  Renderer.swift
//  
//
//  Created by Christian Treffs on 31.08.19.
//

import Metal
import MetalKit

@available(OSX 10.11, *)
final class Renderer: NSObject {
    init(_ view: MTKView) {

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
