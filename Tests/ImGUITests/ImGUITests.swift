import XCTest
import ImGUI

final class ImGUITests: XCTestCase {
    func testHelloImGUI() {
        let vec = helloImGUI(x: 1, y: 2)
        XCTAssertEqual(vec, ImVec2(x: 1, y: 2))
    }
}
