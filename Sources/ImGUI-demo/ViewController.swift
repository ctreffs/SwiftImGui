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

    }
}
