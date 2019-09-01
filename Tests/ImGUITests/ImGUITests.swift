import XCTest
import ImGUI

final class ImGUITests: XCTestCase {
    func testVersion() {
        XCTAssertFalse(ImGui.GetVersion().isEmpty)
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGui.CreateContext())
    }

    func testShowDemoWindow() {
        var show = true
        ImGui.ShowDemoWindow(&show)
    }
}
