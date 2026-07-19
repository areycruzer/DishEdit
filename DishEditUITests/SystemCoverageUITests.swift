import XCTest

@MainActor
final class SystemCoverageUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-DishEditFastReconstruction"]
        if name.contains("testUndoRedoResetAndFixedLayerBehavior") {
            app.launchArguments += [
                "-DishEditDemoProduct", "burger",
                "-DishEditDemoExpanded"
            ]
        }
        app.launch()
    }

    override func tearDown() {
        app?.terminate()
        app = nil
        super.tearDown()
    }

    func testQuickAddEveryProductThenRemoveEveryCartItem() {
        for productID in ["burger", "sub", "taco-wrap"] {
            let add = app.buttons["menu.add.\(productID)"]
            XCTAssertTrue(add.waitForExistence(timeout: 8))
            scrollToHittable(add)
            add.tap()
        }

        let cart = app.buttons["menu.cart.banner"]
        XCTAssertTrue(cart.waitForExistence(timeout: 5))
        cart.tap()

        XCTAssertTrue(app.staticTexts["3 ITEM"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["The Classic Burger"].exists)
        XCTAssertTrue(app.staticTexts["Build Your Own Sub"].exists)
        XCTAssertTrue(app.staticTexts["Taco Wrap"].exists)
        XCTAssertTrue(app.buttons["checkout.placeOrder"].isEnabled)

        let addAnother = app.buttons["Add another dish"]
        XCTAssertTrue(addAnother.waitForExistence(timeout: 5))
        scrollToHittable(addAnother)
        addAnother.tap()
        XCTAssertTrue(app.buttons["menu.cart.banner"].waitForExistence(timeout: 5))
        app.buttons["menu.cart.banner"].tap()

        for productName in ["The Classic Burger", "Build Your Own Sub", "Taco Wrap"] {
            let remove = app.buttons["Remove \(productName)"]
            XCTAssertTrue(remove.waitForExistence(timeout: 5))
            scrollToHittable(remove)
            remove.tap()
        }

        XCTAssertTrue(app.staticTexts["0 ITEM"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["checkout.placeOrder"].isEnabled)
    }

    func testDiagnosticsFailureInjectionReliabilityAndDone() {
        let diagnostics = app.buttons["Open diagnostics"]
        XCTAssertTrue(diagnostics.waitForExistence(timeout: 8))
        diagnostics.tap()
        XCTAssertTrue(app.navigationBars["Diagnostics"].waitForExistence(timeout: 5))

        let failureModes = ["Core AI", "Remote", "Image Playground"]
        for mode in failureModes {
            let toggle = app.switches["diagnostics.forceFailure.\(mode)"]
            XCTAssertTrue(toggle.waitForExistence(timeout: 5))
            scrollToHittable(toggle)
            let didTurnOn = turnOn(toggle)
            if !didTurnOn {
                print("FAILED SWITCH SNAPSHOT \(mode): \(toggle.debugDescription)")
                let attachment = XCTAttachment(screenshot: app.screenshot())
                attachment.name = "diagnostics-switch-failure-\(mode)"
                attachment.lifetime = .keepAlways
                add(attachment)
            }
            XCTAssertTrue(didTurnOn, "\(mode) failure switch did not turn on")
        }

        let reliability = app.buttons["diagnostics.runReliability"]
        XCTAssertTrue(reliability.waitForExistence(timeout: 5))
        scrollToHittable(reliability)
        reliability.tap()
        XCTAssertTrue(app.staticTexts["20/20 passed"].waitForExistence(timeout: 8))

        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["menu.product.burger"].waitForExistence(timeout: 6))
    }

    func testUndoRedoResetAndFixedLayerBehavior() {
        waitForExpandedEditor(productID: "burger")

        let fixedBun = app.descendants(matching: .any)["layer.burger.bun-top"]
        XCTAssertTrue(fixedBun.waitForExistence(timeout: 5))
        fixedBun.tap()
        XCTAssertEqual(fixedBun.value as? String, "present")

        let tomato = app.descendants(matching: .any)["layer.burger.tomato"]
        tomato.tap()
        XCTAssertEqual(tomato.value as? String, "removed")

        let undo = app.buttons["editor.undo"]
        XCTAssertTrue(undo.isEnabled)
        undo.tap()
        XCTAssertEqual(tomato.value as? String, "present")

        let redo = app.buttons["editor.redo"]
        XCTAssertTrue(redo.isEnabled)
        redo.tap()
        XCTAssertEqual(tomato.value as? String, "removed")

        let reset = app.buttons["editor.reset"]
        XCTAssertTrue(reset.isEnabled)
        reset.tap()
        XCTAssertEqual(tomato.value as? String, "present")
        XCTAssertFalse(reset.isEnabled)
    }

    private func waitForExpandedEditor(productID: String) {
        XCTAssertTrue(app.staticTexts["customization.\(productID)"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["layer.\(productID).\(productID == "taco-wrap" ? "onion" : "tomato")"].waitForExistence(timeout: 6))
    }

    private func scrollToHittable(_ element: XCUIElement, maximumSwipes: Int = 8) {
        var attempts = 0
        while (!element.isHittable || element.frame.maxY > app.frame.maxY - 88) && attempts < maximumSwipes {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(
            element.isHittable && element.frame.maxY <= app.frame.maxY - 88,
            "Element never became fully visible: \(element)"
        )
    }


    private func waitForValue(_ value: String, on element: XCUIElement, timeout: TimeInterval = 3) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func turnOn(_ toggle: XCUIElement) -> Bool {
        if toggle.value as? String == "1" { return true }

        // SwiftUI exposes the complete List row as the identified switch. Its
        // actual thumb occupies roughly x=0.79...0.96; 0.88 reliably lands in
        // the native control instead of just beyond its trailing edge.
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5)).tap()
        if waitForValue("1", on: toggle, timeout: 4) { return true }

        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.84, dy: 0.5)).tap()
        return waitForValue("1", on: toggle, timeout: 4)
    }
}
