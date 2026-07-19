import Testing
@testable import DishEdit

@MainActor
struct CustomizationCoordinatorTests {
    private var coordinator: CustomizationCoordinator {
        CustomizationCoordinator(product: DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!)
    }

    // MARK: - Initial State

    @Test func initialPhaseIsOpening() {
        let c = coordinator
        #expect(c.phase == .opening)
    }

    @Test func initialRevisionIsZero() {
        let c = coordinator
        #expect(c.revision == 0)
    }

    @Test func initializesFromExistingAppDraft() {
        let product = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        var draft = CustomizationDraft(product: product)
        _ = draft.remove(ingredientID: "burger.tomato")

        let c = CustomizationCoordinator(product: product, draft: draft)

        #expect(!c.isIngredientPresent(id: "burger.tomato"))
        #expect(c.revision == draft.revision)
    }

    @Test func expandTransitionsToExpanded() {
        var c = coordinator
        c.expand()
        #expect(c.phase == .expanded)
    }

    // MARK: - Valid Remove

    @Test func removeTomatoSucceeds() {
        var c = coordinator
        c.expand()
        let result = c.removeIngredient(id: "burger.tomato")
        #expect(result == .changed(revision: 1))
        #expect(c.phase == .expanded)
    }

    @Test func removeNonRemovableRejects() {
        var c = coordinator
        c.expand()
        let result = c.removeIngredient(id: "burger.bun-bottom")
        #expect(result == .rejected(reason: .ingredientNotRemovable))
    }

    @Test func removeUnknownRejects() {
        var c = coordinator
        c.expand()
        let result = c.removeIngredient(id: "fake.ingredient")
        #expect(result == .rejected(reason: .unknownIngredient))
    }

    // MARK: - Valid Add

    @Test func addCheddarSucceeds() {
        var c = coordinator
        c.expand()
        let result = c.addIngredient(id: "burger.cheddar")
        #expect(result == .changed(revision: 1))
    }

    @Test func addNonAddableRejects() {
        var c = coordinator
        c.expand()
        let result = c.addIngredient(id: "burger.patty")
        #expect(result == .rejected(reason: .ingredientNotAddable))
    }

    @Test func addUnknownRejects() {
        var c = coordinator
        c.expand()
        let result = c.addIngredient(id: "not.real")
        #expect(result == .rejected(reason: .unknownIngredient))
    }

    // MARK: - Revision Tracking

    @Test func revisionIncreasesOnSuccessfulMutation() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        #expect(c.revision == 1)
        _ = c.removeIngredient(id: "burger.onion")
        #expect(c.revision == 2)
    }

    @Test func revisionDoesNotIncreaseOnRejection() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.patty")
        #expect(c.revision == 0)
    }

    // MARK: - Undo / Redo / Reset

    @Test func undoRestoresPreviousState() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        let result = c.undo()
        #expect(result == .changed(revision: 2))
        #expect(c.isIngredientPresent(id: "burger.tomato"))
    }

    @Test func undoWithNoHistoryRejects() {
        var c = coordinator
        c.expand()
        let result = c.undo()
        #expect(result == .rejected(reason: .noStateChange))
    }

    @Test func redoAfterUndoWorks() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        _ = c.undo()
        let result = c.redo()
        #expect(result == .changed(revision: 3))
        #expect(!c.isIngredientPresent(id: "burger.tomato"))
    }

    @Test func resetGoesBackToDefault() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        _ = c.removeIngredient(id: "burger.onion")
        let result = c.reset()
        #expect(result == .changed(revision: 3))
        #expect(c.isIngredientPresent(id: "burger.tomato"))
        #expect(c.isIngredientPresent(id: "burger.onion"))
    }

    @Test func resetWithNoChangesRejects() {
        var c = coordinator
        c.expand()
        let result = c.reset()
        #expect(result == .rejected(reason: .noStateChange))
    }

    // MARK: - Phases

    @Test func confirmTransitionsToReassembling() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        c.confirm()
        #expect(c.phase == .reassembling)
    }

    @Test func finishReassemblyTransitionsToReady() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        c.confirm()
        c.finishReassembly()
        #expect(c.phase == .ready)
    }

    @Test func confirmWithNoChangesStillTransitions() {
        var c = coordinator
        c.expand()
        c.confirm()
        #expect(c.phase == .reassembling)
    }

    // MARK: - Ingredient Presence

    @Test func defaultIngredientsArePresent() {
        let c = coordinator
        #expect(c.isIngredientPresent(id: "burger.bun-top"))
        #expect(c.isIngredientPresent(id: "burger.patty"))
        #expect(c.isIngredientPresent(id: "burger.tomato"))
    }

    @Test func addableNotPresentByDefault() {
        let c = coordinator
        #expect(!c.isIngredientPresent(id: "burger.cheddar"))
        #expect(!c.isIngredientPresent(id: "burger.jalapenos"))
    }

    // MARK: - Price

    @Test func removingIngredientDoesNotChangePriceDelta() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        #expect(c.priceDeltaPaise == 0)
    }

    @Test func addingCheddarAddsFortypaise() {
        var c = coordinator
        c.expand()
        _ = c.addIngredient(id: "burger.cheddar")
        #expect(c.priceDeltaPaise == 4000)
    }

    // MARK: - Modifier Summary

    @Test func summaryReflectsRemovedAndAdded() {
        var c = coordinator
        c.expand()
        _ = c.removeIngredient(id: "burger.tomato")
        _ = c.addIngredient(id: "burger.cheddar")
        let summary = c.modifierSummary
        #expect(summary.count == 2)
        #expect(summary.contains { $0.ingredientID == "burger.tomato" && $0.kind == .removal })
        #expect(summary.contains { $0.ingredientID == "burger.cheddar" && $0.kind == .addition })
    }

    // MARK: - Layout

    @Test func expandedTransformsMatchProduct() {
        var c = coordinator
        c.expand()
        let transforms = c.currentTransforms
        #expect(transforms.count == c.product.ingredients.count)
    }

    @Test func collapsedTransformsWhenInOpening() {
        let c = coordinator
        let transforms = c.currentTransforms
        for (_, t) in transforms {
            #expect(t.center.x == 0.5)
            #expect(t.center.y == 0.5)
        }
    }
}
