import XCTest

final class RestaurantMenuUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-DishEditFastReconstruction"]
        app.launch()
    }

    func testMenuShowsThreeProducts() {
        let burgerCard = app.scrollViews.otherElements["menu.product.burger"]
        XCTAssertTrue(burgerCard.waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews.otherElements["menu.product.sub"].exists)
        XCTAssertTrue(app.scrollViews.otherElements["menu.product.taco-wrap"].exists)
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
}
