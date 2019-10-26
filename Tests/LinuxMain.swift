import XCTest

import ImGuiTests

var tests = [XCTestCaseEntry]()
tests += ImGuiTests.__allTests()

XCTMain(tests)
