//
//  Converter.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

import struct Foundation.Data
import class Foundation.JSONDecoder
import struct Foundation.URL

public func convert(filePath: String, validOnly: Bool, to convertedOutput: (String) throws -> Void = { print($0) }) throws {
    let file = URL(fileURLWithPath: filePath)
    let data: Data = try Data(contentsOf: file)
    let decoder = JSONDecoder()

    let defs = try decoder.decode(Definitions.self, from: data)
    var invalidFuncsCount = 0
    var validFuncsCount = 0

    let getValidFunctionDefs: (Definition) -> Set<FunctionDef> = { defs in
        let valid = defs.validFunctions
        let invalidCount = defs.functions.count - valid.count
        validFuncsCount += valid.count
        invalidFuncsCount += invalidCount
        return valid
    }
    let getFunctionDefs: (Definition) -> Set<FunctionDef> = validOnly ? getValidFunctionDefs : { $0.functions }

    let output: String = defs
        .values
        .flatMap { $0 }
        .flatMap { getFunctionDefs($0) }
        .sorted()
        .map(\.toSwift)
        .joined(separator: "\n\n")

    defer {
        if invalidFuncsCount > 0 {
            print("[WARN]: \(invalidFuncsCount) 'invalid' functions that will not be wrapped. Valid count: \(validFuncsCount)")
        }
    }
    return try convertedOutput(output)
}
