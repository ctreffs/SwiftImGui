import ImGui
import XCTest

final class ImGuiTests: XCTestCase {
    func testImGuiVersion() {
        XCTAssertNotNil(ImGuiGetVersion())
        XCTAssertEqual(ImGuiGetVersion(), "1.74 WIP")
        IMGUI_CHECKVERSION()
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGuiCreateContext(nil))
        ImGuiDestroyContext(ImGuiGetCurrentContext())
    }

    func testGetIO() {
        XCTAssertNotNil(ImGuiCreateContext(nil))
        XCTAssertNotNil(ImGuiGetIO())
        ImGuiDestroyContext(ImGuiGetCurrentContext())
    }
}
