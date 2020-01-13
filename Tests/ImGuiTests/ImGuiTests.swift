import ImGui
import XCTest

final class ImGuiTests: XCTestCase {
    func testImGuiVersion() {
        XCTAssertNotNil(ImGuiGetVersion())
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
