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

var show_demo_window: Bool = true
var show_another_window: Bool = false
var clear_color: [Float] = [0.28, 0.36, 0.5]
var f: Float = 0.0
var counter: Int = 0

@available(OSX 10.11, *)
final class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    init(_ view: MTKView) {
        self.device = view.device!
        commandQueue = device.makeCommandQueue()!

        //        precondition(!ImGui.DebugCheckVersionAndDataLayout())

        ImGui.CreateContext()
        ImGui.StyleColorsDark()

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
            var io: ImGuiIO = ImGui.GetIO()

            io.DisplaySize.x = Float(view.bounds.size.width)
            io.DisplaySize.y = Float(view.bounds.size.height)

            let frameBufferScale = Float(view.window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)

            io.DisplayFramebufferScale = ImVec2(x: frameBufferScale, y: frameBufferScale)
            io.DeltaTime = 1.0 / Float(view.preferredFramesPerSecond)

            ImGui.SetIO(to: &io)

            let commandBuffer = commandQueue.makeCommandBuffer()!

            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
            }

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: Double(clear_color[0]),
                                                                                green: Double(clear_color[1]),
                                                                                blue: Double(clear_color[2]),
                                                                                alpha: 1.0)

            // Here, you could do additional rendering work, including other passes as necessary.

            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.pushDebugGroup("ImGui demo")

            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor)
            ImGui_ImplOSX_NewFrame(view)
            ImGui.NewFrame()

            // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()!
            // You can browse its code to learn more about Dear ImGui!).
            if show_demo_window {
                ImGui.ShowDemoWindow(&show_demo_window)
            }

            // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.

            // Create a window called "Hello, world!" and append into it.
            ImGui.Begin("Hello, world!")

            // Display some text (you can use a format strings too)
            ImGui.Text("This is some useful text.")

            // Edit bools storing our window open/close state
            ImGui.Checkbox("Demo Window", &show_demo_window)
            ImGui.Checkbox("Another Window", &show_another_window)

            ImGui.SliderFloat("float", &f, 0.0, 1.0) // Edit 1 float using a slider from 0.0f to 1.0f

            ImGui.ColorEdit3("clear color", &clear_color); // Edit 3 floats representing a color

            if ImGui.Button("Button") { // Buttons return true when clicked (most widgets return true when edited/activated)
                counter += 1
            }

            ImGui.SameLine()
            ImGui.Text(String(format: "counter = %d", counter))

            ImGui.Text(String(format: "Application average %.3f ms/frame (%.1f FPS)",
                              1000.0 / ImGui.GetIO().Framerate,
                              ImGui.GetIO().Framerate))

            ImGui.End()

            // 3. Show another simple window.
            if show_another_window {

                ImGui.Begin("Another Window", &show_another_window)  // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)

                ImGui.Text("Hello from another window!")
                if ImGui.Button("Close Me") {
                    show_another_window = false
                }
                ImGui.End()
            }

            // Rendering
            ImGui.Render()
            let drawData: ImDrawData = ImGui.GetDrawData()

            ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder)
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
