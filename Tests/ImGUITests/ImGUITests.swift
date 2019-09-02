import XCTest
import ImGUI

final class ImGUITests: XCTestCase {
    func testVersion() {
        XCTAssertFalse(ImGui.GetVersion().isEmpty)
    }

    func testCreateContext() {
        XCTAssertNotNil(ImGui.CreateContext())
    }

    func testGetIO() {
        XCTAssertNotNil(ImGui.GetIO())
    }
}
