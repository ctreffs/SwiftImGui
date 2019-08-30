import CImGUI

@_exported import struct CImGUI.ImVec2

public func helloImGUI(x: Float, y: Float) -> ImVec2 {
    let vec = ImVec2(x: x, y: y)
    print("Hello ImGUI \(vec)")
    return vec
}


extension ImVec2: Equatable {
    public static func == (lhs: ImVec2, rhs: ImVec2) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y
    }
}
