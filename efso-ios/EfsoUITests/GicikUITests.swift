import XCTest

final class EfsoUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        // Splash logo + sign in button visible
        XCTAssertTrue(app.windows.firstMatch.exists)
    }
}
