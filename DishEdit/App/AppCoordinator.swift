import Foundation
import Observation

// MARK: - App Route

nonisolated enum AppRoute: Equatable, Sendable {
    case restaurant
    case customize(productID: String)
    case instructions(productID: String)
    case checkout
    case confirmation(orderID: String)
    case settings
    case diagnostics
}

// MARK: - App Coordinator

@MainActor
@Observable
final class AppCoordinator {
    let restaurant: RestaurantDefinition
    let cart: CartStore
    private(set) var route: AppRoute = .restaurant
    private(set) var drafts: [String: CustomizationDraft] = [:]
    private(set) var customerNote: String = ""
    private(set) var allergyAcknowledged: Bool = false
    private(set) var lastOrderID: String?

    init(
        restaurant: RestaurantDefinition = DemoRestaurantCatalog.copperAndCrumb,
        cart: CartStore = CartStore()
    ) {
        self.restaurant = restaurant
        self.cart = cart
    }

    // MARK: - Navigation

    func showRestaurant() {
        route = .restaurant
    }

    func beginVisualCustomization(productID: String) {
        guard let product = restaurant.product(id: productID) else { return }
        if drafts[productID] == nil {
            drafts[productID] = CustomizationDraft(product: product)
        }
        route = .customize(productID: productID)
    }

    func addDefaultProduct(productID: String) {
        guard let product = restaurant.product(id: productID) else { return }
        cart.addDefault(product: product)
    }

    func confirmCustomization(productID: String) {
        route = .instructions(productID: productID)
    }

    func updateCustomerNote(_ note: String) {
        customerNote = note
    }

    func setAllergyAcknowledged(_ acknowledged: Bool) {
        allergyAcknowledged = acknowledged
    }

    func commitToCart(productID: String) {
        guard let product = restaurant.product(id: productID),
              let draft = drafts[productID] else { return }
        cart.addCustomized(
            product: product,
            draft: draft,
            customerNote: customerNote,
            allergyAcknowledged: allergyAcknowledged
        )
        drafts.removeValue(forKey: productID)
        customerNote = ""
        allergyAcknowledged = false
        route = .checkout
    }

    func showCheckout() {
        route = .checkout
    }

    func placeDemoOrder() -> String {
        let orderID = "DEMO-\(Int.random(in: 1000...9999))"
        lastOrderID = orderID
        route = .confirmation(orderID: orderID)
        return orderID
    }

    func showSettings() {
        route = .settings
    }

    func showDiagnostics() {
        route = .diagnostics
    }

    func goBack() {
        switch route {
        case .restaurant:
            break
        case .customize:
            route = .restaurant
        case .instructions:
            if case .instructions(let productID) = route {
                route = .customize(productID: productID)
            }
        case .checkout:
            route = .restaurant
        case .confirmation:
            cart.clear()
            route = .restaurant
        case .settings, .diagnostics:
            route = .restaurant
        }
    }

    func draft(for productID: String) -> CustomizationDraft? {
        drafts[productID]
    }

    func updateDraft(for productID: String, _ mutation: (inout CustomizationDraft) -> Void) {
        guard var draft = drafts[productID] else { return }
        mutation(&draft)
        drafts[productID] = draft
    }

    func hasDirtyDraft(for productID: String) -> Bool {
        drafts[productID]?.hasChanges ?? false
    }

    func discardDraft(for productID: String) {
        drafts.removeValue(forKey: productID)
        customerNote = ""
        allergyAcknowledged = false
    }
}
