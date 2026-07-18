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

enum IngredientPresentation: String, Codable, Sendable {
    case explodedLayers
    case sandwichCounter
    case tacoFan
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
    let presentation: IngredientPresentation
    let ingredients: [IngredientDefinition]

    func ingredient(id: String) -> IngredientDefinition? {
        ingredients.first { $0.id == id }
    }

    var defaultIngredientIDs: Set<String> {
        Set(ingredients.filter(\.defaultPresence).map(\.id))
    }

    var removableIngredients: [IngredientDefinition] {
        ingredients.filter(\.canRemove)
    }

    var addableIngredients: [IngredientDefinition] {
        ingredients.filter(\.canAdd)
    }
}

nonisolated struct IngredientDefinition: Identifiable, Codable, Equatable, Sendable {
    enum Role: String, Codable, Sendable {
        case base
        case protein
        case cheese
        case vegetable
        case sauce
        case topping
    }

    let id: String
    let name: String
    let role: Role
    let defaultPresence: Bool
    let canRemove: Bool
    let canAdd: Bool
    let priceDeltaPaise: Int
    let layerAssetName: String
    let authorMaskAssetName: String?
    let placementSlots: [NormalizedRect]
    let accessibilityDescription: String
}
