import Foundation
import Observation

// MARK: - App Route

nonisolated enum AppRoute: Equatable, Sendable {
    case restaurant
    case customize(productID: String)
    case checkout
    case confirmation(orderID: String)
}

// MARK: - App Coordinator

@MainActor
@Observable
final class AppCoordinator {
    let restaurant: RestaurantDefinition
    let cart: CartStore
    private(set) var route: AppRoute = .restaurant

    init(
        restaurant: RestaurantDefinition = DemoRestaurantCatalog.copperAndCrumb,
        cart: CartStore = CartStore()
    ) {
        self.restaurant = restaurant
        self.cart = cart
    }

    func showRestaurant() {
        route = .restaurant
    }

    func beginVisualCustomization(productID: String) {
        route = .customize(productID: productID)
    }

    func addDefaultProduct(productID: String) {
        guard let product = restaurant.product(id: productID) else { return }
        cart.addDefault(product: product)
    }

    func addCustomizedProduct(productID: String, priceDelta: Int, instructions: String?) {
        guard let product = restaurant.product(id: productID) else { return }
        cart.addCustomized(product: product, priceDelta: priceDelta, instructions: instructions)
    }

    func showCheckout() {
        route = .checkout
    }

    func placeDemoOrder() -> String {
        let orderID = "DEMO-\(Int.random(in: 1000...9999))"
        route = .confirmation(orderID: orderID)
        return orderID
    }

    func goBack() {
        switch route {
        case .restaurant:
            break
        case .customize:
            route = .restaurant
        case .checkout:
            route = .restaurant
        case .confirmation:
            cart.clear()
            route = .restaurant
        }
    }
}
