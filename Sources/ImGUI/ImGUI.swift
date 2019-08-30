import CImGUI

@_exported import struct CImGUI.ImVec2

public enum ImGui {
    public static func version() -> String {
        return String(cString: igGetVersion()!)
    }
    public static func createContext() {
        let ctx = igCreateContext(nil)
        precondition(ctx != nil)
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
}

extension ImVec2: Equatable {
    public static func == (lhs: ImVec2, rhs: ImVec2) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y
    }
}
