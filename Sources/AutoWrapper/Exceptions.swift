//
//  Exceptions.swift
//
//
//  Created by Christian Treffs on 26.10.19.
//

// Conversion process is not perfect yet so we have a small list of exceptions
public enum Exceptions {
    /// Set of missing functions that are not exposed to Swift automatically,
    /// but are present in definitions.json
    ///
    /// causes "Use of unresolved identifier '...'" compiler error.
    public static let unresolvedIdentifier: Set<String> = [
        "igImFontAtlasBuildMultiplyCalcLookupTable",
        "igImFontAtlasBuildMultiplyRectAlpha8",
        "igImTriangleBarycentricCoords",
        "igDockBuilderCopyDockSpace",
        "ImChunkStream_clear",
        "ImChunkStream_empty",
        "ImChunkStream_size",
        "ImPool_Clear",
        "ImPool_GetSize",
        "ImPool_RemovePoolIdx",
        "ImPool_Reserve",
        "ImVector__grow_capacity",
        "ImVector_capacity",
        "ImVector_clear",
        "ImVector_empty",
        "ImVector_pop_back",
        "ImVector_reserve",
        "ImVector_resizeNil",
        "ImVector_shrink",
        "ImVector_size",
        "ImVector_size_in_bytes",
        "ImVector_swap"
    ]

    /// causes "Use of undeclared type '...'" compiler error.
    public static let undeclardTypes: [String: Declaration] = [
        "ImChunkStream": Declaration(name: "ImChunkStream", typealiasType: "OpaquePointer"),
        "ImPool": Declaration(name: "ImPool", typealiasType: "OpaquePointer")
    ]

    public static let stripPrefix: Set<String> = [
        "ig"
    ]
}

public struct Declaration {
    public let name: String
    public let typealiasType: String
    public var dataType: DataType {
        DataType(meta: .primitive, type: .custom(name), isConst: true)
    }
}

extension Declaration: Equatable { }
extension Declaration: Hashable { }
