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
public func scan<
    S: Sequence, U
    >(_ seq: S, _ initial: U, _ combine: (U, S.Iterator.Element) -> U) -> [U] {
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

/// https://forums.developer.apple.com/thread/72120
public struct CArray<T> {
    @usableFromInline var ptr: UnsafeMutableBufferPointer<T>

    public init(_ start: inout T, _ count: Int) {
        ptr = UnsafeMutableBufferPointer(start: &start, count: count)
    }

    public var count: Int {
        ptr.count
    }

    public subscript<I>(index: I) -> T where I: FixedWidthInteger {
        get {
            ptr[Int(index)]
        }
        set {
            ptr[Int(index)] = newValue
        }
    }

    public subscript<R>(representable: R) -> T where R: RawRepresentable, R.RawValue: FixedWidthInteger {
        get {
            self[representable.rawValue]
        }
        set {
            self[representable.rawValue] = newValue
        }
    }
}

// swiftlint:disable large_tuple
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

    // swiftlint:disable:next line_length
    public init(_ cArray: inout (T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T)) {
        self.init(&cArray.0, MemoryLayout.size(ofValue: cArray))
    }
}

/// Offset of _MEMBER within _TYPE. Standardized as offsetof() in modern C++.
public func IM_OFFSETOF<T>(_ member: PartialKeyPath<T>) -> Int {
    MemoryLayout<T>.offset(of: member)!
}

/// Size of a static C-style array. Don't use on pointers!
public func IM_ARRAYSIZE<T>(_ cTupleArray: T) -> Int {
    //#define IM_ARRAYSIZE(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))
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
