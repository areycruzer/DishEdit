import XCTest

final class DishEditUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCompleteBurgerLoopAndSummary() throws {
        let app = XCUIApplication()
        app.launch()

        let stage = app.descendants(matching: .any)["dish.stage"]
        XCTAssertTrue(stage.waitForExistence(timeout: 8))

        stage.coordinate(withNormalizedOffset: CGVector(dx: 0.50, dy: 0.55)).tap()
        XCTAssertTrue(app.buttons["No tomato"].waitForExistence(timeout: 2))

        app.buttons["modifier.add"].tap()
        XCTAssertTrue(app.buttons["Cheese"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Open order summary, total ₹289"].exists)

        app.buttons["order.summary"].tap()
        XCTAssertTrue(app.navigationBars["Order truth"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()

        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Burger — tomato removed, cheese added"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testDishSwitchingAndAccessibleAddition() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["dish.select.pizza"].tap()
        XCTAssertTrue(app.staticTexts["Midnight Margherita"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add jalapeños"].exists)
        let pizzaScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        pizzaScreenshot.name = "Pizza stage"
        pizzaScreenshot.lifetime = .keepAlways
        add(pizzaScreenshot)

        app.buttons["dish.select.waffle"].tap()
        XCTAssertTrue(app.staticTexts["After Dark Waffle"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add vanilla ice cream"].exists)
        let waffleScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        waffleScreenshot.name = "Waffle stage"
        waffleScreenshot.lifetime = .keepAlways
        add(waffleScreenshot)
    }

    @MainActor
    func testUndoRedoAndResetKeepVisualAndOrderStateTogether() throws {
        let app = XCUIApplication()
        app.launch()

        let stage = app.descendants(matching: .any)["dish.stage"]
        XCTAssertTrue(stage.waitForExistence(timeout: 8))
        stage.coordinate(withNormalizedOffset: CGVector(dx: 0.50, dy: 0.55)).tap()
        XCTAssertTrue(app.buttons["No tomato"].waitForExistence(timeout: 2))

        app.buttons["Undo"].tap()
        XCTAssertFalse(app.buttons["No tomato"].exists)
        XCTAssertTrue(app.buttons["Open order summary, total ₹249"].exists)

        app.buttons["Redo"].tap()
        XCTAssertTrue(app.buttons["No tomato"].waitForExistence(timeout: 2))

        app.buttons["Reset dish"].tap()
        XCTAssertFalse(app.buttons["No tomato"].exists)
        XCTAssertTrue(app.buttons["Open order summary, total ₹249"].exists)
    }

    @MainActor
    func testMagneticCheeseDragCommitsOnlyInsideApprovedFoodZone() throws {
        let app = XCUIApplication()
        app.launch()

        let stage = app.descendants(matching: .any)["dish.stage"]
        let cheese = app.descendants(matching: .any)["modifier.drag.asset"]
        XCTAssertTrue(stage.waitForExistence(timeout: 8))
        XCTAssertTrue(cheese.waitForExistence(timeout: 2))

        cheese.press(
            forDuration: 0.80,
            thenDragTo: stage,
            withVelocity: .slow,
            thenHoldForDuration: 0.20
        )

        XCTAssertTrue(app.buttons["Cheese"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Open order summary, total ₹289"].exists)
    }

    @MainActor
    func testReconstructionAppearsBeforePhotographCommits() throws {
        let app = XCUIApplication()
        app.launch()

        let stage = app.descendants(matching: .any)["dish.stage"]
        XCTAssertTrue(stage.waitForExistence(timeout: 8))
        stage.coordinate(withNormalizedOffset: CGVector(dx: 0.50, dy: 0.55)).tap()

        XCTAssertTrue(app.staticTexts["ON-DEVICE PREVIEW"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["No tomato"].exists)
        XCTAssertTrue(app.staticTexts["Visual preview ready"].waitForExistence(timeout: 7))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
