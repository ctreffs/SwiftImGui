//
//  ArgT.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

public struct ArgType: Decodable {
    public let isConst: Bool
    public let isUnsigned: Bool
    public let type: DataType

    @inlinable public var isValid: Bool {
        type.isValid
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var raw: String = try container.decode(String.self)

        // const
        if let range = raw.range(of: "const") {
            self.isConst = true
            raw.removeSubrange(range)
            raw = raw.replacingOccurrences(of: "const", with: "")
            raw = raw.trimmingCharacters(in: .whitespaces)
        } else {
            self.isConst = false
        }

        // unsigned
        if let unsigned = raw.range(of: "unsigned") {
            self.isUnsigned = true
            raw.removeSubrange(unsigned)
            raw = raw.trimmingCharacters(in: .whitespaces)
        } else {
            self.isUnsigned = false
        }

        precondition(!raw.contains("const"))
        precondition(!raw.contains("unsigned"))
        self.type = DataType(string: raw)
    }
}
extension ArgType: Equatable { }
extension ArgType: Hashable { }

public struct ArgsT: Decodable {
    public let escapedName: String
    public let name: String
    public let type: DataType
    public let ret: String?
    public let signature: String?

    public enum Keys: String, CodingKey {
        case name
        case type
        case ret
        case signature
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let rawName = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(DataType.self, forKey: .type)

        self.name = rawName
        let escapedName = rawName.swiftEscaped
        switch escapedName {
        case "...":
            self.escapedName = "arguments"
        default:
            self.escapedName = escapedName
        }

        self.ret = try container.decodeIfPresent(String.self, forKey: .ret)
        self.signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }

    @inlinable public var isValid: Bool {
        type.isValid && name != "..."
    }

    public var toSwift: String {
        switch self.type.type {
        case let .custom(name) where name.hasSuffix("Callback") && escapedName.contains("callback"):
            return "_ \(escapedName): @escaping \(self.type.toString(self, .argSwift))"
        default:
            return "_ \(escapedName): \(self.type.toString(self, .argSwift, defaultArg: true))"
        }
    }
}

extension ArgsT: Equatable { }
extension ArgsT: Hashable { }
