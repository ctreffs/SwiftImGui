//
//  Converter.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

import struct Foundation.URL
import struct Foundation.Data
import class Foundation.JSONDecoder

public func convert(filePath: String, validOnly: Bool, to convertedOutput: (String) throws -> Void = { print($0) }) throws {
    let file: URL = URL(fileURLWithPath: filePath)
    let data: Data = try Data(contentsOf: file)
    let decoder = JSONDecoder()

    let defs = try decoder.decode(Definitions.self, from: data)

    let getFunctionDefs: (Definition) -> Set<FunctionDef> = validOnly ? { $0.validFunctions } : { $0.functions }

    let output: String = defs
        .values
        .flatMap { $0 }
        .flatMap { getFunctionDefs($0) }
        .sorted()
        .map { $0.toSwift }
        .joined(separator: "\n\n")
    return try convertedOutput(output)
}
