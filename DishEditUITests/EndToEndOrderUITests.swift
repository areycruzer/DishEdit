import XCTest

@MainActor
final class EndToEndOrderUITests: XCTestCase {
    private struct Journey {
        let productID: String
        let productName: String
        let removableID: String
        let removalLabel: String
        let addableID: String
        let additionLabel: String
        let customerNote: String?
        let requiresAllergenAcknowledgement: Bool
    }

    private var app: XCUIApplication!

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

    func testBurgerFromRestaurantToPlacedOrder() {
        runJourney(Journey(
            productID: "burger",
            productName: "The Classic Burger",
            removableID: "burger.tomato",
            removalLabel: "No Tomato",
            addableID: "burger.cheddar",
            additionLabel: "Add Cheddar cheese",
            customerNote: "I have a nut allergy and don't like onions.",
            requiresAllergenAcknowledgement: true
        ))
    }

    func testSubFromRestaurantToPlacedOrder() {
        runJourney(Journey(
            productID: "sub",
            productName: "Build Your Own Sub",
            removableID: "sub.onion",
            removalLabel: "No Onion",
            addableID: "sub.jalapenos",
            additionLabel: "Add Jalapeños",
            customerNote: nil,
            requiresAllergenAcknowledgement: false
        ))
    }

    func testTacoWrapFromRestaurantToPlacedOrder() {
        runJourney(Journey(
            productID: "taco-wrap",
            productName: "Taco Wrap",
            removableID: "taco-wrap.onion",
            removalLabel: "No Onion",
            addableID: "taco-wrap.guacamole",
            additionLabel: "Add Guacamole",
            customerNote: nil,
            requiresAllergenAcknowledgement: false
        ))
    }

    private func runJourney(_ journey: Journey) {
        capture("01-menu-\(journey.productID)")

        let editButton = app.buttons["menu.edit-visually.\(journey.productID)"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        makeHittable(editButton)
        editButton.tap()

        XCTAssertTrue(app.staticTexts["customization.\(journey.productID)"].waitForExistence(timeout: 6))
        capture("02-hero-\(journey.productID)")

        let openButton = app.buttons["editor.expand"]
        XCTAssertTrue(openButton.waitForExistence(timeout: 6))
        openButton.tap()

        let removable = app.descendants(matching: .any)["layer.\(journey.removableID)"]
        XCTAssertTrue(removable.waitForExistence(timeout: 6))
        removable.tap()
        XCTAssertEqual(removable.value as? String, "removed")

        let addable = app.descendants(matching: .any)["tray.\(journey.addableID)"]
        XCTAssertTrue(addable.waitForExistence(timeout: 6))
        makeHittable(addable, swipingUp: false)
        addable.tap()

        let addedLayer = app.descendants(matching: .any)["layer.\(journey.addableID)"]
        XCTAssertTrue(addedLayer.waitForExistence(timeout: 6))
        XCTAssertEqual(addedLayer.value as? String, "present")
        capture("03-customized-\(journey.productID)")

        let confirm = app.buttons["editor.confirm"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        let reconstructed = app.buttons["reassembly.confirm"]
        XCTAssertTrue(reconstructed.waitForExistence(timeout: 5))
        XCTAssertTrue(waitUntilEnabled(reconstructed, timeout: 7))
        capture("04-preview-\(journey.productID)")
        reconstructed.tap()

        let commit = app.buttons["commitButton"]
        XCTAssertTrue(commit.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts[journey.removalLabel].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[journey.additionLabel].waitForExistence(timeout: 5))

        if let customerNote = journey.customerNote {
            let note = app.textFields["customerNote"]
            XCTAssertTrue(note.waitForExistence(timeout: 5))
            makeHittable(note)
            note.tap()
            note.typeText(customerNote)
            let keyboardDone = app.buttons["customerNote.done"]
            XCTAssertTrue(keyboardDone.waitForExistence(timeout: 3))
            keyboardDone.tap()
        }

        if journey.requiresAllergenAcknowledgement {
            XCTAssertFalse(commit.isEnabled)
            let banner = app.buttons["allergenBanner"]
            XCTAssertTrue(banner.waitForExistence(timeout: 5))
            makeHittable(banner)
            banner.tap()

            let acknowledge = app.buttons["acknowledgeButton"]
            XCTAssertTrue(acknowledge.waitForExistence(timeout: 5))
            acknowledge.tap()
        }

        XCTAssertTrue(waitUntilEnabled(commit, timeout: 10))
        capture("05-instructions-\(journey.productID)")
        commit.tap()

        XCTAssertTrue(app.buttons["checkout.placeOrder"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts[journey.productName].exists)
        XCTAssertTrue(app.staticTexts[journey.removalLabel].exists)
        XCTAssertTrue(app.staticTexts[journey.additionLabel].exists)
        if let customerNote = journey.customerNote {
            XCTAssertTrue(app.staticTexts["“\(customerNote)”"].exists)
        }
        capture("06-checkout-\(journey.productID)")

        let placeOrder = app.buttons["checkout.placeOrder"]
        XCTAssertTrue(placeOrder.isEnabled)
        placeOrder.tap()

        XCTAssertTrue(app.staticTexts["Your order has been placed"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'DEMO-'")).firstMatch.exists)
        capture("07-confirmation-\(journey.productID)")

        let done = app.buttons["doneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()
        XCTAssertTrue(app.staticTexts["menu.product.burger"].waitForExistence(timeout: 6))
        XCTAssertFalse(app.buttons["menu.cart.banner"].exists)
    }

    private func makeHittable(
        _ element: XCUIElement,
        swipingUp: Bool = true,
        maximumSwipes: Int = 7
    ) {
        var attempts = 0
        while !element.isHittable && attempts < maximumSwipes {
            swipingUp ? app.swipeUp() : app.swipeDown()
            attempts += 1
        }
        XCTAssertTrue(element.isHittable, "Element never became hittable: \(element)")
    }

    private func waitUntilEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "enabled == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
