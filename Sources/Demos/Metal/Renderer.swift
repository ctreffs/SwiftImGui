//
//  Renderer.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

import ImGui
import Metal
import MetalKit

var show_demo_window: Bool = true
var show_another_window: Bool = false
var clear_color: SIMD3<Float> = .init(x: 0.28, y: 0.36, z: 0.5)
var f: Float = 0.0
var counter: Int = 0

@available(OSX 10.11, *)
final class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    init(_ view: MTKView) {
        self.device = view.device!
        commandQueue = device.makeCommandQueue()!

        //        precondition(!ImGuiDebugCheckVersionAndDataLayout())

        
        _ = ImGuiCreateContext(nil)
        ImGuiStyleColorsDark(nil)

        ImGui_ImplMetal_Init(device)
    }
}

@available(OSX 10.11, *)
extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard view.bounds.size.width > 0 && view.bounds.size.height > 0 else {
            return
        }
        autoreleasepool {
            let io = ImGuiGetIO()!

            io.pointee.DisplaySize.x = Float(view.bounds.size.width)
            io.pointee.DisplaySize.y = Float(view.bounds.size.height)

            let frameBufferScale = Float(view.window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)

            io.pointee.DisplayFramebufferScale = ImVec2(x: frameBufferScale, y: frameBufferScale)
            io.pointee.DeltaTime = 1.0 / Float(view.preferredFramesPerSecond)

            

            let commandBuffer = commandQueue.makeCommandBuffer()!

            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
            }

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: Double(clear_color.x),
                                                                                green: Double(clear_color.x),
                                                                                blue: Double(clear_color.z),
                                                                                alpha: 1.0)

            // Here, you could do additional rendering work, including other passes as necessary.

            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.pushDebugGroup("ImGui demo")

            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor)
            ImGui_ImplOSX_NewFrame(view)
            ImGuiNewFrame()

            // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()!
            // You can browse its code to learn more about Dear ImGui!).
            if show_demo_window {
                ImGuiShowDemoWindow(&show_demo_window)
            }

            // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.

            // Create a window called "Hello, world!" and append into it.
            ImGuiBegin("Hello, world!", &show_demo_window, 0)

            // Display some text (you can use a format strings too)
            ImGuiTextV("This is some useful text.")

            // Edit bools storing our window open/close state
            ImGuiCheckbox("Demo Window", &show_demo_window)
            ImGuiCheckbox("Another Window", &show_another_window)

            ImGuiSliderFloat("Float Slider", &f, 0.0, 1.0, nil, 1) // Edit 1 float using a slider from 0.0f to 1.0f

            ImGuiColorEdit3("clear color", &clear_color, 0) // Edit 3 floats representing a color

            if ImGuiButton("Button", ImVec2(x: 0,y: 0)) { // Buttons return true when clicked (most widgets return true when edited/activated)
                counter += 1
            }

            //SameLine(offset_from_start_x: 0, spacing: 0)

            ImGuiSameLine(0, 2)
            ImGuiTextV(String(format: "counter = %d", counter))

            let avg: Float = (1000.0 / io.pointee.Framerate)
            let fps = io.pointee.Framerate
            
            ImGuiTextV(String(format: "Application average %.3f ms/frame (%.1f FPS)", avg, fps))
                              

            ImGuiEnd()
            //End()

            // 3. Show another simple window.
            if show_another_window {

                ImGuiBegin("Another Window", &show_another_window, 0)  // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)

                ImGuiTextV("Hello from another window!")
                if ImGuiButton("Close Me", ImVec2(x: 0, y: 0)) {
                    show_another_window = false
                }
                ImGuiEnd()
            }

            // Rendering
            ImGuiRender()
            let drawData = ImGuiGetDrawData()!

            ImGui_ImplMetal_RenderDrawData(drawData.pointee, commandBuffer, renderEncoder)
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            commandBuffer.present(view.currentDrawable!)

            commandBuffer.commit()

        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function, size)
    }

}
