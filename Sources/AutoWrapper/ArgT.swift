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
            isConst = true
            raw.removeSubrange(range)
            raw = raw.replacingOccurrences(of: "const", with: "")
            raw = raw.trimmingCharacters(in: .whitespaces)
        } else {
            isConst = false
        }

        // unsigned
        if let unsigned = raw.range(of: "unsigned") {
            isUnsigned = true
            raw.removeSubrange(unsigned)
            raw = raw.trimmingCharacters(in: .whitespaces)
        } else {
            isUnsigned = false
        }

        precondition(!raw.contains("const"))
        precondition(!raw.contains("unsigned"))
        type = DataType(string: raw)
    }
}

extension ArgType: Equatable {}
extension ArgType: Hashable {}

public struct ArgsT: Decodable {
    public let escapedName: String
    public let name: String
    public let type: DataType
    public let ret: String?
    public let signature: String?

    private let escapingCallbackExceptions: Set<String> = [
        "ImGuiErrorLogCallback",
    ]

    public enum Keys: String, CodingKey {
        case name
        case type
        case ret
        case signature
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let rawName = try container.decode(String.self, forKey: .name)
        type = try container.decode(DataType.self, forKey: .type)

        name = rawName
        let escapedName = rawName.swiftEscaped
        switch escapedName {
        case "...":
            self.escapedName = "arguments"
        default:
            self.escapedName = escapedName
        }

        ret = try container.decodeIfPresent(String.self, forKey: .ret)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }

    @inlinable public var isValid: Bool {
        type.isValid && name != "..."
    }

    public var toSwift: String {
        switch type.type {
        case let .custom(name) where name.hasSuffix("Callback") && escapedName.contains("callback")
            && !escapingCallbackExceptions.contains(name):
            return "_ \(escapedName): @escaping \(type.toString(self, .argSwift))"
        default:
            return "_ \(escapedName): \(type.toString(self, .argSwift, defaultArg: true))"
        }
    }
}

extension ArgsT: Equatable {}
extension ArgsT: Hashable {}
