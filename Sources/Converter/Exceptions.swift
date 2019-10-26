//
//  Exceptions.swift
//  
//
//  Created by Christian Treffs on 26.10.19.
//

// Conversion process is not perfect right now so we have a small list of exceptions
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
}
