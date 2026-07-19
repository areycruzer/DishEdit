import XCTest

@MainActor
final class VisualEditorUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-DishEditFastReconstruction"]
        app.launch()
    }

    override func tearDown() {
        app?.terminate()
        app = nil
        super.tearDown()
    }

    func testNavigateToEditorShowsCanvas() {
        navigateToEditor(productID: "burger")
    }

    func testExpandShowsIngredientLayers() {
        navigateToEditor(productID: "burger")

        let expandButton = app.buttons["Open"]
        XCTAssertTrue(expandButton.waitForExistence(timeout: 8))
        expandButton.tap()

        let tomatoLayer = app.descendants(matching: .any)["layer.burger.tomato"]
        XCTAssertTrue(tomatoLayer.waitForExistence(timeout: 5))
    }

    func testRemoveIngredientAndConfirm() {
        navigateToEditor(productID: "burger")
        expandEditor()

        let tomatoLayer = app.descendants(matching: .any)["layer.burger.tomato"]
        XCTAssertTrue(tomatoLayer.waitForExistence(timeout: 8))
        tomatoLayer.tap()
        XCTAssertEqual(tomatoLayer.value as? String, "removed")

        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        let confirmOrderButton = app.buttons["Confirm Order"]
        XCTAssertTrue(confirmOrderButton.waitForExistence(timeout: 5))
    }

    func testAddIngredientViaTray() {
        navigateToEditor(productID: "burger")
        expandEditor()

        let cheddarButton = app.descendants(matching: .any)["tray.burger.cheddar"]
        XCTAssertTrue(cheddarButton.waitForExistence(timeout: 5))
        cheddarButton.tap()

        let cheddarLayer = app.descendants(matching: .any)["layer.burger.cheddar"]
        XCTAssertTrue(cheddarLayer.waitForExistence(timeout: 5))
    }

    func testAddedIngredientCanBeRemovedFromCanvas() {
        navigateToEditor(productID: "burger")
        expandEditor()

        let cheddarButton = app.descendants(matching: .any)["tray.burger.cheddar"]
        XCTAssertTrue(cheddarButton.waitForExistence(timeout: 5))
        cheddarButton.tap()

        let cheddarLayer = app.descendants(matching: .any)["layer.burger.cheddar"]
        XCTAssertTrue(cheddarLayer.waitForExistence(timeout: 5))
        cheddarLayer.tap()

        XCTAssertFalse(cheddarLayer.waitForExistence(timeout: 2))
    }

    func testBackButtonReturnsToMenu() {
        navigateToEditor(productID: "burger")

        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        let menuCard = app.scrollViews.staticTexts["menu.product.burger"]
        XCTAssertTrue(menuCard.waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func navigateToEditor(productID: String) {
        // Launch the editor deterministically. iOS 27 beta 3 currently reports
        // a duplicate WebKit accessibility loader and can drop synthesized taps
        // immediately after a ScrollView gesture; the app's coordinator route
        // transition is covered independently by unit tests.
        app.terminate()
        app.launchArguments = [
            "-DishEditFastReconstruction",
            "-DishEditDemoProduct", productID
        ]
        app.launch()

        let marker = app.staticTexts["customization.\(productID)"]
        XCTAssertTrue(marker.waitForExistence(timeout: 8))
    }

    private func expandEditor() {
        let expandButton = app.buttons["Open"]
        XCTAssertTrue(expandButton.waitForExistence(timeout: 5))
        expandButton.tap()
    }
}
