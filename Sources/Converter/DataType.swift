//
//  DataType.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

indirect enum DataType: Decodable {
    case void
    case bool
    case int
    case uint
    case char
    case float
    case double
    case size_t
    case va_list
    case arrayFixedSize(DataType, Int)
    case pointer(DataType)
    case reference(DataType)
    case custom(String)
    case unknown

    @inlinable var isValid: Bool {
        return self != .unknown
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self.init(string: raw)
    }

    init(string: String) {

        var string = string
        let isConst: Bool
        let isUnsigned: Bool

        // const
        if let range = string.range(of: "const") {
            isConst = true
            string.removeSubrange(range)
            string = string.replacingOccurrences(of: "const", with: "")
            string = string.trimmingCharacters(in: .whitespaces)
        } else {
            isConst = false
        }

        // unsigned
        if let unsigned = string.range(of: "unsigned") {
            isUnsigned = true
            string.removeSubrange(unsigned)
            string = string.replacingOccurrences(of: "int", with: "uint")
            string = string.trimmingCharacters(in: .whitespaces)
        } else {
            isUnsigned = false
        }

        precondition(!string.contains("const"))
        precondition(!string.contains("unsigned"))

        if let direct = DataType(rawValue: string) {
            self = direct
            return
        }

        if let firstAsterisk = string.firstIndex(of: "*") {
            // TODO: parse complex types

            guard let lastAsertisk = string.lastIndex(of: "*") else {
                assertionFailure("should not happen since we already tested for at least one asterisk")
                self = .unknown
                return
            }

            if firstAsterisk == lastAsertisk {
                // only one '*' present -> simple pointer
                let dataType = DataType(string: String(string[string.startIndex..<firstAsterisk].trimmingCharacters(in: .whitespaces)))
                print(string, dataType)
                self = .pointer(dataType)
            } else {
                self = .unknown
            }

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
        case "uint":
            self = .uint
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
        case .uint:
            return "UInt32"
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
        case let .pointer(dataType) where dataType == .char:
            return "String"
        case let .pointer(dataType):
            return "inout \(dataType.toSwift)"
        case let .custom(string):
            return string
        case .unknown:
            return "<#TYPE#>"

        }
    }

    func fromSwift(name: String) -> String {
        switch self {
        case let .pointer(dataType) where dataType == .char:
            return "\(name).cStrPtr()"
        case .reference, .pointer:
            return "&\(name)"
        default:
            return "\(name)"
        }
    }

}

extension DataType: Equatable { }
extension DataType: Hashable { }
