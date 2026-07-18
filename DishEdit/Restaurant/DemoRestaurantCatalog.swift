import Foundation

// MARK: - Copper & Crumb Demo Catalog

enum DemoRestaurantCatalog {
    nonisolated static let copperAndCrumb = RestaurantDefinition(
        id: "copper-and-crumb",
        name: "Copper & Crumb",
        cuisine: "Burgers · Subs · Wraps",
        rating: 4.3,
        deliveryEstimate: "25–35 min",
        products: [burger, sub, tacoWrap]
    )
}

// MARK: - The Classic Burger

private extension DemoRestaurantCatalog {
    nonisolated static let burger = ProductDefinition(
        id: "burger",
        name: "The Classic Burger",
        subtitle: "Charred beef · brioche · house sauce",
        description: "Our signature charcoal-grilled patty on a toasted brioche bun with house sauce, fresh tomato, red onion, and crisp lettuce.",
        basePricePaise: 24_900,
        dietaryMarker: "Non-veg",
        rating: 4.5,
        assembledAssetName: "burger_base",
        presentation: .explodedLayers,
        ingredients: [
            IngredientDefinition(
                id: "burger.bun-bottom",
                name: "Bottom brioche bun",
                role: .base,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_bun_bottom",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Bottom brioche bun"
            ),
            IngredientDefinition(
                id: "burger.sauce",
                name: "House sauce",
                role: .sauce,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_sauce",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "House sauce"
            ),
            IngredientDefinition(
                id: "burger.patty",
                name: "Beef patty",
                role: .protein,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_patty",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Charcoal-grilled beef patty"
            ),
            IngredientDefinition(
                id: "burger.tomato",
                name: "Tomato",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_tomato",
                authorMaskAssetName: "burger_tomato_mask",
                placementSlots: [],
                accessibilityDescription: "Fresh tomato slices"
            ),
            IngredientDefinition(
                id: "burger.onion",
                name: "Red onion",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_onion",
                authorMaskAssetName: "burger_onion_mask",
                placementSlots: [],
                accessibilityDescription: "Red onion rings"
            ),
            IngredientDefinition(
                id: "burger.lettuce",
                name: "Lettuce",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_lettuce",
                authorMaskAssetName: "burger_lettuce_mask",
                placementSlots: [],
                accessibilityDescription: "Crisp lettuce leaf"
            ),
            IngredientDefinition(
                id: "burger.bun-top",
                name: "Top brioche bun",
                role: .base,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "burger_layer_bun_top",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Top brioche bun"
            ),
            IngredientDefinition(
                id: "burger.cheddar",
                name: "Cheddar cheese",
                role: .cheese,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 4_000,
                layerAssetName: "burger_layer_cheddar",
                authorMaskAssetName: "burger_cheese_mask",
                placementSlots: [NormalizedRect(x: 0.18, y: 0.47, width: 0.64, height: 0.28)],
                accessibilityDescription: "Cheddar cheese slice, adds ₹40"
            ),
            IngredientDefinition(
                id: "burger.jalapenos",
                name: "Jalapeños",
                role: .topping,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 3_000,
                layerAssetName: "burger_layer_jalapenos",
                authorMaskAssetName: "burger_jalapenos_mask",
                placementSlots: [NormalizedRect(x: 0.20, y: 0.35, width: 0.60, height: 0.25)],
                accessibilityDescription: "Sliced jalapeños, adds ₹30"
            )
        ]
    )
}

// MARK: - Build Your Own Sub

private extension DemoRestaurantCatalog {
    nonisolated static let sub = ProductDefinition(
        id: "sub",
        name: "Build Your Own Sub",
        subtitle: "Grilled paneer · chipotle · toasted bread",
        description: "Build it your way. Toasted sub bread with grilled paneer, cheddar, fresh vegetables, and chipotle sauce.",
        basePricePaise: 22_900,
        dietaryMarker: "Veg",
        rating: 4.2,
        assembledAssetName: "sub_base",
        presentation: .sandwichCounter,
        ingredients: [
            IngredientDefinition(
                id: "sub.bread",
                name: "Toasted sub bread",
                role: .base,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_bread",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Toasted sub bread"
            ),
            IngredientDefinition(
                id: "sub.paneer",
                name: "Grilled paneer",
                role: .protein,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_paneer",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Grilled paneer slices"
            ),
            IngredientDefinition(
                id: "sub.cheddar",
                name: "Cheddar",
                role: .cheese,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_cheddar",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Cheddar cheese"
            ),
            IngredientDefinition(
                id: "sub.lettuce",
                name: "Lettuce",
                role: .vegetable,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_lettuce",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Fresh lettuce"
            ),
            IngredientDefinition(
                id: "sub.tomato",
                name: "Tomato",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_tomato",
                authorMaskAssetName: "sub_tomato_mask",
                placementSlots: [],
                accessibilityDescription: "Fresh tomato slices"
            ),
            IngredientDefinition(
                id: "sub.onion",
                name: "Onion",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_onion",
                authorMaskAssetName: "sub_onion_mask",
                placementSlots: [],
                accessibilityDescription: "Sliced onion"
            ),
            IngredientDefinition(
                id: "sub.cucumber",
                name: "Cucumber",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_cucumber",
                authorMaskAssetName: "sub_cucumber_mask",
                placementSlots: [],
                accessibilityDescription: "Fresh cucumber slices"
            ),
            IngredientDefinition(
                id: "sub.chipotle",
                name: "Chipotle sauce",
                role: .sauce,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "sub_layer_chipotle",
                authorMaskAssetName: "sub_chipotle_mask",
                placementSlots: [],
                accessibilityDescription: "Chipotle sauce"
            ),
            IngredientDefinition(
                id: "sub.jalapenos",
                name: "Jalapeños",
                role: .topping,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 3_000,
                layerAssetName: "sub_layer_jalapenos",
                authorMaskAssetName: "sub_jalapenos_mask",
                placementSlots: [NormalizedRect(x: 0.15, y: 0.30, width: 0.70, height: 0.20)],
                accessibilityDescription: "Sliced jalapeños, adds ₹30"
            ),
            IngredientDefinition(
                id: "sub.olives",
                name: "Olives",
                role: .topping,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 3_500,
                layerAssetName: "sub_layer_olives",
                authorMaskAssetName: "sub_olives_mask",
                placementSlots: [NormalizedRect(x: 0.15, y: 0.35, width: 0.70, height: 0.20)],
                accessibilityDescription: "Black olives, adds ₹35"
            ),
            IngredientDefinition(
                id: "sub.mint-mayo",
                name: "Mint mayonnaise",
                role: .sauce,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 2_000,
                layerAssetName: "sub_layer_mint_mayo",
                authorMaskAssetName: "sub_mint_mayo_mask",
                placementSlots: [NormalizedRect(x: 0.10, y: 0.40, width: 0.80, height: 0.15)],
                accessibilityDescription: "Mint mayonnaise, adds ₹20"
            )
        ]
    )
}

// MARK: - Taco Wrap

private extension DemoRestaurantCatalog {
    nonisolated static let tacoWrap = ProductDefinition(
        id: "taco-wrap",
        name: "Taco Wrap",
        subtitle: "Spiced beans · grilled veg · chipotle crema",
        description: "A soft tortilla filled with spiced beans, grilled vegetables, tomato salsa, and finished with chipotle crema.",
        basePricePaise: 19_900,
        dietaryMarker: "Veg",
        rating: 4.4,
        assembledAssetName: "taco_base",
        presentation: .tacoFan,
        ingredients: [
            IngredientDefinition(
                id: "taco-wrap.tortilla",
                name: "Soft tortilla",
                role: .base,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_tortilla",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Soft flour tortilla"
            ),
            IngredientDefinition(
                id: "taco-wrap.beans",
                name: "Spiced beans",
                role: .protein,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_beans",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Spiced black beans"
            ),
            IngredientDefinition(
                id: "taco-wrap.grilled-veg",
                name: "Grilled vegetables",
                role: .vegetable,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_grilled_veg",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Grilled mixed vegetables"
            ),
            IngredientDefinition(
                id: "taco-wrap.salsa",
                name: "Tomato salsa",
                role: .sauce,
                defaultPresence: true,
                canRemove: false,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_salsa",
                authorMaskAssetName: nil,
                placementSlots: [],
                accessibilityDescription: "Fresh tomato salsa"
            ),
            IngredientDefinition(
                id: "taco-wrap.onion",
                name: "Onion",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_onion",
                authorMaskAssetName: "taco_onion_mask",
                placementSlots: [],
                accessibilityDescription: "Diced onion"
            ),
            IngredientDefinition(
                id: "taco-wrap.lettuce",
                name: "Lettuce",
                role: .vegetable,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_lettuce",
                authorMaskAssetName: "taco_lettuce_mask",
                placementSlots: [],
                accessibilityDescription: "Shredded lettuce"
            ),
            IngredientDefinition(
                id: "taco-wrap.crema",
                name: "Chipotle crema",
                role: .sauce,
                defaultPresence: true,
                canRemove: true,
                canAdd: false,
                priceDeltaPaise: 0,
                layerAssetName: "taco_layer_crema",
                authorMaskAssetName: "taco_crema_mask",
                placementSlots: [],
                accessibilityDescription: "Chipotle crema drizzle"
            ),
            IngredientDefinition(
                id: "taco-wrap.cheese",
                name: "Cheese",
                role: .cheese,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 4_000,
                layerAssetName: "taco_layer_cheese",
                authorMaskAssetName: "taco_cheese_mask",
                placementSlots: [NormalizedRect(x: 0.20, y: 0.30, width: 0.60, height: 0.25)],
                accessibilityDescription: "Shredded cheese, adds ₹40"
            ),
            IngredientDefinition(
                id: "taco-wrap.jalapenos",
                name: "Jalapeños",
                role: .topping,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 3_000,
                layerAssetName: "taco_layer_jalapenos",
                authorMaskAssetName: "taco_jalapenos_mask",
                placementSlots: [NormalizedRect(x: 0.22, y: 0.28, width: 0.56, height: 0.22)],
                accessibilityDescription: "Sliced jalapeños, adds ₹30"
            ),
            IngredientDefinition(
                id: "taco-wrap.guacamole",
                name: "Guacamole",
                role: .topping,
                defaultPresence: false,
                canRemove: false,
                canAdd: true,
                priceDeltaPaise: 6_000,
                layerAssetName: "taco_layer_guacamole",
                authorMaskAssetName: "taco_guacamole_mask",
                placementSlots: [NormalizedRect(x: 0.18, y: 0.32, width: 0.64, height: 0.20)],
                accessibilityDescription: "Fresh guacamole, adds ₹60"
            )
        ]
    )
}
