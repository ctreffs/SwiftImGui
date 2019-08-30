import XCTest
import ImGUI

final class ImGUITests: XCTestCase {
    func testVersion() {
        XCTAssertFalse(ImGui.version().isEmpty)
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGui.createContext())
    }

    func testShowDemoWindow() {
        ImGui.showDemoWindow()
    }
}
