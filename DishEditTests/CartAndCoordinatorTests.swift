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
        #expect(store.items[0].totalPricePaise == 24_900)
        #expect(store.items[0].instructions == nil)
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
    }

    @Test func addDefaultAddsToCart() {
        let coordinator = AppCoordinator()
        coordinator.addDefaultProduct(productID: "burger")
        #expect(coordinator.cart.itemCount == 1)
        #expect(coordinator.cart.items[0].instructions == nil)
    }

    @Test func addCustomizedAddsInstructions() {
        let coordinator = AppCoordinator()
        coordinator.addCustomizedProduct(productID: "burger", priceDelta: 4000, instructions: "no tomato, add cheese")
        #expect(coordinator.cart.itemCount == 1)
        #expect(coordinator.cart.items[0].instructions == "no tomato, add cheese")
        #expect(coordinator.cart.items[0].totalPricePaise == 24_900 + 4000)
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
}
