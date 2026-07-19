import XCTest

@MainActor
final class CustomizationCoverageUITests: XCTestCase {
    private struct ProductControls {
        let productID: String
        let fixed: [String]
        let removable: [String]
        let addable: [String]
    }

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app?.terminate()
        app = nil
        super.tearDown()
    }

    func testEveryBurgerIngredientControl() {
        exercise(ProductControls(
            productID: "burger",
            fixed: ["burger.bun-bottom", "burger.sauce", "burger.patty", "burger.bun-top"],
            removable: ["burger.tomato", "burger.onion", "burger.lettuce"],
            addable: ["burger.cheddar", "burger.jalapenos"]
        ))
    }

    func testEverySubIngredientControl() {
        exercise(ProductControls(
            productID: "sub",
            fixed: ["sub.bread", "sub.paneer", "sub.cheddar", "sub.lettuce"],
            removable: ["sub.tomato", "sub.onion", "sub.cucumber", "sub.chipotle"],
            addable: ["sub.jalapenos", "sub.olives", "sub.mint-mayo"]
        ))
    }

    func testEveryTacoWrapIngredientControl() {
        exercise(ProductControls(
            productID: "taco-wrap",
            fixed: ["taco-wrap.tortilla", "taco-wrap.beans", "taco-wrap.grilled-veg", "taco-wrap.salsa"],
            removable: ["taco-wrap.onion", "taco-wrap.lettuce", "taco-wrap.crema"],
            addable: ["taco-wrap.cheese", "taco-wrap.jalapenos", "taco-wrap.guacamole"]
        ))
    }

    private func exercise(_ controls: ProductControls) {
        app.launchArguments = [
            "-DishEditFastReconstruction",
            "-DishEditDemoProduct", controls.productID,
            "-DishEditDemoExpanded"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["customization.\(controls.productID)"].waitForExistence(timeout: 8))

        for ingredientID in controls.fixed {
            let layer = app.descendants(matching: .any)["layer.\(ingredientID)"]
            XCTAssertTrue(layer.waitForExistence(timeout: 5), "Missing fixed layer \(ingredientID)")
            layer.tap()
            XCTAssertEqual(layer.value as? String, "present", "Fixed layer changed: \(ingredientID)")
        }

        for ingredientID in controls.removable {
            let layer = app.descendants(matching: .any)["layer.\(ingredientID)"]
            XCTAssertTrue(layer.waitForExistence(timeout: 5), "Missing removable layer \(ingredientID)")
            layer.tap()
            XCTAssertEqual(layer.value as? String, "removed", "Layer did not remove: \(ingredientID)")
            layer.tap()
            XCTAssertEqual(layer.value as? String, "present", "Layer did not restore: \(ingredientID)")
        }

        for ingredientID in controls.addable {
            let tray = app.descendants(matching: .any)["tray.\(ingredientID)"]
            XCTAssertTrue(tray.waitForExistence(timeout: 5), "Missing tray control \(ingredientID)")
            tray.tap()

            let layer = app.descendants(matching: .any)["layer.\(ingredientID)"]
            XCTAssertTrue(layer.waitForExistence(timeout: 5), "Added layer did not appear: \(ingredientID)")
            XCTAssertEqual(layer.value as? String, "present")

            tray.tap()
            XCTAssertFalse(layer.waitForExistence(timeout: 2), "Added layer did not return to default: \(ingredientID)")
        }
    }
}
