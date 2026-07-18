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
        let count = product.ingredients.count
        let totalSpan = 0.72
        let spacing = totalSpan / Double(max(count - 1, 1))
        let startY = 0.14

        for (index, ingredient) in product.ingredients.enumerated() {
            let y = startY + Double(index) * spacing
            let labelSide: Double = index.isMultiple(of: 2) ? -0.32 : 0.32
            transforms[ingredient.id] = IngredientTransform(
                center: NormalizedPoint(x: 0.5, y: y),
                scale: 0.82,
                rotationDegrees: 0,
                zIndex: Double(count - index),
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
        let count = product.ingredients.count

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
                let fillingIndex = index - 1
                let fillingCount = count - 1
                let spacing = 0.72 / Double(max(fillingCount - 1, 1))
                let x = 0.14 + Double(fillingIndex) * spacing
                let tilt = Double((fillingIndex % 3) - 1) * 3.5
                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: x, y: 0.42),
                    scale: 0.55,
                    rotationDegrees: tilt,
                    zIndex: Double(index),
                    labelOffset: NormalizedPoint(x: 0, y: -0.12),
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
        let count = product.ingredients.count

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
                // Fillings fan in a shallow arc
                let fillingIndex = index - 1
                let fillingCount = count - 1
                let arcAngle = 140.0
                let startAngle = -arcAngle / 2
                let angleStep = arcAngle / Double(max(fillingCount - 1, 1))
                let angle = startAngle + Double(fillingIndex) * angleStep
                let radians = angle * .pi / 180
                let radius = 0.30
                let x = 0.5 + sin(radians) * radius
                let y = 0.44 - cos(radians) * radius * 0.5
                let rotation = angle * 0.3

                transforms[ingredient.id] = IngredientTransform(
                    center: NormalizedPoint(x: x, y: y),
                    scale: 0.50,
                    rotationDegrees: rotation,
                    zIndex: Double(index),
                    labelOffset: NormalizedPoint(x: 0, y: -0.10),
                    opacity: 1.0
                )
            }
        }
        return transforms
    }
}
