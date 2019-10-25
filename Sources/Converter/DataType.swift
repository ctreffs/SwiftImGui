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
    case char
    case float
    case double
    case size_t
    case va_list
    case arrayFixedSize(DataType, Int)
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

extension DataType: Equatable { }
extension DataType: Hashable { }
