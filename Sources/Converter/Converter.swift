//
//  Converter.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

import struct Foundation.URL
import struct Foundation.Data
import class Foundation.JSONDecoder

public func convert(filePath: String, to convertedOutput: (String) -> Void = { print($0) }) throws {
    let file: URL = URL(fileURLWithPath: filePath)
    let data: Data = try Data(contentsOf: file)
    let decoder = JSONDecoder()

    let defs = try decoder.decode(Definitions.self, from: data)

    let output: String = defs
        .values
        .flatMap { $0 }
        .flatMap { $0.definitions }
        .compactMap { def in
            switch def {
            case let .function(funcDef):
                return funcDef.toSwift
            default:
                return nil
            }
    }
    .joined(separator: "\n\n")
    return convertedOutput(output)
}
