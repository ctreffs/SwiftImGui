//
//  File.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

typealias Definitions = [String: [Definition]]

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
    let ret: DataType = .void

    let templated: Bool = false

    func encode(swift def: [ArgsT]) -> String {
        return def.map { $0.toSwift }.joined(separator: ", ")
    }

    func encode(c def: [ArgsT]) -> String {
        return def.map { $0.toC }.joined(separator: ",")
    }

    var toSwift: String {
        return """
        @inlinable public func \(self.funcname)(\(encode(swift: self.argsT))) -> \(ret.toSwift) {
        \t\(self.ret == .void ? "" : "return ")\(self.cimguiname)(\(encode(c: self.argsT)))
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

/*
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
 */
