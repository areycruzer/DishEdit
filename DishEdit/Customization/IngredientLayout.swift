import Foundation

// MARK: - Ingredient Layout

nonisolated struct IngredientTransform: Equatable, Sendable {
    let center: NormalizedPoint
    let scale: Double
    let rotationDegrees: Double
    let zIndex: Double
    let labelOffset: NormalizedPoint
    let opacity: Double

    init(
        center: NormalizedPoint,
        scale: Double = 1.0,
        rotationDegrees: Double = 0,
        zIndex: Double = 0,
        labelOffset: NormalizedPoint = NormalizedPoint(x: 0, y: 0),
        opacity: Double = 1.0
    ) {
        self.center = center
        self.scale = scale
        self.rotationDegrees = rotationDegrees
        self.zIndex = zIndex
        self.labelOffset = labelOffset
        self.opacity = opacity
    }
}

nonisolated enum IngredientLayout {
    /// Collapsed transforms — all layers stacked at center.
    static func collapsed(for product: ProductDefinition) -> [String: IngredientTransform] {
        var transforms: [String: IngredientTransform] = [:]
        for (index, ingredient) in product.ingredients.enumerated() {
            transforms[ingredient.id] = IngredientTransform(
                center: NormalizedPoint(x: 0.5, y: 0.5),
                scale: 1.0,
                rotationDegrees: 0,
                zIndex: Double(index),
                labelOffset: NormalizedPoint(x: 0, y: 0),
                opacity: 1.0
            )
        }
        return transforms
    }

    /// Expanded transforms depend on the product presentation type.
    static func expanded(for product: ProductDefinition) -> [String: IngredientTransform] {
        switch product.presentation {
        case .explodedLayers:
            return burgerExpanded(product: product)
        case .sandwichCounter:
            return subExpanded(product: product)
        case .tacoFan:
            return tacoExpanded(product: product)
        }
    }

    /// Reduce Motion layout — readable vertical list.
    static func reduceMotion(for product: ProductDefinition) -> [String: IngredientTransform] {
        var transforms: [String: IngredientTransform] = [:]
        let count = product.ingredients.count
        let spacing = min(0.09, 0.8 / Double(max(count, 1)))

        for (index, ingredient) in product.ingredients.enumerated() {
            let y = 0.12 + Double(index) * spacing
            transforms[ingredient.id] = IngredientTransform(
                center: NormalizedPoint(x: 0.5, y: y),
                scale: 0.65,
                rotationDegrees: 0,
                zIndex: Double(index),
                labelOffset: NormalizedPoint(x: 0.38, y: 0),
                opacity: 1.0
            )
        }
        return transforms
    }

    /// Approved drop regions for addable ingredients.
    static func dropRegions(for product: ProductDefinition) -> [String: NormalizedRect] {
        var regions: [String: NormalizedRect] = [:]
        for ingredient in product.addableIngredients {
            if let slot = ingredient.placementSlots.first {
                regions[ingredient.id] = slot
            }
        }
        return regions
    }
}

// MARK: - Burger: Vertical Layer Separation

private nonisolated extension IngredientLayout {
    static func burgerExpanded(product: ProductDefinition) -> [String: IngredientTransform] {
        var transforms: [String: IngredientTransform] = [:]
        let recipeOrder = [
            "burger.bun-top",
            "burger.lettuce",
            "burger.onion",
            "burger.tomato",
            "burger.jalapenos",
            "burger.cheddar",
            "burger.patty",
            "burger.sauce",
            "burger.bun-bottom"
        ]
        let layerY: [String: Double] = [
            "burger.bun-top": 0.13,
            "burger.lettuce": 0.24,
            "burger.onion": 0.35,
            "burger.tomato": 0.46,
            "burger.jalapenos": 0.53,
            "burger.cheddar": 0.60,
            "burger.patty": 0.67,
            "burger.sauce": 0.76,
            "burger.bun-bottom": 0.85
        ]

        for (catalogIndex, ingredient) in product.ingredients.enumerated() {
            let layerIndex = recipeOrder.firstIndex(of: ingredient.id) ?? catalogIndex
            let y = layerY[ingredient.id] ?? (0.13 + Double(layerIndex) * 0.09)
            let labelSide: Double = layerIndex.isMultiple(of: 2) ? -0.32 : 0.32
            transforms[ingredient.id] = IngredientTransform(
                center: NormalizedPoint(x: 0.5, y: y),
                scale: 0.92,
                rotationDegrees: 0,
                zIndex: Double(recipeOrder.count - layerIndex),
                labelOffset: NormalizedPoint(x: labelSide, y: 0),
                opacity: 1.0
            )
        }
        return transforms
    }
}

// MARK: - Sub: Horizontal Sandwich Counter Line

private nonisolated extension IngredientLayout {
    static func subExpanded(product: ProductDefinition) -> [String: IngredientTransform] {
        var transforms: [String: IngredientTransform] = [:]
        let fillings = product.ingredients.filter { $0.role != .base }

        // Bread stays at center-bottom, fillings spread horizontally
        for (index, ingredient) in product.ingredients.enumerated() {
            if ingredient.role == .base {
                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: 0.5, y: 0.82),
                    scale: 0.90,
                    rotationDegrees: 0,
                    zIndex: 0,
                    labelOffset: NormalizedPoint(x: 0, y: 0.08),
                    opacity: 1.0
                )
            } else {
                let fillingIndex = fillings.firstIndex(where: { $0.id == ingredient.id }) ?? 0
                let columns = 5
                let column = fillingIndex % columns
                let row = fillingIndex / columns
                let x = 0.12 + Double(column) * 0.19
                let y = 0.25 + Double(row) * 0.28
                let tilt = Double((fillingIndex % 3) - 1) * 3.5
                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: x, y: y),
                    scale: 0.60,
                    rotationDegrees: tilt,
                    zIndex: Double(index),
                    labelOffset: counterLabelOffset(column: column, row: row),
                    opacity: 1.0
                )
            }
        }
        return transforms
    }
}

// MARK: - Taco: Fan Arc Above Tortilla

private nonisolated extension IngredientLayout {
    static func tacoExpanded(product: ProductDefinition) -> [String: IngredientTransform] {
        var transforms: [String: IngredientTransform] = [:]
        let fillings = product.ingredients.filter { $0.role != .base }

        for (index, ingredient) in product.ingredients.enumerated() {
            if ingredient.role == .base {
                // Tortilla stays at center-bottom
                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: 0.5, y: 0.80),
                    scale: 0.88,
                    rotationDegrees: 0,
                    zIndex: 0,
                    labelOffset: NormalizedPoint(x: 0, y: 0.08),
                    opacity: 1.0
                )
            } else {
                let fillingIndex = fillings.firstIndex(where: { $0.id == ingredient.id }) ?? 0
                let columns = 5
                let column = fillingIndex % columns
                let row = fillingIndex / columns
                let x = 0.12 + Double(column) * 0.19
                let y = 0.24 + Double(row) * 0.27
                let rotation = Double(column - 2) * 4.0

                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: x, y: y),
                    scale: 0.50,
                    rotationDegrees: rotation,
                    zIndex: Double(index),
                    labelOffset: counterLabelOffset(column: column, row: row),
                    opacity: 1.0
                )
            }
        }
        return transforms
    }

    /// Five ingredients fit cleanly across the canvas, but their names do not.
    /// Stagger neighbouring callouts above and below the food while keeping the
    /// second row away from the first. Edge labels also lean toward the canvas.
    static func counterLabelOffset(column: Int, row: Int) -> NormalizedPoint {
        let x: Double = switch column {
        case 0: 0.04
        case 4: -0.04
        default: 0
        }
        let y: Double
        if row == 0 {
            y = column.isMultiple(of: 2) ? -0.12 : 0.09
        } else {
            y = column.isMultiple(of: 2) ? -0.10 : 0.12
        }
        return NormalizedPoint(x: x, y: y)
    }
}
