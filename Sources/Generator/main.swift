//
//  main.swift
//
//
//  Created by Christian Treffs on 24.10.19.
//

import struct Foundation.URL
import struct Foundation.Data
import class Foundation.JSONDecoder

let arg1 = CommandLine.arguments[1]

let file: URL = URL(fileURLWithPath: arg1)
let data: Data = try Data(contentsOf: file)

let decoder = JSONDecoder()

struct Prototype {
    let args: String
    let signature: String

    let callArgs: String
    let cimguiname: String
    let ovCimguiname: String
    let stname: String
    let argsT: [ArgsT]

    let defaults: Defaults
    let funcname: String?

    let ret: String?
    let argsoriginal: String?

    let nonUdt: Int?
    let retorig: Retorig?
    let constructor: Bool?
    let destructor: Bool?
    let isvararg: Isvararg?
    let manual: Bool?
    let templated: Bool?
    let retref: String?
    let namespace: Namespace?
}

/*
 case bool
 case int
 case char
 case float
 case double
 case unknown(String)

 */

indirect enum DataType: Decodable {
    case void
    case bool
    case int
    case char
    case float
    case double
    case size_t
    case va_list
    case arrayFixedSize(DataType, Int)
    case reference(DataType)
    case custom(String)
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self.init(string: raw)
    }

    init(string: String) {
        if let direct = DataType(rawValue: string) {
            self = direct
            return
        }

        if let asterisc = string.firstIndex(of: "*") {
            // TODO: parse complex types
            self = .unknown
        } else if let ref = string.firstIndex(of: "&") {
            // i.e. float&, ImVector&
            let dataType = DataType(string: String(string[string.startIndex..<ref]))
            self = .reference(dataType)
        } else if let startFixArr = string.firstIndex(of: "["), let endFixArr = string.firstIndex(of: "]") {
            // i.e. float[4]
            let numRange = string.index(after: startFixArr)..<endFixArr
            let count = Int(string[numRange])!

            let dataType = DataType(string: String(string[string.startIndex..<startFixArr]))

            self = .arrayFixedSize(dataType, count)
        } else {
            // TODO: parse plain types
            self = .custom(string)
        }

        // FIXME: special handle 'T'

    }

    init?(rawValue: String) {
        switch rawValue {
        case "void":
            self = .void
        case "bool":
            self = .bool
        case "int":
            self = .int
        case "char":
            self = .char
        case "float":
            self = .float
        case "double":
            self = .double
        case "size_t":
            self = .size_t
        case "va_list", "...":
            self = .va_list
        default:
            return nil
        }
    }
    var toSwift: String {
        switch self {
        case .void:
            return "Void"
        case .bool:
            return "Bool"
        case .int:
            return "Int32"
        case .char:
            return "CChar"
        case .float:
            return "Float"
        case .double:
            return "Double"
        case .size_t:
            return "Int"
        case .va_list:
            return "CVarArg..."
        case let .arrayFixedSize(dataType, count):
            return "(\((0..<count).map { _ in dataType.toSwift }.joined(separator: ",")))"
        case let .reference(dataType):
            return "inout \(dataType.toSwift)"
        case let .custom(string):
            return string
        case .unknown:
            return "<#TYPE#>"
        }
    }

}

struct ArgType: Decodable {

    let isConst: Bool

    let isUnsigned: Bool

    let type: DataType

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var raw: String = try container.decode(String.self)

        // const
        if let range = raw.range(of: "const ") {
            self.isConst = true
            raw.removeSubrange(range)
        } else {
            self.isConst = false
        }

        // unsigned
        if let unsigned = raw.range(of: "unsigned ") {
            self.isUnsigned = true
            raw.removeSubrange(unsigned)
        } else {
            self.isUnsigned = false
        }

        self.type = DataType(string: raw)
    }

}

struct ArgsT: Decodable {
    let name: String
    let type: ArgType
    let ret: String?
    let signature: String?

    var toSwift: String {
        return "\(self.name): \(self.type.type.toSwift)"
    }

    var toC: String {
        return "\(self.name)"
    }
}

enum Defaults {
    case anythingArray([Any?])
    case stringMap([String: String])
}

enum Isvararg {
    case empty
}

enum Namespace {
    case imGui
}

enum Retorig {
    case imColor
    case imVec2
    case imVec4
}

struct DestructorDef: Decodable {

    let destructor: Bool
    let args: String
    let signature: String

    let cimguiname: String

    let stname: String
    let argsT: [ArgsT]
}

struct ConstructorDef: Decodable {
    let constructor: Bool
    let args: String
    let signature: String

    let cimguiname: String

    let stname: String
    let argsT: [ArgsT]
}

struct FunctionDef: Decodable {
    let funcname: String

    let args: String
    let signature: String

    let cimguiname: String

    let stname: String
    let argsT: [ArgsT]
    let ret: DataType?

    func encode(swift def: [ArgsT]) -> String {
        return def.map { $0.toSwift }.joined(separator: ", ")
    }

    func encode(c def: [ArgsT]) -> String {
        return def.map { $0.toC }.joined(separator: ",")
    }

    var toSwift: String {
        let ret = self.ret ?? .void
        return """
        @inlinable public func \(self.funcname)(\(encode(swift: self.argsT))) -> \(ret.toSwift) {
        \(self.ret == nil ? "" : "return ")\(self.cimguiname)(\(encode(c: self.argsT)))
        }
        """
    }

}

struct Definition: Decodable {
    enum Keys: String, CodingKey {
        case funcname
        case destructor
        case constructor
    }

    enum Def {
        case function(FunctionDef)
        case destructor(DestructorDef)
        case constructor(ConstructorDef)
    }

    let definitions: [Def]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        var defs: [Def] = []

        if container.contains(.funcname) && !container.contains(.destructor) && !container.contains(.constructor) {
            defs.append(.function(try FunctionDef(from: decoder)))
        } else if container.contains(.destructor) {
            defs.append(.destructor(try DestructorDef(from: decoder)))
        } else if container.contains(.constructor) {
            defs.append(.constructor(try ConstructorDef(from: decoder)))
        }

        self.definitions = defs
    }
}

typealias Definitions = [String: [Definition]]

let defs = try decoder.decode(Definitions.self, from: data)

let definitions: [Definition.Def] = defs.values.flatMap { $0 }.flatMap { $0.definitions }

for def in definitions {
    switch def {
    case let .function(funcDef):
        //print(funcDef)
        print(funcDef.toSwift)
        //print()
        break
    default:
        break
    }
}
