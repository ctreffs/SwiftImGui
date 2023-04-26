//
//  imgui_impl_metal.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

import AppKit
import CImGui
import ImGui
import Metal
import MetalKit

@available(OSX 10.11, *)
var g_sharedMetalContext: MetalContext = .init()

@available(OSX 10.11, *)
@discardableResult
func ImGui_ImplMetal_Init(_ device: MTLDevice) -> Bool {
    let io = ImGuiGetIO()!

    "imgui_impl_metal".withCString {
        io.pointee.BackendRendererName = $0
    }

    // We can honor the ImDrawCmd::VtxOffset field, allowing for large meshes.
    io.pointee.BackendFlags |= Int32(ImGuiBackendFlags_RendererHasVtxOffset.rawValue)

    ImGui_ImplMetal_CreateDeviceObjects(device)
    return true
}

@available(OSX 10.11, *)
func ImGui_ImplMetal_Shutdown() {
    ImGui_ImplMetal_DestroyDeviceObjects()
}

@available(OSX 10.11, *)
func ImGui_ImplMetal_NewFrame(_ renderPassDescriptor: MTLRenderPassDescriptor) {
    g_sharedMetalContext.framebufferDescriptor = FramebufferDescriptor(renderPassDescriptor)
}

// Metal Render function.
@available(OSX 10.11, *)
func ImGui_ImplMetal_RenderDrawData(_ draw_data: ImDrawData,
                                    _ commandBuffer: MTLCommandBuffer,
                                    _ commandEncoder: MTLRenderCommandEncoder)
{
    g_sharedMetalContext.renderDrawData(drawData: draw_data,
                                        commandBuffer: commandBuffer,
                                        commandEncoder: commandEncoder)
}

@available(OSX 10.11, *)
@discardableResult
func ImGui_ImplMetal_CreateDeviceObjects(_ device: MTLDevice) -> Bool {
    g_sharedMetalContext.makeDeviceObjects(with: device)
    ImGui_ImplMetal_CreateFontsTexture(device)
    return true
}

@available(OSX 10.11, *)
@discardableResult
func ImGui_ImplMetal_CreateFontsTexture(_ device: MTLDevice) -> Bool {
    g_sharedMetalContext.makeFontTexture(with: device)

    let io = ImGuiGetIO()!

    let texId: ImTextureID = withUnsafePointer(to: &g_sharedMetalContext.fontTexture!) { ptr in
        UnsafeMutableRawPointer(mutating: ptr)
    }

    io.pointee.Fonts.pointee.TexID = texId // ImTextureID == void*

    return g_sharedMetalContext.fontTexture != nil
}

@available(OSX 10.11, *)
func ImGui_ImplMetal_DestroyFontsTexture() {
    let io = ImGuiGetIO()!
    g_sharedMetalContext.fontTexture = nil
    io.pointee.Fonts.pointee.TexID = nil
}

@available(OSX 10.11, *)
func ImGui_ImplMetal_DestroyDeviceObjects() {
    ImGui_ImplMetal_DestroyFontsTexture()
    g_sharedMetalContext.emptyRenderPipelineStateCache()
}

// A wrapper around a MTLBuffer object that knows the last time it was reused
@available(OSX 10.11, *)
class MetalBuffer {
    let buffer: MTLBuffer
    var lastReuseTime: TimeInterval

    init(_ buffer: MTLBuffer) {
        self.buffer = buffer
        lastReuseTime = Date.timeIntervalBetween1970AndReferenceDate
    }
}

@available(OSX 10.11, *)
extension MetalBuffer: Equatable {
    static func == (lhs: MetalBuffer, rhs: MetalBuffer) -> Bool {
        lhs.buffer.length == rhs.buffer.length &&
            lhs.buffer.contents() == rhs.buffer.contents() &&
            lhs.lastReuseTime == rhs.lastReuseTime
    }
}

// An object that encapsulates the data necessary to uniquely identify a
// render pipeline state. These are used as cache keys.
@available(OSX 10.11, *)
struct FramebufferDescriptor {
    let sampleCount: Int
    let colorPixelFormat: MTLPixelFormat
    let depthPixelFormat: MTLPixelFormat
    let stencilPixelFormat: MTLPixelFormat

    init(_ renderPassDescriptor: MTLRenderPassDescriptor) {
        sampleCount = renderPassDescriptor.colorAttachments[0].texture!.sampleCount
        colorPixelFormat = renderPassDescriptor.colorAttachments[0].texture!.pixelFormat
        depthPixelFormat = renderPassDescriptor.depthAttachment.texture?.pixelFormat ?? .invalid
        stencilPixelFormat = renderPassDescriptor.stencilAttachment.texture?.pixelFormat ?? .invalid
    }
}

@available(OSX 10.11, *)
extension FramebufferDescriptor: Equatable {
    static func == (lhs: FramebufferDescriptor, rhs: FramebufferDescriptor) -> Bool {
        lhs.sampleCount == rhs.sampleCount &&
            lhs.colorPixelFormat == rhs.colorPixelFormat &&
            lhs.depthPixelFormat == rhs.depthPixelFormat &&
            lhs.stencilPixelFormat == rhs.stencilPixelFormat
    }
}

@available(OSX 10.11, *)
extension FramebufferDescriptor: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sampleCount)
        hasher.combine(colorPixelFormat)
        hasher.combine(depthPixelFormat)
        hasher.combine(stencilPixelFormat)
    }
}

/// A singleton that stores long-lived objects that are needed by the Metal
/// renderer backend. Stores the render pipeline state cache and the default
/// font texture, and manages the reusable buffer cache.
@available(OSX 10.11, *)
class MetalContext {
    var depthStencilState: MTLDepthStencilState!
    // framebuffer descriptor for current frame; transient
    var framebufferDescriptor: FramebufferDescriptor!
    // pipeline cache; keyed on framebuffer descriptors
    var renderPipelineStateCache: [FramebufferDescriptor: MTLRenderPipelineState]
    var fontTexture: MTLTexture?
    var bufferCache: [MetalBuffer]
    var lastBufferCachePurge: TimeInterval

    init() {
        renderPipelineStateCache = [:]
        bufferCache = []
        lastBufferCachePurge = Date().timeIntervalSince1970
    }

    func makeDeviceObjects(with device: MTLDevice) {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilDescriptor.depthCompareFunction = .always
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    /// We are retrieving and uploading the font atlas as a 4-channels RGBA texture here.
    /// In theory we could call GetTexDataAsAlpha8() and upload a 1-channel texture to save on memory access bandwidth.
    /// However, using a shader designed for 1-channel texture would make it less obvious to use the ImTextureID facility
    /// to render users own textures.
    /// You can make that change in your implementation.
    func makeFontTexture(with device: MTLDevice) {
        let io = ImGuiGetIO()!

        var pixels: UnsafeMutablePointer<UInt8>?
        var width: Int32 = 0
        var height: Int32 = 0
        var bytesPerPixel: Int32 = 0
        ImFontAtlas_GetTexDataAsRGBA32(io.pointee.Fonts, &pixels, &width, &height, &bytesPerPixel)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: Int(width),
                                                                         height: Int(height),
                                                                         mipmapped: false)

        textureDescriptor.usage = .shaderRead
        textureDescriptor.storageMode = .managed

        let texture = device.makeTexture(descriptor: textureDescriptor)!

        texture.replace(region: MTLRegionMake2D(0, 0, Int(width), Int(height)),
                        mipmapLevel: 0,
                        withBytes: UnsafeRawPointer(pixels!),
                        bytesPerRow: Int(width) * Int(bytesPerPixel))

        fontTexture = texture
    }

    func dequeueReusableBuffer(ofLength length: Int, device: MTLDevice) -> MetalBuffer {
        let now: TimeInterval = Date().timeIntervalSince1970

        // Purge old buffers that haven't been useful for a while
        if (now - lastBufferCachePurge) > 1.0 {
            var survivors: [MetalBuffer] = []
            for candidate in bufferCache {
                if candidate.lastReuseTime > lastBufferCachePurge {
                    survivors.append(candidate)
                }
            }
            bufferCache = survivors
            lastBufferCachePurge = now
        }

        // See if we have a buffer we can reuse
        var bestCandidate: MetalBuffer?

        for candidate in bufferCache {
            if candidate.buffer.length >= length, bestCandidate == nil || bestCandidate!.lastReuseTime > candidate.lastReuseTime {
                bestCandidate = candidate
            }
        }

        if let bestCandidate = bestCandidate {
            bufferCache.removeAll(where: { $0 == bestCandidate })
            bestCandidate.lastReuseTime = now
            return bestCandidate
        }

        // No luck; make a new buffer
        let backing: MTLBuffer = device.makeBuffer(length: length, options: .storageModeShared)!
        return MetalBuffer(backing)
    }

    func enqueueReusableBuffer(_ buffer: MetalBuffer) {
        bufferCache.append(buffer)
    }

    func renderPipelineStateForFrameAndDevice(_ device: MTLDevice) -> MTLRenderPipelineState {
        // Try to retrieve a render pipeline state that is compatible with the framebuffer config for this frame
        // The hit rate for this cache should be very near 100%.
        let renderPipelineState: MTLRenderPipelineState

        if let cached: MTLRenderPipelineState = renderPipelineStateCache[framebufferDescriptor] {
            renderPipelineState = cached
        } else {
            // No luck; make a new render pipeline state
            renderPipelineState = renderPipelineStateForFramebufferDescriptor(framebufferDescriptor, device)
            // Cache render pipeline state for later reuse
            renderPipelineStateCache[framebufferDescriptor] = renderPipelineState
        }

        return renderPipelineState
    }

    func emptyRenderPipelineStateCache() {
        renderPipelineStateCache.removeAll(keepingCapacity: true)
    }

    func setupRenderState(drawData: ImDrawData,
                          commandBuffer _: MTLCommandBuffer,
                          commandEncoder: MTLRenderCommandEncoder,
                          renderPipelineState: MTLRenderPipelineState,
                          vertexBuffer: MetalBuffer,
                          vertexBufferOffset: Int)
    {
        commandEncoder.setCullMode(.none)
        commandEncoder.setDepthStencilState(g_sharedMetalContext.depthStencilState)

        // Setup viewport, orthographic projection matrix
        // Our visible imgui space lies from draw_data->DisplayPos (top left) to
        // draw_data->DisplayPos+data_data->DisplaySize (bottom right). DisplayMin is typically (0,0) for single viewport apps.

        let viewport = MTLViewport(
            originX: 0.0,
            originY: 0.0,
            width: Double(drawData.DisplaySize.x * drawData.FramebufferScale.x),
            height: Double(drawData.DisplaySize.y * drawData.FramebufferScale.y),
            znear: 0.0,
            zfar: 1.0
        )
        commandEncoder.setViewport(viewport)

        let L: Float = drawData.DisplayPos.x
        let R: Float = drawData.DisplayPos.x + drawData.DisplaySize.x
        let T: Float = drawData.DisplayPos.y
        let B: Float = drawData.DisplayPos.y + drawData.DisplaySize.y
        let N = Float(viewport.znear)
        let F = Float(viewport.zfar)

        var ortho_projection = simd_float4x4([2.0 / (R - L), 0.0, 0.0, 0.0],
                                             [0.0, 2.0 / (T - B), 0.0, 0.0],
                                             [0.0, 0.0, 1 / (F - N), 0.0],
                                             [(R + L) / (L - R), (T + B) / (B - T), N / (F - N), 1.0])

        withUnsafeMutablePointer(to: &ortho_projection) {
            commandEncoder.setVertexBytes($0, length: MemoryLayout<simd_float4x4>.size, index: 1)
        }

        commandEncoder.setRenderPipelineState(renderPipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
        commandEncoder.setVertexBufferOffset(vertexBufferOffset, index: 0)
    }

    func renderDrawData(drawData: ImDrawData,
                        commandBuffer: MTLCommandBuffer,
                        commandEncoder: MTLRenderCommandEncoder)
    {
        // Avoid rendering when minimized,
        // scale coordinates for retina displays (screen coordinates != framebuffer coordinates)

        let fb_width = Int(drawData.DisplaySize.x * drawData.FramebufferScale.x)
        let fb_height = Int(drawData.DisplaySize.y * drawData.FramebufferScale.y)

        if fb_width <= 0 || fb_height <= 0 || drawData.CmdListsCount == 0 {
            return
        }

        let renderPipelineState: MTLRenderPipelineState = renderPipelineStateForFrameAndDevice(commandBuffer.device)

        let vertexBufferLength = Int(drawData.TotalVtxCount) * MemoryLayout<ImDrawVert>.size
        let indexBufferLength = Int(drawData.TotalIdxCount) * MemoryLayout<ImDrawIdx>.size

        let vertexBuffer: MetalBuffer = dequeueReusableBuffer(ofLength: vertexBufferLength,
                                                              device: commandBuffer.device)

        let indexBuffer: MetalBuffer = dequeueReusableBuffer(ofLength: indexBufferLength,
                                                             device: commandBuffer.device)

        setupRenderState(drawData: drawData,
                         commandBuffer: commandBuffer,
                         commandEncoder: commandEncoder,
                         renderPipelineState: renderPipelineState,
                         vertexBuffer: vertexBuffer,
                         vertexBufferOffset: 0)

        // Will project scissor/clipping rectangles into framebuffer space
        let clipOff: ImVec2 = drawData.DisplayPos // (0,0) unless using multi-viewports
        let clipScale: ImVec2 = drawData.FramebufferScale // (1,1) unless using retina display which are often (2,2)

        // // Render command lists

        var vertexBufferOffset = 0
        var indexBufferOffset = 0

        for n in 0 ..< Int(drawData.CmdListsCount) {
            var cmd_list: ImDrawList = drawData.CmdLists[n]!.pointee

            memcpy(vertexBuffer.buffer.contents().advanced(by: vertexBufferOffset),
                   cmd_list.VtxBuffer.Data,
                   Int(cmd_list.VtxBuffer.Size) * MemoryLayout<ImDrawVert>.size)

            memcpy(indexBuffer.buffer.contents().advanced(by: indexBufferOffset),
                   cmd_list.IdxBuffer.Data,
                   Int(cmd_list.IdxBuffer.Size) * MemoryLayout<ImDrawIdx>.size)

            for cmd_i in 0 ..< Int(cmd_list.CmdBuffer.Size) {
                var pcmd: ImDrawCmd = cmd_list.CmdBuffer.Data[cmd_i]

                if let userCallback = pcmd.UserCallback {
                    // User callback, registered via ImDrawList::AddCallback()
                    // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                    if pcmd.UserCallbackData == nil { // (pcmd->UserCallback == ImDrawCallback_ResetRenderState)
                        setupRenderState(drawData: drawData,
                                         commandBuffer: commandBuffer,
                                         commandEncoder: commandEncoder,
                                         renderPipelineState: renderPipelineState,
                                         vertexBuffer: vertexBuffer,
                                         vertexBufferOffset: vertexBufferOffset)
                    } else {
                        userCallback(&cmd_list, &pcmd)
                    }
                } else {
                    // Project scissor/clipping rectangles into framebuffer space
                    let clipRect = ImVec4(x: (pcmd.ClipRect.x - clipOff.x) * clipScale.x,
                                          y: (pcmd.ClipRect.y - clipOff.y) * clipScale.y,
                                          z: (pcmd.ClipRect.z - clipOff.x) * clipScale.x,
                                          w: (pcmd.ClipRect.w - clipOff.y) * clipScale.y)

                    if clipRect.x < Float(fb_width), clipRect.y < Float(fb_height), clipRect.z >= 0.0, clipRect.w >= 0.0 {
                        // Apply scissor/clipping rectangle
                        let scissorsRect = MTLScissorRect(x: Int(clipRect.x),
                                                          y: Int(clipRect.y),
                                                          width: Int(clipRect.z - clipRect.x),
                                                          height: Int(clipRect.w - clipRect.y))
                        commandEncoder.setScissorRect(scissorsRect)

                        // Bind texture, Draw
                        if let textureId = pcmd.TextureId {
                            let texture = textureId.load(as: MTLTexture.self)
                            commandEncoder.setFragmentTexture(texture, index: 0)
                        }

                        let vbOffset = vertexBufferOffset + Int(pcmd.VtxOffset) * MemoryLayout<ImDrawVert>.size
                        commandEncoder.setVertexBufferOffset(vbOffset,
                                                             index: 0)

                        let indexCount = Int(pcmd.ElemCount)
                        let indexType: MTLIndexType = MemoryLayout<ImDrawIdx>.size == 2 ? .uint16 : .uint32
                        let ibOffset = indexBufferOffset + Int(pcmd.IdxOffset) * MemoryLayout<ImDrawIdx>.size
                        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                             indexCount: indexCount,
                                                             indexType: indexType,
                                                             indexBuffer: indexBuffer.buffer,
                                                             indexBufferOffset: ibOffset)
                    }
                }
            }

            vertexBufferOffset += Int(cmd_list.VtxBuffer.Size) * MemoryLayout<ImDrawVert>.size
            indexBufferOffset += Int(cmd_list.IdxBuffer.Size) * MemoryLayout<ImDrawIdx>.size
        }

        commandBuffer.addCompletedHandler { [weak self] _ in

            DispatchQueue.main.async { [weak self] in
                self?.enqueueReusableBuffer(vertexBuffer)
                self?.enqueueReusableBuffer(indexBuffer)
            }
        }
    }

    func renderPipelineStateForFramebufferDescriptor(_: FramebufferDescriptor, _ device: MTLDevice) -> MTLRenderPipelineState {
        let shaderSource: String = Shaders.default

        let library: MTLLibrary = try! device.makeLibrary(source: shaderSource, options: nil)

        let vertexFunction: MTLFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction: MTLFunction = library.makeFunction(name: "fragment_main")!

        let vertexDescriptor = MTLVertexDescriptor()

        // position
        vertexDescriptor.attributes[0].offset = IM_OFFSETOF(\ImDrawVert.pos)
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0

        // texCoords
        vertexDescriptor.attributes[1].offset = IM_OFFSETOF(\ImDrawVert.uv)
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = 0

        // color
        vertexDescriptor.attributes[2].offset = IM_OFFSETOF(\ImDrawVert.col)
        vertexDescriptor.attributes[2].format = .uchar4
        vertexDescriptor.attributes[2].bufferIndex = 0

        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<ImDrawVert>.size

        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.sampleCount = framebufferDescriptor.sampleCount
        pipelineDescriptor.colorAttachments[0].pixelFormat = framebufferDescriptor.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        pipelineDescriptor.depthAttachmentPixelFormat = framebufferDescriptor.depthPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = framebufferDescriptor.stencilPixelFormat

        let renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        return renderPipelineState
    }
}
