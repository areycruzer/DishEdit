import Testing
@testable import DishEdit

struct IngredientLayoutTests {
    private var burger: ProductDefinition {
        DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
    }

    private var sub: ProductDefinition {
        DemoRestaurantCatalog.copperAndCrumb.product(id: "sub")!
    }

    private var taco: ProductDefinition {
        DemoRestaurantCatalog.copperAndCrumb.product(id: "taco-wrap")!
    }

    // MARK: - Collapsed

    @Test func collapsedGivesEveryIngredientATransform() {
        let transforms = IngredientLayout.collapsed(for: burger)
        #expect(transforms.count == burger.ingredients.count)
        for ingredient in burger.ingredients {
            #expect(transforms[ingredient.id] != nil, "\(ingredient.id) missing transform")
        }
    }

    @Test func collapsedCentersAllAtHalfHalf() {
        let transforms = IngredientLayout.collapsed(for: burger)
        for (_, transform) in transforms {
            #expect(transform.center.x == 0.5)
            #expect(transform.center.y == 0.5)
        }
    }

    // MARK: - Expanded

    @Test func expandedGivesEveryIngredientATransform() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let transforms = IngredientLayout.expanded(for: product)
            #expect(transforms.count == product.ingredients.count,
                    "\(product.id) has wrong transform count")
        }
    }

    @Test func expandedPositionsAreInNormalizedRange() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let transforms = IngredientLayout.expanded(for: product)
            for (id, transform) in transforms {
                #expect(transform.center.x >= 0 && transform.center.x <= 1,
                        "\(id) x out of range: \(transform.center.x)")
                #expect(transform.center.y >= 0 && transform.center.y <= 1,
                        "\(id) y out of range: \(transform.center.y)")
            }
        }
    }

    @Test func burgerAndTacoHaveDifferentExpandedLayouts() {
        let burgerTransforms = IngredientLayout.expanded(for: burger)
        let tacoTransforms = IngredientLayout.expanded(for: taco)
        let burgerCenters = Set(burgerTransforms.values.map { "\($0.center.x),\($0.center.y)" })
        let tacoCenters = Set(tacoTransforms.values.map { "\($0.center.x),\($0.center.y)" })
        #expect(burgerCenters != tacoCenters)
    }

    @Test func subBreadStaysAtBottom() {
        let transforms = IngredientLayout.expanded(for: sub)
        let bread = transforms["sub.bread"]!
        #expect(bread.center.y > 0.7, "Bread should be at bottom")
    }

    @Test func tacoTortillaStaysAtBottom() {
        let transforms = IngredientLayout.expanded(for: taco)
        let tortilla = transforms["taco-wrap.tortilla"]!
        #expect(tortilla.center.y > 0.7, "Tortilla should be at bottom")
    }

    // MARK: - Reduce Motion

    @Test func reduceMotionIsReadableList() {
        let transforms = IngredientLayout.reduceMotion(for: burger)
        #expect(transforms.count == burger.ingredients.count)
        let ys = burger.ingredients.compactMap { transforms[$0.id]?.center.y }
        for i in 1..<ys.count {
            #expect(ys[i] > ys[i - 1], "Items should be vertically ordered")
        }
    }

    @Test func reduceMotionHasNoRotation() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let transforms = IngredientLayout.reduceMotion(for: product)
            for (_, transform) in transforms {
                #expect(transform.rotationDegrees == 0)
            }
        }
    }

    // MARK: - Drop Regions

    @Test func dropRegionsExistForAllAddableIngredients() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let regions = IngredientLayout.dropRegions(for: product)
            for ingredient in product.addableIngredients {
                #expect(regions[ingredient.id] != nil, "\(ingredient.id) missing drop region")
            }
        }
    }

    @Test func dropRegionsAreInNormalizedRange() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let regions = IngredientLayout.dropRegions(for: product)
            for (id, region) in regions {
                #expect(region.x >= 0 && region.x + region.width <= 1,
                        "\(id) x region out of bounds")
                #expect(region.y >= 0 && region.y + region.height <= 1,
                        "\(id) y region out of bounds")
            }
        }
    }

    // MARK: - Catalog order preserved

    @Test func collapsedZIndexMatchesCatalogOrder() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let transforms = IngredientLayout.collapsed(for: product)
            for (index, ingredient) in product.ingredients.enumerated() {
                #expect(transforms[ingredient.id]?.zIndex == Double(index),
                        "\(ingredient.id) zIndex mismatch")
            }
        }
    }
}
