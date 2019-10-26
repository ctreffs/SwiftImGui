//
//  File.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

struct ArgType: Decodable {

    let isConst: Bool

    let isUnsigned: Bool

    let type: DataType

    @inlinable var isValid: Bool {
        return type.isValid
    }

    init(from decoder: Decoder) throws {
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

struct ArgsT: Decodable {
    let name: String
    let type: DataType
    let ret: String?
    let signature: String?

    enum Keys: String, CodingKey {
        case name
        case type
        case ret
        case signature
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.name = try container.decode(String.self, forKey: .name).swiftEscaped
        self.type = try container.decode(DataType.self, forKey: .type)
        self.ret = try container.decodeIfPresent(String.self, forKey: .ret)
        self.signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }

    @inlinable var isValid: Bool {
        return type.isValid && name != "..."
    }

    var argName: String {
        switch name {
        case "...":
            return "arguments"
        default:
            return name
        }
    }

    var toSwift: String {
        switch self.type.type {
        case let .custom(name) where name.hasSuffix("Callback") && argName.contains("callback"):
            return "_ \(argName): @escaping \(self.type.toString(.argSwift))"
        default:
            return "_ \(argName): \(self.type.toString(.argSwift))"
        }
    }

    func wrapCArg(_ arg: String) -> String {
        switch self.type.meta {
        case .primitive:
            return arg
        case .array where self.type.type == .char:
            return "\(arg).map { $0.cStrPtr() }"
        case .array:
            return "&\(arg)"
        case let .arrayFixedSize(count) where self.type.isConst == false:
            return "UnsafeMutableBufferPointer<\(self.type.toString(.argSwift, wrapped: false))>(start: &\(arg).0, count: \(count)).baseAddress!"
            case let .arrayFixedSize(count):
                return "UnsafeBufferPointer<\(self.type.toString(.argSwift, wrapped: false))>(start: &\(arg).0, count: \(count)).baseAddress!"
        case .reference:
            return "&\(arg)"
        case .pointer where self.type.isConst == false && self.type.type == .void:
            return arg
        case .pointer where self.type.type != .char && self.type.isConst == false:
            return "&\(arg)"
        case .pointer:
            return arg
        case .unknown:
            return arg
        case .exception:
            return arg
        }
    }

    var toC: String {
        var out: String = argName
        switch type.type {
        case .char where type.isConst == true && type.meta == .pointer:
            // const char*
            out.append(".cStrPtr()")
        case .char where type.isConst == false && type.meta == .pointer:
        // char*
            out.append(".cMutableStrPtr()")
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
