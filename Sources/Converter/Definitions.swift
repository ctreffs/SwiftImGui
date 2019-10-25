//
//  File.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

typealias Definitions = [String: [Definition]]

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
    let ov_cimguiname: String

    let stname: String
    let argsT: [ArgsT]
    let ret: DataType = .void

    let templated: Bool = false

    @inlinable var isValid: Bool {
        return argsT.allSatisfy { $0.isValid }
    }
    
    func encode(swift def: [ArgsT]) -> String {
        return def.map { $0.toSwift }.joined(separator: ", ")
    }

    func encode(c def: [ArgsT]) -> String {
        return def.map { $0.toC }.joined(separator: ",")
    }
    
    var encodedFuncname: String {
        guard let range = ov_cimguiname.range(of: funcname) else {
            return funcname
        }
        
        //let prefix: String = String(ov_cimguiname[ov_cimguiname.startIndex..<range.lowerBound])
        let postfix: String = String(ov_cimguiname[range.upperBound..<ov_cimguiname.endIndex])
        
        return funcname + postfix
    }

    var toSwift: String {
        return """
        @inlinable public func \(encodedFuncname)(\(encode(swift: self.argsT))) -> \(ret.toSwift) {
        \t\(self.ret == .void ? "" : "return ")\(self.ov_cimguiname)(\(encode(c: self.argsT)))
        }
        """
    }

}
extension FunctionDef: Equatable { }
extension FunctionDef: Hashable { }

struct Definition: Decodable {
    enum Keys: String, CodingKey {
        case funcname
        case destructor
        case constructor
    }

    let functions: Set<FunctionDef>
    let destructors: [DestructorDef]
    let constructors: [ConstructorDef]
    
    var validFunctions: Set<FunctionDef> {
        return functions.filter { $0.isValid }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        var functions: Set<FunctionDef> = []
        var destructors: [DestructorDef] = []
        var constructors: [ConstructorDef] = []

        if container.contains(.funcname) && !container.contains(.destructor) && !container.contains(.constructor) {
            functions.insert(try FunctionDef(from: decoder))
        } else if container.contains(.destructor) {
            destructors.append(try DestructorDef(from: decoder))
        } else if container.contains(.constructor) {
            constructors.append(try ConstructorDef(from: decoder))
        }
        
        self.functions = functions
        self.destructors = destructors
        self.constructors = constructors
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
