//
//  DataType.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

struct DataType: Decodable {
    enum MetaType: Equatable, Hashable {
        case primitive
        case arrayFixedSize(Int)
        case pointer
        case reference

        case unknown
    }

    enum ValueType: Equatable, Hashable {
        case void
        case bool
        case int
        case uint
        case char
        case float
        case double
        case size_t
        case va_list
        case custom(String)

        case unknown

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
    }

    let meta: MetaType
    let isConst: Bool
    let type: ValueType

    @inlinable var isValid: Bool {
        return meta != .unknown && type != .unknown
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self.init(string: raw)
    }

    init(string: String) {

        var string = string

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
            string.removeSubrange(unsigned)
            string = string.replacingOccurrences(of: "int", with: "uint")
            string = string.trimmingCharacters(in: .whitespaces)
        }

        precondition(!string.contains("const"))
        precondition(!string.contains("unsigned"))

        if let primitive = ValueType(rawValue: string) {
            // primitive types int, char, float ....
            self.type = primitive
            self.meta = .primitive
            return
        }

        if let firstAsterisk = string.firstIndex(of: "*") {
            // TODO: parse complex types

            guard let lastAsertisk = string.lastIndex(of: "*") else {
                assertionFailure("should not happen since we already tested for at least one asterisk")
                self.meta = .unknown
                self.type = .unknown
                return
            }

            if firstAsterisk == lastAsertisk {
                // only one '*' present -> simple pointer
                let dataType = DataType(string: String(string[string.startIndex..<firstAsterisk].trimmingCharacters(in: .whitespaces)))

                self.meta = .pointer
                self.type = dataType.type

            } else {
                // TODO: handle array pointer
                self.type = .unknown
                self.meta = .unknown
            }

        } else if let ref = string.firstIndex(of: "&") {
            // i.e. float&, ImVector&
            let dataType = DataType(string: String(string[string.startIndex..<ref]))
            self.meta = .reference
            self.type = dataType.type

        } else if let startFixArr = string.firstIndex(of: "["), let endFixArr = string.firstIndex(of: "]") {
            // i.e. float[4]
            let numRange = string.index(after: startFixArr)..<endFixArr
            let count = Int(string[numRange])!
            let dataType = DataType(string: String(string[string.startIndex..<startFixArr]))

            self.meta = .arrayFixedSize(count)
            self.type = dataType.type

        } else {
            // primitive custom types ImVec2, ImVector, T ...

            self.meta = .primitive
            self.type = .custom(string)

        }

        // FIXME: special handle 'T'

    }

    //
    //    var toSwift: String {
    //        switch (type, meta, isConst) {
    //        case (.void, _, _):
    //            return "Void"
    //        case (.bool, _, _):
    //            return "Bool"
    //        case (.int, _, _):
    //            return "Int32"
    //        case (.uint, _, _):
    //            return "UInt32"
    //        case (.char, _, _):
    //            return "CChar"
    //        case (.float, _, _):
    //            return "Float"
    //        case (.double, _, _):
    //            return "Double"
    //        case (.size_t, _, _):
    //            return "Int"
    //        case (.va_list, _, _):
    //            return "CVarArg..."
    //        case let (_,.arrayFixedSize(count), const) where const == true:
    //            return "(\((0..<count).map { _ in type.toSwift }.joined(separator: ",")))"
    //        case let (_,.arrayFixedSize(count), const) where const == false:
    //            return "inout [\(type)]"
    //        case let .reference(dataType):
    //            return "inout \(dataType.toSwift)"
    //        case let .pointer(dataType) where dataType == .char:
    //            return "String"
    //        case let .pointer(dataType):
    //            return "inout \(dataType.toSwift)"
    //        case let .custom(string):
    //            return string
    //        case .unknown:
    //            return "<#TYPE#>"
    //        }
    //    }
    //
    //    var returnSwift: String {
    //        switch self {
    //           case .void:
    //               return "Void"
    //           case .bool:
    //               return "Bool"
    //           case .int:
    //               return "Int32"
    //           case .uint:
    //               return "UInt32"
    //           case .char:
    //               return "CChar"
    //           case .float:
    //               return "Float"
    //           case .double:
    //               return "Double"
    //           case .size_t:
    //               return "Int"
    //           case .va_list:
    //               return "CVarArg..."
    //           case let .arrayFixedSize(dataType, count):
    //               //return "(\((0..<count).map { _ in dataType.toSwift }.joined(separator: ",")))"
    //                return "UnsafeMutablePointer<\(dataType.toSwift)>!"
    //           case let .reference(dataType):
    //               return "UnsafeMutablePointer<\(dataType.toSwift)>!"
    //           case let .pointer(dataType) where dataType == .char:
    //               return "String"
    //           case let .pointer(dataType):
    //               return "UnsafeMutablePointer<\(dataType.toSwift)>!"
    //           case let .custom(string):
    //               return string
    //           case .unknown:
    //               return "<#TYPE#>"
    //           }
    //    }
    //
    //    func fromSwift(name: String) -> String {
    //        switch self {
    //        case let .pointer(dataType) where dataType == .char:
    //            return "\(name).cStrPtr()"
    //        case .reference, .pointer, .arrayFixedSize:
    //            return "&\(name)"
    //        default:
    //            return "\(name)"
    //        }
    //    }

}

extension DataType: Equatable { }
extension DataType: Hashable { }
