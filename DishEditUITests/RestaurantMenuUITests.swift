import XCTest

final class RestaurantMenuUITests: XCTestCase {
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

    func testMenuShowsThreeProducts() {
        let burgerCard = app.scrollViews.staticTexts["menu.product.burger"]
        XCTAssertTrue(burgerCard.waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews.staticTexts["menu.product.sub"].exists)
        XCTAssertTrue(app.scrollViews.staticTexts["menu.product.taco-wrap"].exists)
    }

    func testMenuUsesCustomerFacingZomatoCommerceLanguage() {
        XCTAssertTrue(app.staticTexts["Recommended for you"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["VISUAL MENU · iOS 27"].exists)
        XCTAssertFalse(app.staticTexts["Don’t describe it. Touch it."].exists)
    }

    func testAddBurgerIncreasesCartCount() {
        let addButton = app.scrollViews.buttons["menu.add.burger"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 8))
        addButton.tap()
        let cartBanner = app.buttons["menu.cart.banner"]
        XCTAssertTrue(cartBanner.waitForExistence(timeout: 3))
    }

    func testEditVisuallyNavigatesToCustomization() {
        let editButton = app.scrollViews.buttons["menu.edit-visually.burger"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()
        let marker = app.staticTexts["customization.burger"]
        XCTAssertTrue(marker.waitForExistence(timeout: 5))
    }

    func testSettingsButtonNavigates() {
        let settingsButton = app.buttons["Open preview settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 8))
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Generation"].waitForExistence(timeout: 5))
    }

    func testStageSafeSettingPersistsAfterClosingAndReopening() {
        let settingsButton = app.buttons["Open preview settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 8))
        settingsButton.tap()

        let stageSafeToggle = app.switches["Stage Safe Mode"]
        XCTAssertTrue(stageSafeToggle.waitForExistence(timeout: 5))
        if (stageSafeToggle.value as? String) != "1" {
            stageSafeToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        }
        XCTAssertTrue(waitForSwitch(stageSafeToggle, value: "1"))
        app.navigationBars.buttons["Done"].tap()

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        XCTAssertTrue(stageSafeToggle.waitForExistence(timeout: 5))
        XCTAssertTrue(waitForSwitch(stageSafeToggle, value: "1"))
    }

    private func waitForSwitch(_ element: XCUIElement, value: String) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: 3) == .completed
    }
}
