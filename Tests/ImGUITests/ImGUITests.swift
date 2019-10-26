import XCTest
import ImGUI

final class ImGUITests: XCTestCase {
    func testVersion() {
        XCTAssertNotNil(ImGuiGetVersion())
        XCTAssertFalse(ImGuiGetVersion().isEmpty)
        print(ImGuiGetVersion())
        XCTAssertEqual(ImGuiGetVersion(), "1.74 WIP")
    }

    func testCreateContext() {
        var fontAtlass = ImFontAtlas()
        XCTAssertNotNil(ImGuiCreateContext(&fontAtlass))
    }

    func testGetIO() {
        XCTAssertNotNil(ImGuiGetIO())
    }
}
