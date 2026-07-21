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

    func testBurgerExpandedEditorUsesCommerceLanguageAndLargeControls() {
        navigateToEditor(productID: "burger")
        expandEditor()

        XCTAssertTrue(app.staticTexts["Customize burger"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Tap an ingredient to remove it"].exists)
        XCTAssertTrue(app.staticTexts["Add extras"].exists)

        let reviewButton = app.buttons["editor.confirm"]
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 5))
        XCTAssertEqual(reviewButton.label, "Review changes")
        XCTAssertGreaterThanOrEqual(reviewButton.frame.height, 52)

        let cheddarButton = app.descendants(matching: .any)["tray.burger.cheddar"]
        XCTAssertTrue(cheddarButton.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(cheddarButton.frame.height, 88)
    }

    func testSubExpandedEditorUsesTheSameCommerceLanguage() {
        navigateToEditor(productID: "sub")
        expandEditor()

        XCTAssertTrue(app.staticTexts["Customize sub"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Tap an ingredient to remove it"].exists)
        XCTAssertTrue(app.staticTexts["Add extras"].exists)
        XCTAssertEqual(app.buttons["editor.confirm"].label, "Review changes")
    }

    func testShowcaseExpandedEditorsKeepEveryAddOnControlInsideTheWindow() {
        // The card's plus badge and shadow extend past its accessibility frame.
        // A 24-point frame gutter leaves at least 12 points of real visual air.
        let minimumControlFrameGutter: CGFloat = 24
        let showcaseAddOns = [
            "sub": ["sub.jalapenos", "sub.olives", "sub.mint-mayo"],
            "taco-wrap": ["taco-wrap.cheese", "taco-wrap.jalapenos", "taco-wrap.guacamole"]
        ]

        for productID in ["sub", "taco-wrap"] {
            launchExpandedEditor(productID: productID)

            guard let ingredientIDs = showcaseAddOns[productID] else {
                XCTFail("Missing showcase fixture for \(productID)")
                continue
            }

            let window = app.windows.firstMatch
            XCTAssertTrue(window.waitForExistence(timeout: 8))
            let windowFrame = window.frame

            let controls = ingredientIDs.map { ingredientID in
                let control = app.descendants(matching: .any)["tray.\(ingredientID)"]
                XCTAssertTrue(control.waitForExistence(timeout: 5), "Missing tray.\(ingredientID)")
                return (ingredientID, control)
            }

            // Validate the known screenshot risk first. On the original packed
            // layout, the last card's visual badge/shadow had no safe trailing
            // margin, even though its accessibility frame intersected the window.
            if let (lastIngredientID, lastControl) = controls.last {
                let lastControlFrame = lastControl.frame
                XCTAssertLessThanOrEqual(
                    lastControlFrame.maxX,
                    windowFrame.maxX - minimumControlFrameGutter,
                    "tray.\(lastIngredientID) trailing gutter \(windowFrame.maxX - lastControlFrame.maxX) is below \(minimumControlFrameGutter); control=\(lastControlFrame), window=\(windowFrame)"
                )
            }

            for (ingredientID, control) in controls {
                let controlFrame = control.frame
                XCTAssertGreaterThanOrEqual(
                    controlFrame.minX,
                    windowFrame.minX + minimumControlFrameGutter,
                    "tray.\(ingredientID) leading gutter \(controlFrame.minX - windowFrame.minX) is below \(minimumControlFrameGutter); control=\(controlFrame), window=\(windowFrame)"
                )

                if ingredientID != ingredientIDs.last {
                    XCTAssertLessThanOrEqual(
                        controlFrame.maxX,
                        windowFrame.maxX - minimumControlFrameGutter,
                        "tray.\(ingredientID) trailing gutter \(windowFrame.maxX - controlFrame.maxX) is below \(minimumControlFrameGutter); control=\(controlFrame), window=\(windowFrame)"
                    )
                }
            }
        }
    }

    func testPreviewPreparationUsesCustomerLanguage() {
        app.terminate()
        app.launchArguments = [
            "-DishEditDemoProduct", "burger",
            "-DishEditDemoReassembly"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Preparing your preview"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["ON-DEVICE VISUAL REBUILD"].exists)
        XCTAssertFalse(app.staticTexts["Making the edit visible"].exists)
    }

    func testRemoveIngredientAndConfirm() {
        navigateToEditor(productID: "burger")
        expandEditor()

        let tomatoLayer = app.descendants(matching: .any)["layer.burger.tomato"]
        XCTAssertTrue(tomatoLayer.waitForExistence(timeout: 8))
        tomatoLayer.tap()
        XCTAssertEqual(tomatoLayer.value as? String, "removed")

        let confirmButton = app.buttons["editor.confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        let previewContinueButton = app.buttons["reassembly.confirm"]
        XCTAssertTrue(previewContinueButton.waitForExistence(timeout: 8))
        previewContinueButton.tap()

        let commitButton = app.buttons["commitButton"]
        XCTAssertTrue(commitButton.waitForExistence(timeout: 5))
        let enabledExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == true"),
            object: commitButton
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [enabledExpectation], timeout: 5),
            .completed,
            "The instruction CTA must become enabled before measuring its content inset. button=\(commitButton.frame)"
        )

        let addItemText = app.staticTexts["ADD ITEM"]
        XCTAssertTrue(addItemText.waitForExistence(timeout: 5))

        let buttonFrame = commitButton.frame
        let textFrame = addItemText.frame
        let leadingInset = textFrame.minX - buttonFrame.minX
        XCTAssertGreaterThanOrEqual(
            leadingInset,
            12,
            "ADD ITEM leading inset \(leadingInset)pt must be at least 12pt. button=\(buttonFrame), text=\(textFrame)"
        )
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

        let removed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: cheddarLayer
        )
        XCTAssertEqual(XCTWaiter.wait(for: [removed], timeout: 3), .completed)
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

    private func launchExpandedEditor(productID: String) {
        app.terminate()
        app.launchArguments = [
            "-DishEditFastReconstruction",
            "-DishEditDemoProduct", productID,
            "-DishEditDemoExpanded"
        ]
        app.launch()

        let marker = app.staticTexts["customization.\(productID)"]
        XCTAssertTrue(marker.waitForExistence(timeout: 8))
    }
}
