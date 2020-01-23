//
//  FunctionBodyRenderer.swift
//
//
//  Created by Christian Treffs on 23.01.20.
//

struct FunctionBodyRenderer {
    static func render(_ callName: String, _ args: [ArgsT], _ returnType: DataType) -> String {
        // determine if somethings needs to be pre- or appended depending on return type
        let prependCall: String
        let appendCall: String
        switch (returnType.meta, returnType.type) {
        case (.pointer, .char):
            prependCall = "String(cString: "
            appendCall = ")"
        default:
            prependCall = ""
            appendCall = ""
        }

        // insert return keyword if neccessary
        let returnKeyword: String
        switch returnType.type {
        case .void where returnType.isConst == true:
            returnKeyword = ""
        default:
            returnKeyword = "return "
        }

        var preCallLines: [String] = []
        var callArguments: [String] = []
        var postCallLines: [String] = []

        // parse arguments and construct lines
        for arg in args {
            for parsed in parse(cArg: arg) {
                switch parsed {
                case let .preLine(line):
                    preCallLines.append(line)

                case let .line(line):
                    callArguments.append(line)

                case let .postLine(line):
                    postCallLines.insert(line, at: 0)
                }
            }
        }

        // create call signature
        let callSignature = "\(returnKeyword)\(prependCall)\(callName)(" + callArguments.joined(separator: ",") + ")\(appendCall)"

        // render output
        assert(preCallLines.count == postCallLines.count)

        let functionBody: String
        if preCallLines.isEmpty {
            functionBody = "\t" + callSignature
        } else {
            var begin: String = ""
            var end: String = ""

            let maxIndentation: Int = preCallLines.count
            for (index, (pre, post)) in zip(preCallLines, postCallLines.reversed()).enumerated() {
                begin.append(String(repeating: "\t", count: index + 1) + pre + "\n")
                end.append(String(repeating: "\t", count: maxIndentation - index) + post + "\n")
            }

            functionBody = begin + String(repeating: "\t", count: maxIndentation + 1) + callSignature + "\n" + end
        }
        return functionBody
    }

    enum ParsedArg {
        case preLine(String)
        case line(String)
        case postLine(String)
    }

    static func parse(cArg arg: ArgsT) -> [ParsedArg] {
        switch arg.type.meta {
        case .primitive where arg.type.type == .va_list:
            return [
                .preLine("withVaList(\(arg.escapedName)) { varArgsPtr in"),
                .line("varArgsPtr"),
                .postLine("}")
            ]

        case .primitive:
            return [.line(arg.escapedName)]

        case .array where arg.type.type == .char:
            return [
                .preLine("withArrayOfCStringsBasePointer(\(arg.escapedName)) { \(arg.name)Ptr in"),
                .line("\(arg.name)Ptr"),
                .postLine("}")
            ]

        case .array, .reference:
            return [.line("&\(arg.escapedName)")]

        case let .arrayFixedSize(count) where arg.type.isConst == false:
            if arg.type.type.isNumber && count < 5 {
                // SIMD vector
                return [
                    .preLine("withUnsafeMutablePointer(to: &\(arg.escapedName)) { \(arg.name)MutPtr in"),
                    .preLine("\(arg.name)MutPtr.withMemoryRebound(to: \(arg.type.toString(.argSwift, wrapped: false)).self, capacity: \(count)) { \(arg.name)Ptr in"),
                    .line("\(arg.name)Ptr"),
                    .postLine("}"),
                    .postLine("}")
                ]
            } else {
                return [.line("UnsafeMutableBufferPointer<\(arg.type.toString(.argSwift, wrapped: false))>(start: &\(arg.escapedName).0, count: \(count)).baseAddress!")]
            }

        case let .arrayFixedSize(count):
            return [.line("UnsafeMutableBufferPointer<\(arg.type.toString(.argSwift, wrapped: false))>(start: &\(arg.escapedName).0, count: \(count)).baseAddress!")]

        case .pointer where arg.type.isConst == false && arg.type.type == .void:
            return [.line(arg.escapedName)]

        case .pointer where arg.type.type != .char && arg.type.isConst == false:
            return [.line(arg.escapedName)]

        case .pointer where arg.type.type == .char && arg.type.isConst == true:
            // const char*
            return [
                .preLine("\(arg.escapedName)!.withCString { \(arg.name)Ptr in"),
                .line("\(arg.name)Ptr"),
                .postLine("}")
            ]

        case .pointer where arg.type.type == .char && arg.type.isConst == false:
            // char*
            return [
                .preLine("\(arg.escapedName)!.withCString { \(arg.name)Ptr in"),
                .line("UnsafeMutablePointer(mutating: \(arg.name)Ptr)"),
                .postLine("}")
            ]

        case .pointer:
            return [.line(arg.escapedName)]

        case .unknown:
            return [.line(arg.escapedName)]

        case .exception:
            return [.line(arg.escapedName)]
        }
    }
}
