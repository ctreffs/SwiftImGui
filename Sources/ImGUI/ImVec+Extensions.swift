//
//  ImVec+Extensions.swift
//  
//
//  Created by Christian Treffs on 31.08.19.
//
import CImGUI

@_exported import struct CImGUI.ImVec2
@_exported import struct CImGUI.ImVec4

extension ImVec2: Equatable {
    public static func == (lhs: ImVec2, rhs: ImVec2) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y
    }
}

extension ImVec4: Equatable {
    public static func == (lhs: ImVec4, rhs: ImVec4) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.z == rhs.z &&
            lhs.w == rhs.w
    }
}
