import XCTest

final class PersilladeUITests: XCTestCase {
    @MainActor
    func testOngletsEtReglages() {
        let app = XCUIApplication()
        app.launch()

        let onglets = app.tabBars.firstMatch
        for titre in ["Recettes", "Semaine", "Courses"] {
            let onglet = onglets.buttons[titre]
            XCTAssertTrue(onglet.exists)
            onglet.tap()
            XCTAssertTrue(app.navigationBars[titre].exists)
        }
        app.navigationBars["Courses"].buttons["Réglages"].tap()
        XCTAssertTrue(app.navigationBars["Réglages"].exists)
        app.navigationBars["Réglages"].buttons["Fermer"].tap()
        XCTAssertTrue(app.navigationBars["Courses"].exists)
    }
}
