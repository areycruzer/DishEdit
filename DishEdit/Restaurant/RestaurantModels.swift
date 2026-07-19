import Foundation

// MARK: - Restaurant Catalog Types

nonisolated struct RestaurantDefinition: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let cuisine: String
    let rating: Double
    let deliveryEstimate: String
    let products: [ProductDefinition]

    func product(id: String) -> ProductDefinition? {
        products.first { $0.id == id }
    }
}

nonisolated struct ProductDefinition: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let basePricePaise: Int
    let dietaryMarker: String
    let rating: Double
    let assembledAssetName: String
}
