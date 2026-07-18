import Foundation

// MARK: - Cart Models

nonisolated struct CartItem: Identifiable, Equatable, Sendable {
    let id: String
    let productID: String
    let productName: String
    let basePricePaise: Int
    let modifiers: [ModifierSummaryItem]
    let customerNote: String
    let allergyAcknowledged: Bool
    let priceDeltaPaise: Int

    var totalPricePaise: Int {
        basePricePaise + priceDeltaPaise
    }
}

nonisolated struct CartTotals: Equatable, Sendable {
    let itemTotal: Int
    let deliveryFee: Int
    let platformFee: Int
    let taxes: Int
    let grandTotal: Int
}

nonisolated enum ConceptFees {
    static let deliveryFee = 4_900
    static let platformFee = 600
    static let taxRate = 0.05
}
