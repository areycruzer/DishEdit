import Testing
@testable import DishEdit

@MainActor
struct CartStoreTests {
    @Test func addDefaultCreatesOneItem() {
        let store = CartStore()
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        store.addDefault(product: burger)
        #expect(store.itemCount == 1)
        #expect(store.items[0].productID == "burger")
        #expect(store.items[0].modifiers.isEmpty)
        #expect(store.items[0].totalPricePaise == 24_900)
    }

    @Test func addCustomizedCarriesModifiers() {
        let store = CartStore()
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        var draft = CustomizationDraft(product: burger)
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.add(ingredientID: "burger.cheddar")
        store.addCustomized(product: burger, draft: draft, customerNote: "Nut allergy", allergyAcknowledged: true)
        #expect(store.items[0].priceDeltaPaise == 4_000)
        #expect(store.items[0].totalPricePaise == 28_900)
        #expect(store.items[0].customerNote == "Nut allergy")
        #expect(store.items[0].allergyAcknowledged == true)
        #expect(store.items[0].modifiers.count == 2)
    }

    @Test func totalsIncludeConceptFees() {
        let store = CartStore()
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        store.addDefault(product: burger)
        let totals = store.totals
        #expect(totals.itemTotal == 24_900)
        #expect(totals.deliveryFee == 4_900)
        #expect(totals.platformFee == 600)
        #expect(totals.grandTotal > totals.itemTotal)
    }

    @Test func clearRemovesAllItems() {
        let store = CartStore()
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        store.addDefault(product: burger)
        store.clear()
        #expect(store.isEmpty)
    }
}

@MainActor
struct AppCoordinatorTests {
    @Test func defaultRouteIsRestaurant() {
        let coordinator = AppCoordinator()
        #expect(coordinator.route == .restaurant)
    }

    @Test func beginVisualCustomizationCreatesRoute() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        #expect(coordinator.route == .customize(productID: "burger"))
        #expect(coordinator.draft(for: "burger") != nil)
    }

    @Test func addDefaultAddsToCart() {
        let coordinator = AppCoordinator()
        coordinator.addDefaultProduct(productID: "burger")
        #expect(coordinator.cart.itemCount == 1)
    }

    @Test func confirmNavigatesToInstructions() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.confirmCustomization(productID: "burger")
        #expect(coordinator.route == .instructions(productID: "burger"))
    }

    @Test func commitToCartNavigatesToCheckout() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.commitToCart(productID: "burger")
        #expect(coordinator.route == .checkout)
        #expect(coordinator.cart.itemCount == 1)
        #expect(coordinator.draft(for: "burger") == nil)
    }

    @Test func placeDemoOrderCreatesConfirmation() {
        let coordinator = AppCoordinator()
        coordinator.addDefaultProduct(productID: "burger")
        let orderID = coordinator.placeDemoOrder()
        #expect(coordinator.route == .confirmation(orderID: orderID))
        #expect(orderID.hasPrefix("DEMO-"))
    }

    @Test func goBackFromCustomizationToRestaurant() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.goBack()
        #expect(coordinator.route == .restaurant)
    }

    @Test func goBackFromInstructionsToCustomization() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.confirmCustomization(productID: "burger")
        coordinator.goBack()
        #expect(coordinator.route == .customize(productID: "burger"))
    }

    @Test func unknownProductIDDoesNothing() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "pizza")
        #expect(coordinator.route == .restaurant)
    }

    @Test func draftMutationPersists() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.updateDraft(for: "burger") { draft in
            _ = draft.remove(ingredientID: "burger.tomato")
        }
        let draft = coordinator.draft(for: "burger")!
        #expect(!draft.presentIngredientIDs.contains("burger.tomato"))
        #expect(coordinator.hasDirtyDraft(for: "burger"))
    }

    @Test func discardDraftClearsState() {
        let coordinator = AppCoordinator()
        coordinator.beginVisualCustomization(productID: "burger")
        coordinator.updateDraft(for: "burger") { _ = $0.remove(ingredientID: "burger.tomato") }
        coordinator.discardDraft(for: "burger")
        #expect(coordinator.draft(for: "burger") == nil)
    }
}
