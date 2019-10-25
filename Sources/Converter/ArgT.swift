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
        if let range = raw.range(of: "const ") {
            self.isConst = true
            raw.removeSubrange(range)
        } else {
            self.isConst = false
        }

        // unsigned
        if let unsigned = raw.range(of: "unsigned ") {
            self.isUnsigned = true
            raw.removeSubrange(unsigned)
        } else {
            self.isUnsigned = false
        }

        self.type = DataType(string: raw)
    }

}
extension ArgType: Equatable { }
extension ArgType: Hashable { }


struct ArgsT: Decodable {
    let name: String
    let type: ArgType
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
        self.type = try container.decode(ArgType.self, forKey: .type)
        self.ret = try container.decodeIfPresent(String.self, forKey: .ret)
        self.signature = try container.decodeIfPresent(String.self, forKey: .signature)
    }
    
    @inlinable var isValid: Bool {
        return type.isValid
    }

    var toSwift: String {
        return "\(self.name): \(self.type.type.toSwift)"
    }

    var toC: String {
        switch type.type {
        case .reference:
            return "&\(self.name)"
        default:
            return "\(self.name)"
        }
    }
}

extension ArgsT: Equatable { }
extension ArgsT: Hashable { }
