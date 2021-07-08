//
//  Helper.swift
//
//
//  Created by Christian Treffs on 31.08.19.
//

extension Array {
    public subscript<R>(representable: R) -> Element where R: RawRepresentable, R.RawValue: FixedWidthInteger {
        get { self[Int(representable.rawValue)] }
        set { self[Int(representable.rawValue)] = newValue }
    }
}
/// Compute the prefix sum of `seq`.
public func scan<S: Sequence, U>(_ seq: S, _ initial: U, _ combine: (U, S.Iterator.Element) -> U) -> [U] {
    var result: [U] = []
    result.reserveCapacity(seq.underestimatedCount)
    var runningResult = initial
    for element in seq {
        runningResult = combine(runningResult, element)
        result.append(runningResult)
    }
    return result
}
/// https://oleb.net/blog/2016/10/swift-array-of-c-strings/
// from: https://forums.swift.org/t/bridging-string-to-const-char-const/3804/4
public func withArrayOfCStrings<R>(
    _ args: [String],
    _ body: ([UnsafePointer<CChar>?]) -> R) -> R {
    let argsCounts = Array(args.map {
        $0.utf8.count + 1
    })
    let argsOffsets = [0] + scan(argsCounts, 0, +)
    let argsBufferSize = argsOffsets.last!

    var argsBuffer: [UInt8] = []
    argsBuffer.reserveCapacity(argsBufferSize)
    for arg in args {
        argsBuffer.append(contentsOf: arg.utf8)
        argsBuffer.append(0)
    }

    return argsBuffer.withUnsafeBufferPointer {
        argsBuffer in
        let ptr = UnsafeRawPointer(argsBuffer.baseAddress!)
            .bindMemory(to: CChar.self, capacity: argsBuffer.count)
        var cStrings: [UnsafePointer<CChar>?] = argsOffsets.map {
            ptr + $0
        }
        cStrings[cStrings.count - 1] = nil
        return body(cStrings)
    }
}

public func withArrayOfCStringsBasePointer<Result>(_ strings: [String], _ body: (UnsafePointer<UnsafePointer<Int8>?>?) -> Result) -> Result {
    withArrayOfCStrings(strings) { arrayPtr in
        arrayPtr.withUnsafeBufferPointer { bufferPtr in
            body(bufferPtr.baseAddress)
        }
    }
}

extension Optional where Wrapped == String {
    @inlinable public func withOptionalCString<Result>(_ body: (UnsafePointer<Int8>?) throws -> Result) rethrows -> Result {
        guard let string = self else {
            return try body(nil)
        }
        return try string.withCString(body)
    }
}

/// https://forums.developer.apple.com/thread/72120
/// https://forums.swift.org/t/fixed-size-array-hacks/32962/4
/// https://github.com/stephentyrone/swift-numerics/blob/static-array/Sources/StaticArray/StaticArray.swift
public enum CArray<T> {
    @discardableResult
    @_transparent
    public static func write<C, O>(_ cArray: inout C, _ body: (UnsafeMutableBufferPointer<T>) throws -> O) rethrows -> O {
        try withUnsafeMutablePointer(to: &cArray) {
            try body(UnsafeMutableBufferPointer<T>(start: UnsafeMutableRawPointer($0).assumingMemoryBound(to: T.self),
                                                   count: (MemoryLayout<C>.stride / MemoryLayout<T>.stride)))
        }
    }

    @discardableResult
    @_transparent
    public static func read<C, O>(_ cArray: C, _ body: (UnsafeBufferPointer<T>) throws -> O) rethrows -> O {
        try withUnsafePointer(to: cArray) {
            try body(UnsafeBufferPointer<T>(start: UnsafeRawPointer($0).assumingMemoryBound(to: T.self),
                                            count: (MemoryLayout<C>.stride / MemoryLayout<T>.stride)))
        }
    }
}

/// Offset of _MEMBER within _TYPE. Standardized as offsetof() in modern C++.
public func IM_OFFSETOF<T>(_ member: PartialKeyPath<T>) -> Int {
    MemoryLayout<T>.offset(of: member)!
}

/// Size of a static C-style array. Don't use on pointers!
public func IM_ARRAYSIZE<T>(_ cTupleArray: T) -> Int {
    // #define IM_ARRAYSIZE(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))
    let mirror = Mirror(reflecting: cTupleArray)
    precondition(mirror.displayStyle == Mirror.DisplayStyle.tuple, "IM_ARRAYSIZE may only be applied to C array tuples")
    return mirror.children.count
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
