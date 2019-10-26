//
//  DataType.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

struct DataType: Decodable {
    let meta: MetaType
    let isConst: Bool
    let type: ValueType

    init(meta: MetaType, type: ValueType, isConst: Bool) {
        self.meta = meta
        self.type = type
        self.isConst = isConst
    }

    @inlinable var isValid: Bool {
        return meta != .unknown && type != .unknown && type != .generic
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

        if let startFixArr = string.firstIndex(of: "["), let endFixArr = string.firstIndex(of: "]") {
            // i.e. float[4]
            let numRange = string.index(after: startFixArr)..<endFixArr
            let count = Int(string[numRange]) ?? -1
            let dataType = DataType(string: String(string[string.startIndex..<startFixArr]))

            if count == -1 {
                self.meta = .array
                self.type = dataType.type
            } else {
                self.meta = .arrayFixedSize(count)
                self.type = dataType.type
            }

        } else if let firstAsterisk = string.firstIndex(of: "*") {
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

                switch dataType.meta {
                case .exception:
                    self.meta = dataType.meta
                    self.type = dataType.type
                default:
                    self.meta = .pointer
                    self.type = dataType.type
                }

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

        } else {
            // primitive custom types ImVec2, ImVector, T ...

            if let exceptionType = Exceptions.undeclardTypes[string] {
                self.meta = .exception(exceptionType)
                self.type = .custom(string)
                return
            }

            self.meta = .primitive
            self.type = .custom(string)

        }

        // FIXME: special handle 'T'

    }

    enum Context {
        case argSwift
        case argC
        case ret
    }

    func wrapIn(_ context: Context, _ toWrap: String) -> String {

        switch meta {
        case .primitive:
            return toWrap
        case .array where isConst == true && type == .char:
            return "[String]"
        case .array where isConst == true:
            return "[\(toWrap)]"
        //return "UnsafePointer<\(toWrap)>!"
        case .array where type == .char:
            return "inout [String]"
        case .array:
            return "inout [\(toWrap)]"
        //return "inout UnsafePointer<\(toWrap)>!"
        case let .arrayFixedSize(size) where isConst == false:
            // tuple
            return "inout (\((0..<size).map({_ in toWrap }).joined(separator: ",")))"
        case let .arrayFixedSize(size):
            return "(\((0..<size).map({_ in toWrap }).joined(separator: ",")))"
        case .pointer where isConst == true && type == .char:
            // const char* -> String
            return toWrap
        case .pointer where isConst == false && type == .char:
            // char* -> String
            return "inout \(toWrap)"
        case .pointer where isConst == true && type == .void:
            return "UnsafeRawPointer!"
        case .pointer where isConst == false && type == .void:
            return "UnsafeMutableRawPointer!"
        case .pointer where isConst == true:
            return "UnsafePointer<\(toWrap)>!"
        case .pointer where context == .argSwift:
            return "inout \(toWrap)"
        case .pointer:
            return "UnsafeMutablePointer<\(toWrap)>!"
        case .reference where context == .argC && isConst == false:
            return "&\(toWrap)"
        case .reference where context == .argSwift && isConst == false:
            return "inout \(toWrap)"
        case .reference:
            return "<#\(toWrap)#>"
        case .unknown:
            return "<#\(toWrap)#>"
        case let .exception(decl):
            return decl.name
        }

    }

    func toString(_ context: Context, wrapped: Bool = true) -> String {
        let out: String

        switch type {

        case .void:
            out = "Void"
        case .bool:
            out = "Bool"
        case .int:
            out = "Int32"
        case .uint:
            out = "UInt32"
        case .char where meta == .pointer:
            out = "String"
        case .char:
            out = "CChar"
        case .float:
            out = "Float"
        case .double:
            out = "Double"
        case .size_t:
            out = "Int"
        case .va_list:
            out = "CVarArg..."
        case let .custom(value):
            out = value
        case .unknown:
            out = "<#CODE#>"
        case .generic:
            out = "<#T#>"
        }

        if wrapped {
            return wrapIn(context, out)
        } else {
            return out
        }

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

// MARK: - MetaType
extension DataType {
    enum MetaType: Equatable, Hashable {
        case primitive
        case arrayFixedSize(Int)
        case array
        case pointer
        case reference

        case unknown
        case exception(Declaration)
    }

}

// MARK: - Value Type
extension DataType {

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

        case generic
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
            case "T":
                self = .generic
            default:
                return nil
            }
        }

    }
}
