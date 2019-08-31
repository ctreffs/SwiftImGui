import CImGUI

public enum ImGui {
    public typealias ImGuiContext = OpaquePointer

    public static func GetVersion() -> String {
        return String(cString: igGetVersion()!)
    }

    public static func GetIO() -> ImGuiIO {
        return igGetIO().pointee
    }

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
