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

    func testNavigateToEditorShowsCanvas() {
        let editButton = app.scrollViews.buttons["menu.edit-visually.burger"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let marker = app.staticTexts["customization.burger"]
        XCTAssertTrue(marker.waitForExistence(timeout: 5))
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

    func testBackButtonReturnsToMenu() {
        navigateToEditor(productID: "burger")

        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        let menuCard = app.scrollViews.otherElements["menu.product.burger"]
        XCTAssertTrue(menuCard.waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func navigateToEditor(productID: String) {
        let editButton = app.scrollViews.buttons["menu.edit-visually.\(productID)"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let marker = app.staticTexts["customization.\(productID)"]
        XCTAssertTrue(marker.waitForExistence(timeout: 5))
    }

    private func expandEditor() {
        let expandButton = app.buttons["Open"]
        XCTAssertTrue(expandButton.waitForExistence(timeout: 5))
        expandButton.tap()
    }
}
