import Foundation

// MARK: - Copper & Crumb Demo Catalog

enum DemoRestaurantCatalog {
    nonisolated static let copperAndCrumb = RestaurantDefinition(
        id: "copper-and-crumb",
        name: "Termin8ors's Restaurant",
        cuisine: "Burgers · Pizza · Waffles",
        rating: 4.3,
        deliveryEstimate: "25–35 min",
        products: [burger, pizza, waffle]
    )
}

// MARK: - The Classic Burger

private extension DemoRestaurantCatalog {
    nonisolated static let burger = ProductDefinition(
        id: "burger",
        name: "The Classic",
        subtitle: "Charred beef · brioche · house sauce",
        description: "Our signature charcoal-grilled patty on a toasted brioche bun with house sauce, fresh tomato, and crisp lettuce.",
        basePricePaise: 24_900,
        dietaryMarker: "Non-veg",
        rating: 4.5,
        assembledAssetName: "burger_base"
    )
}

// MARK: - Margherita Pizza

private extension DemoRestaurantCatalog {
    nonisolated static let pizza = ProductDefinition(
        id: "pizza",
        name: "Margherita Pizza",
        subtitle: "Fresh mozzarella · basil · tomato sauce",
        description: "Classic Neapolitan-style pizza with San Marzano tomatoes, fresh mozzarella, and hand-torn basil.",
        basePricePaise: 29_900,
        dietaryMarker: "Veg",
        rating: 4.4,
        assembledAssetName: "pizza_base"
    )
}

// MARK: - Belgian Waffle

private extension DemoRestaurantCatalog {
    nonisolated static let waffle = ProductDefinition(
        id: "waffle",
        name: "Belgian Waffle",
        subtitle: "Belgian waffle · berries · maple",
        description: "Golden Belgian waffle topped with fresh strawberries, whipped cream, and real maple syrup.",
        basePricePaise: 29_900,
        dietaryMarker: "Veg",
        rating: 4.6,
        assembledAssetName: "waffle_base"
    )
}
