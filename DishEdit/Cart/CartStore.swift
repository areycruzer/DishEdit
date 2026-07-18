import Foundation
import Observation

// MARK: - Cart Store

@MainActor
@Observable
final class CartStore {
    private(set) var items: [CartItem] = []

    var itemCount: Int { items.count }
    var isEmpty: Bool { items.isEmpty }

    var itemTotal: Int {
        items.reduce(0) { $0 + $1.totalPricePaise }
    }

    var totals: CartTotals {
        let itemTotal = self.itemTotal
        let taxes = Int(Double(itemTotal) * ConceptFees.taxRate)
        return CartTotals(
            itemTotal: itemTotal,
            deliveryFee: ConceptFees.deliveryFee,
            platformFee: ConceptFees.platformFee,
            taxes: taxes,
            grandTotal: itemTotal + ConceptFees.deliveryFee + ConceptFees.platformFee + taxes
        )
    }

    func addDefault(product: ProductDefinition) {
        let item = CartItem(
            id: UUID().uuidString,
            productID: product.id,
            productName: product.name,
            basePricePaise: product.basePricePaise,
            modifiers: [],
            customerNote: "",
            allergyAcknowledged: false,
            priceDeltaPaise: 0
        )
        items.append(item)
    }

    func addCustomized(
        product: ProductDefinition,
        draft: CustomizationDraft,
        customerNote: String,
        allergyAcknowledged: Bool
    ) {
        let item = CartItem(
            id: UUID().uuidString,
            productID: product.id,
            productName: product.name,
            basePricePaise: product.basePricePaise,
            modifiers: draft.modifierSummary,
            customerNote: customerNote,
            allergyAcknowledged: allergyAcknowledged,
            priceDeltaPaise: draft.priceDeltaPaise
        )
        items.append(item)
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
    }

    func clear() {
        items.removeAll()
    }
}
