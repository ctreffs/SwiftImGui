//
//  Exceptions.swift
//  
//
//  Created by Christian Treffs on 26.10.19.
//

// Conversion process is not perfect yet so we have a small list of exceptions
enum Exceptions {

    /// Set of missing functions that are not exposed to Swift automatically,
    /// but are present in definitions.json
    ///
    /// causes "Use of unresolved identifier '...'" compiler error.
    static let unresolvedIdentifier: Set<String> = [
        "ImVector_capacity",
        "ImVector_clear",
        "ImVector_empty",
        "ImVector__grow_capacity",
        "ImVector_pop_back",
        "ImVector_reserve",
        "ImVector_resize",
        "ImVector_size",
        "ImVector_size_in_bytes",
        "ImVector_swap"
    ]

    /// causes "Use of undeclared type '...'" compiler error.
    static let undeclardTypes: [String: Declaration] = [
        "ImGuiContext": Declaration(name: "ImGuiContext", typealiasType: "OpaquePointer"),
        "ImDrawListSharedData": Declaration(name: "ImDrawListSharedData", typealiasType: "OpaquePointer")
    ]
}

struct Declaration {
    let name: String
    let typealiasType: String
    var dataType: DataType {
        return DataType(meta: .primitive, type: .custom(name), isConst: true)
    }
}

extension Declaration: Equatable { }
extension Declaration: Hashable { }
