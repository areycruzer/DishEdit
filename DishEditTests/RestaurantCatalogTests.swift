import Testing
@testable import DishEdit

struct RestaurantCatalogTests {
    @Test func catalogContainsExactlyThreeProducts() {
        let catalog = DemoRestaurantCatalog.copperAndCrumb
        #expect(catalog.products.map(\.id) == ["burger", "sub", "taco-wrap"])
    }

    @Test func everyIngredientIDIsGloballyStableWithinProduct() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            #expect(Set(product.ingredients.map(\.id)).count == product.ingredients.count,
                    "Duplicate ingredient ID in \(product.id)")
            #expect(product.ingredients.allSatisfy { $0.id.hasPrefix(product.id + ".") },
                    "Ingredient ID must start with product ID in \(product.id)")
        }
    }

    @Test func requiredHeroModifiersExist() throws {
        let burger = try #require(DemoRestaurantCatalog.copperAndCrumb.product(id: "burger"))
        let tomato = try #require(burger.ingredient(id: "burger.tomato"))
        #expect(tomato.defaultPresence == true)
        #expect(tomato.canRemove == true)
        #expect(tomato.priceDeltaPaise == 0)

        let cheddar = try #require(burger.ingredient(id: "burger.cheddar"))
        #expect(cheddar.defaultPresence == false)
        #expect(cheddar.canAdd == true)
        #expect(cheddar.priceDeltaPaise == 4_000)
    }

    @Test func burgerHasSevenDefaultIngredients() {
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        let defaults = burger.ingredients.filter(\.defaultPresence)
        #expect(defaults.count == 7)
    }

    @Test func burgerRemovablesAreExactlyTomatoOnionLettuce() {
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        let removableIDs = Set(burger.removableIngredients.map(\.id))
        #expect(removableIDs == ["burger.tomato", "burger.onion", "burger.lettuce"])
    }

    @Test func burgerAddablesAreCheddarAndJalapenos() {
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        let addableIDs = Set(burger.addableIngredients.map(\.id))
        #expect(addableIDs == ["burger.cheddar", "burger.jalapenos"])
    }

    @Test func subHasFourRemovableIngredients() {
        let sub = DemoRestaurantCatalog.copperAndCrumb.product(id: "sub")!
        let removableIDs = Set(sub.removableIngredients.map(\.id))
        #expect(removableIDs == ["sub.tomato", "sub.onion", "sub.cucumber", "sub.chipotle"])
    }

    @Test func subHasThreeAddableIngredients() {
        let sub = DemoRestaurantCatalog.copperAndCrumb.product(id: "sub")!
        let addableIDs = Set(sub.addableIngredients.map(\.id))
        #expect(addableIDs == ["sub.jalapenos", "sub.olives", "sub.mint-mayo"])
    }

    @Test func tacoWrapHasThreeRemovableIngredients() {
        let taco = DemoRestaurantCatalog.copperAndCrumb.product(id: "taco-wrap")!
        let removableIDs = Set(taco.removableIngredients.map(\.id))
        #expect(removableIDs == ["taco-wrap.onion", "taco-wrap.lettuce", "taco-wrap.crema"])
    }

    @Test func tacoWrapHasThreeAddableIngredients() {
        let taco = DemoRestaurantCatalog.copperAndCrumb.product(id: "taco-wrap")!
        let addableIDs = Set(taco.addableIngredients.map(\.id))
        #expect(addableIDs == ["taco-wrap.cheese", "taco-wrap.jalapenos", "taco-wrap.guacamole"])
    }

    @Test func subJalapenosCostThirtyRupees() {
        let sub = DemoRestaurantCatalog.copperAndCrumb.product(id: "sub")!
        let jalapenos = sub.ingredient(id: "sub.jalapenos")!
        #expect(jalapenos.priceDeltaPaise == 3_000)
    }

    @Test func tacoGuacamoleCostsSixtyRupees() {
        let taco = DemoRestaurantCatalog.copperAndCrumb.product(id: "taco-wrap")!
        let guac = taco.ingredient(id: "taco-wrap.guacamole")!
        #expect(guac.priceDeltaPaise == 6_000)
    }

    @Test func everyAddableHasAtLeastOnePlacementSlot() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            for ingredient in product.addableIngredients {
                #expect(!ingredient.placementSlots.isEmpty,
                        "\(ingredient.id) must have a placement slot")
            }
        }
    }

    @Test func nonAddableIngredientsHaveNoPlacementSlots() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            for ingredient in product.ingredients where !ingredient.canAdd {
                #expect(ingredient.placementSlots.isEmpty,
                        "\(ingredient.id) should not have placement slots")
            }
        }
    }

    @Test func productPresentationsMatchExpectedTypes() {
        let catalog = DemoRestaurantCatalog.copperAndCrumb
        #expect(catalog.product(id: "burger")?.presentation == .explodedLayers)
        #expect(catalog.product(id: "sub")?.presentation == .sandwichCounter)
        #expect(catalog.product(id: "taco-wrap")?.presentation == .tacoFan)
    }

    @Test func restaurantLookupReturnsNilForUnknownID() {
        let catalog = DemoRestaurantCatalog.copperAndCrumb
        #expect(catalog.product(id: "pizza") == nil)
        let burger = catalog.product(id: "burger")!
        #expect(burger.ingredient(id: "burger.mushrooms") == nil)
    }

    @Test func defaultIngredientIDsMatchDefaultPresence() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            let defaultIDs = product.defaultIngredientIDs
            let expectedIDs = Set(product.ingredients.filter(\.defaultPresence).map(\.id))
            #expect(defaultIDs == expectedIDs, "Default IDs mismatch in \(product.id)")
        }
    }
}
