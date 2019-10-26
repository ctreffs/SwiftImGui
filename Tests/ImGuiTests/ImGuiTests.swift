import XCTest
import ImGui

final class ImGuiTests: XCTestCase {
    func testVersion() {
        XCTAssertNotNil(ImGuiGetVersion())
        XCTAssertEqual(ImGuiGetVersion(), "1.74 WIP")
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGuiCreateContext(nil))
    }

    func testGetIO() {
        XCTAssertNotNil(ImGuiGetIO())
    }
}
