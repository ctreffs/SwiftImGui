//
//  Helper.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

import Foundation

extension String {
    public func cStrPtr() -> UnsafePointer<CChar>! {
        guard let cString: [CChar] = self.cString(using: .utf8) else {
            assertionFailure("could not create cString with encoding from \(self)")
            return nil
        }

        return cString.withUnsafeBufferPointer { ptr -> UnsafePointer<CChar>? in
            guard let startAddress = ptr.baseAddress else {
                assertionFailure("could not get start address of cString \(cString)")
                return nil
            }

            return startAddress
        }
    }

    public mutating func cMutableStrPtr() -> UnsafeMutablePointer<CChar>! {
        return UnsafeMutablePointer<CChar>(mutating: self.cStrPtr())
    }
}

extension Array {
    public subscript<R>(representable: R) -> Element where R: RawRepresentable, R.RawValue: FixedWidthInteger {
        get { return self[Int(representable.rawValue)] }
        set { self[Int(representable.rawValue)] = newValue }
    }
}

/// https://forums.developer.apple.com/thread/72120
public struct CArray<T> {
    @usableFromInline var ptr: UnsafeMutableBufferPointer<T>

    public init(_ start: inout T, _ count: Int) {
        ptr = UnsafeMutableBufferPointer(start: &start, count: count)
    }

    public var count: Int {
        return ptr.count
    }

    public subscript<I>(index: I) -> T where I: FixedWidthInteger {
        get {
            return ptr[Int(index)]
        }
        set {
            ptr[Int(index)] = newValue
        }
    }

    public subscript<R>(representable: R) -> T where R: RawRepresentable, R.RawValue: FixedWidthInteger {
        get {
            return self[representable.rawValue]
        }
        set {
            self[representable.rawValue] = newValue
        }
    }
}

extension CArray {
    public init(_ cArray: inout (T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }

    public init(_ cArray: inout (T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }
}

/// Offset of _MEMBER within _TYPE. Standardized as offsetof() in modern C++.
public func IM_OFFSETOF<T>(_ member: PartialKeyPath<T>) -> Int {
    return MemoryLayout<T>.offset(of: member)!
}

/// Size of a static C-style array. Don't use on pointers!
public func IM_ARRAYSIZE<T>(_ cTupleArray: T) -> Int {
    //#define IM_ARRAYSIZE(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))
    let m = Mirror(reflecting: cTupleArray)
    precondition(m.displayStyle == Mirror.DisplayStyle.tuple, "IM_ARRAYSIZE may only be applied to C array tuples")
    return m.children.count
}

/// Debug Check Version
///
/// ImGui::DebugCheckVersionAndDataLayout(IMGUI_VERSION, sizeof(ImGuiIO), sizeof(ImGuiStyle), sizeof(ImVec2), sizeof(ImVec4), sizeof(ImDrawVert), sizeof(ImDrawIdx))
public func IMGUI_CHECKVERSION() {
    ImGuiDebugCheckVersionAndDataLayout(ImGuiGetVersion(),
                                        MemoryLayout<ImGuiIO>.size,
                                        MemoryLayout<ImGuiStyle>.size,
                                        MemoryLayout<ImVec2>.size,
                                        MemoryLayout<ImVec4>.size,
                                        MemoryLayout<ImDrawVert>.size,
                                        MemoryLayout<ImDrawIdx>.size)
}
