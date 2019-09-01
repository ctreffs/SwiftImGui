import CImGUI

public enum ImGui {
    public typealias ImGuiContext = OpaquePointer

    public static func GetVersion() -> String {
        return String(cString: igGetVersion()!)
    }

    public static func GetIO() -> ImGuiIO {
        return igGetIO()!.pointee
    }

    public static func SetIO(to io: inout ImGuiIO) {
        igGetIO().assign(from: &io, count: 1)
    }

    @discardableResult
    public static func DebugCheckVersionAndDataLayout() -> Bool {
        return igDebugCheckVersionAndDataLayout(igGetVersion(),
                                                MemoryLayout<ImGuiIO>.size,
                                                MemoryLayout<ImGuiStyle>.size,
                                                MemoryLayout<ImVec2>.size,
                                                MemoryLayout<ImVec4>.size,
                                                MemoryLayout<ImDrawVert>.size,
                                                MemoryLayout<ImDrawIdx>.size)
    }

    @discardableResult
    public static func CreateContext(_ sharedFontAtlas: UnsafeMutablePointer<ImFontAtlas>! = nil) -> ImGuiContext {
        return igCreateContext(sharedFontAtlas)
    }

    public static func StyleColorsDark(_ dst: UnsafeMutablePointer<ImGuiStyle>! = nil) {
        igStyleColorsDark(dst)
    }

    public static func NewFrame() {
        igNewFrame()
    }

    public static func ShowDemoWindow(_ open: inout Bool) {
        igShowDemoWindow(&open)
    }

    public static func Render() {
        igRender()
    }

    public static func GetDrawData() -> ImDrawData {
        return igGetDrawData().pointee
    }

}

extension ImFontAtlas {
    public mutating func GetTexDataAsRGBA32(
        _ out_pixels: inout UnsafeMutablePointer<UInt8>?,
        _ out_width: inout Int32,
        _ out_height: inout Int32,
        _ out_bytes_per_pixel: inout Int32) {
        ImFontAtlas_GetTexDataAsRGBA32(&self,
                                       &out_pixels,
                                       &out_width,
                                       &out_height,
                                       &out_bytes_per_pixel)
    }

}

/// Offset of _MEMBER within _TYPE. Standardized as offsetof() in modern C++.
public func IM_OFFSETOF<T>(_ member: PartialKeyPath<T>) -> Int {
    return MemoryLayout<T>.offset(of: member)!
}

// Special Draw callback value to request renderer back-end to reset the graphics/render state.
// The renderer back-end needs to handle this special value, otherwise it will crash trying to call a function at this address.
// This is useful for example if you submitted callbacks which you know have altered the render state and you want it to be restored.
// It is not done by default because they are many perfectly useful way of altering render state for imgui contents (e.g. changing shader/blending settings before an Image call).
// let ImDrawCallback_ResetRenderState = ImDrawCallback()(-1)

/*
 public static func showDemoWindow() {

        let ctx = igCreateContext(nil)
        let io = igGetIO()

        let out_pixels: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! = UnsafeMutablePointer.allocate(capacity: 0)
        var out_width: Int32 = 0
        var out_height: Int32 = 0

        let atlas = ImFontAtlas_ImFontAtlas()
        ImFontAtlas_GetTexDataAsRGBA32(atlas!,
                                       out_pixels,
                                       &out_width,
                                       &out_height,
                                       nil)
        ImFontAtlas_Build(atlas!)

        io!.pointee.Fonts.pointee = atlas!.pointee
        //ImFontAtlas_Build(&io!.pointee.Fonts.pointee)
        //ImFontAtlas_GetTexDataAsRGBA32(&io!.pointee.Fonts.pointee, )
        // See ImGuiFreeType::RasterizationFlags
        //unsigned int flags = ImGuiFreeType::NoHinting;
        //ImGuiFreeType::BuildFontAtlas(io.Fonts, flags);
        //io.Fonts->GetTexDataAsRGBA32(&pixels, &width, &height);

        //io!.pointee.Fonts.pointee.texD
        //io!.pointee.Fonts.pointee.textDat
        io!.pointee.DisplaySize = ImVec2(x: 1920, y: 1080)
        io!.pointee.DeltaTime = 1.0 / 60.0
        igNewFrame()

        igShowDemoWindow(nil)
        igRender()

        igDestroyContext(ctx!)
    }
 */
