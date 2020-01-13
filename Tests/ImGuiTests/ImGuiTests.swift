import ImGui
import XCTest

public final class ImGuiTests: XCTestCase {
    func testVersion() {
        XCTAssertNotNil(ImGuiGetVersion())
        XCTAssertEqual(ImGuiGetVersion(), "1.74 WIP")
        IMGUI_CHECKVERSION()
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGuiCreateContext(nil))
    }

    func testGetIO() {
        XCTAssertNotNil(ImGuiGetIO())
    }
}
