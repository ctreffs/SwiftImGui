//
//  SwiftKeyword.swift
//
//
//  Created by Christian Treffs on 25.10.19.
//

// swiftlint:disable identifier_name
public enum SwiftKeyword: String {
    case `Self`
    case `Type`
    case `as`
    case `associatedtype`
    case `associativity`
    case `break`
    case `case`
    case `catch`
    case `class`
    case `continue`
    case `convenience`
    case `default`
    case `defer`
    case `deinit`
    case `didSet`
    case `do`
    case `dynamic`
    case `else`
    case `enum`
    case `extension`
    case `fallthrough`
    case `false`
    case `fileprivate`
    case `final`
    case `for`
    case `func`
    case `get`
    case `guard`
    case `if`
    case `import`
    case `in`
    case `indirect`
    case `infix`
    case `init`
    case `inout`
    case `internal`
    case `is`
    case `lazy`
    case `left`
    case `let`
    case `mutating`
    case `nil`
    case `none`
    case `nonmutating`
    case `open`
    case `operator`
    case `optional`
    case `override`
    case `postfix`
    case `precedence`
    case `prefix`
    case `private`
    case `protocol`
    case `public`
    case `repeat`
    case `required`
    case `rethrows`
    case `return`
    case `right`
    case `self`
    case `set`
    case `static`
    case `struct`
    case `subscript`
    case `super`
    case `switch`
    case `throw`
    case `throws`
    case `true`
    case `try`
    case `typealias`
    case `unowned`
    case `var`
    case `weak`
    case `where`
    case `while`
    case `willSet`
}

extension String {
    public var swiftEscaped: String {
        guard let swiftKeyword = SwiftKeyword(rawValue: self) else {
            return self
        }
        if swiftKeyword == .`self` || swiftKeyword == .Self {
            return "this"
        }

        return "`\(swiftKeyword.rawValue)`"
    }
}
