//
//  Definitions.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

public typealias Definitions = [String: [Definition]]

public struct DestructorDef: Decodable {
    public let destructor: Bool
    public let args: String
    public let signature: String
    public let cimguiname: String
    public let stname: String
    public let argsT: [ArgsT]
}

public struct ConstructorDef: Decodable {
    public let constructor: Bool
    public let args: String
    public let signature: String
    public let cimguiname: String
    public let stname: String
    public let argsT: [ArgsT]
}

public struct FunctionDef: Decodable {
    public let funcname: String
    public let args: String
    public let signature: String
    public let cimguiname: String
    // swiftlint:disable:next identifier_name
    public let ov_cimguiname: String
    public let stname: String
    public let argsT: [ArgsT]
    public let ret: DataType?
    public let templated = false
    public let namespace: String?

    @inlinable public var isValid: Bool {
        argsT.allSatisfy(\.isValid) && returnType.isValid && !Exceptions.unresolvedIdentifier.contains(ov_cimguiname)
    }

    public func encode(swift def: [ArgsT]) -> String {
        def.map(\.toSwift).joined(separator: ", ")
    }

    public var encodedFuncname: String {
        guard let range = ov_cimguiname.range(of: funcname), !range.isEmpty else {
            assertionFailure("Original name should contain funcname")
            return funcname
        }

        let name: String = funcname

        var prefix: String
        if let namespace = namespace, !namespace.isEmpty {
            prefix = namespace
        } else {
            prefix = String(ov_cimguiname[ov_cimguiname.startIndex ..< range.lowerBound])
        }

        if Exceptions.stripPrefix.contains(prefix) {
            prefix = ""
        }

        // let suffix = String(ov_cimguiname[range.upperBound..<ov_cimguiname.endIndex])
        let combinedName = prefix + name
        return combinedName.replacingOccurrences(of: "_", with: "")
    }

    public var returnType: DataType {
        guard let ret = ret else {
            return DataType(meta: .primitive, type: .void, isConst: false)
        }

        return ret
    }

    public func wrapCCall(_ call: @autoclosure () -> String) -> String {
        switch (returnType.meta, returnType.type) {
        case (.pointer, .char):
            return "String(cString: \(call()))"
        default:
            return call()
        }
    }

    public var innerReturn: String {
        switch returnType.type {
        case .void where returnType.isConst == true:
            return ""
        default:
            return "return "
        }
    }

    public var funcDefs: String {
        switch returnType.type {
        case .bool:
            return "@inlinable @discardableResult public func"
        default:
            return "@inlinable public func"
        }
    }

    public var toSwift: String {
        // \t\(innerReturn)\(wrapCCall("\(self.ov_cimguiname)(\(encode(c: self.argsT)))"))
        """
        \(funcDefs) \(encodedFuncname)(\(encode(swift: argsT))) -> \(returnType.toString(nil, .ret)) {
        \(FunctionBodyRenderer.render(ov_cimguiname, argsT, returnType))
        }
        """
    }
}

extension FunctionDef: Equatable {}
extension FunctionDef: Hashable {}
extension FunctionDef: Comparable {
    public static func < (lhs: FunctionDef, rhs: FunctionDef) -> Bool {
        lhs.encodedFuncname < rhs.encodedFuncname
    }
}

public struct Definition: Decodable {
    public enum Keys: String, CodingKey {
        case funcname
        case destructor
        case constructor
    }

    public let functions: Set<FunctionDef>
    public let destructors: [DestructorDef]
    public let constructors: [ConstructorDef]

    public var validFunctions: Set<FunctionDef> {
        functions.filter(\.isValid)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        var functions: Set<FunctionDef> = []
        var destructors: [DestructorDef] = []
        var constructors: [ConstructorDef] = []

        if container.contains(.funcname), !container.contains(.destructor), !container.contains(.constructor) {
            do {
                try functions.insert(FunctionDef(from: decoder))
            } catch {
                print("DECODING ERROR FunctionDef", decoder.codingPath, error.localizedDescription)
            }
        } else if container.contains(.destructor) {
            do {
                try destructors.append(DestructorDef(from: decoder))
            } catch {
                print("DECODING ERROR DestructorDef", decoder.codingPath, error.localizedDescription)
            }
        } else if container.contains(.constructor) {
            do {
                try constructors.append(ConstructorDef(from: decoder))
            } catch {
                print("DECODING ERROR ConstructorDef", decoder.codingPath, error.localizedDescription)
            }
        }

        self.functions = functions
        self.destructors = destructors
        self.constructors = constructors
    }
}
