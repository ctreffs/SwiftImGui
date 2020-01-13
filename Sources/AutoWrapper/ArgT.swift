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
        self.name = try container.decode(String.self, forKey: .name).swiftEscaped
        self.type = try container.decode(DataType.self, forKey: .type)
        self.ret = try container.decodeIfPresent(String.self, forKey: .ret)
        self.signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }

    @inlinable public var isValid: Bool {
        type.isValid && name != "..."
    }

    public var argName: String {
        switch name {
        case "...":
            return "arguments"
        default:
            return name
        }
    }

    public var toSwift: String {
        switch self.type.type {
        case let .custom(name) where name.hasSuffix("Callback") && argName.contains("callback"):
            return "_ \(argName): @escaping \(self.type.toString(.argSwift))"
        default:
            return "_ \(argName): \(self.type.toString(.argSwift))"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func wrapCArg(_ arg: String) -> String {
        switch self.type.meta {
        case .primitive:
            return arg

        case .array where self.type.type == .char:
            return "\(arg).map { $0.cStrPtr() }"
        case .array:
            return "&\(arg)"
        case let .arrayFixedSize(count) where self.type.isConst == false:
            if type.type.isNumber && count < 5 {
                // SIMD
                return "withUnsafeMutablePointer(to: &\(arg)) { $0.withMemoryRebound(to: \(self.type.toString(.argSwift, wrapped: false)).self, capacity: \(count)) { $0 } }"
            } else {
                return "UnsafeMutableBufferPointer<\(self.type.toString(.argSwift, wrapped: false))>(start: &\(arg).0, count: \(count)).baseAddress!"
            }

        case let .arrayFixedSize(count):
            return "UnsafeBufferPointer<\(self.type.toString(.argSwift, wrapped: false))>(start: &\(arg).0, count: \(count)).baseAddress!"
        case .reference:
            return "&\(arg)"
        case .pointer where self.type.isConst == false && self.type.type == .void:
            return arg

        case .pointer where self.type.type != .char && self.type.isConst == false:
            return "\(arg)"
        case .pointer:
            return arg

        case .unknown:
            return arg

        case .exception:
            return arg
        }
    }

    public var toC: String {
        var out: String = argName
        switch type.type {
        case .char where type.isConst == true && type.meta == .pointer:
            // const char*
            out.append("?.cStrPtr()")

        case .char where type.isConst == false && type.meta == .pointer:
            // char*
            out.append("?.cMutableStrPtr()")

        case .va_list:
            out = "withVaList(\(out), { $0 })"
        default:
            break
        }
        return wrapCArg(out)
    }
}

extension ArgsT: Equatable { }
extension ArgsT: Hashable { }
