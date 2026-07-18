import Testing
@testable import DishEdit

struct CustomizationDraftTests {
    private func burgerDraft() -> CustomizationDraft {
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        return CustomizationDraft(product: burger)
    }

    private func subDraft() -> CustomizationDraft {
        let sub = DemoRestaurantCatalog.copperAndCrumb.product(id: "sub")!
        return CustomizationDraft(product: sub)
    }

    // MARK: - Initial state

    @Test func initialDraftContainsAllDefaultIngredients() {
        let draft = burgerDraft()
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        #expect(draft.presentIngredientIDs == burger.defaultIngredientIDs)
    }

    @Test func initialRevisionIsZero() {
        let draft = burgerDraft()
        #expect(draft.revision == 0)
    }

    @Test func initialPriceDeltaIsZero() {
        let draft = burgerDraft()
        #expect(draft.priceDeltaPaise == 0)
    }

    // MARK: - Removal

    @Test func removeTomatoSucceeds() {
        var draft = burgerDraft()
        let result = draft.remove(ingredientID: "burger.tomato")
        #expect(result == .changed(revision: 1))
        #expect(!draft.presentIngredientIDs.contains("burger.tomato"))
    }

    @Test func removeTomatoDoesNotChangePriceDelta() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        #expect(draft.priceDeltaPaise == 0)
    }

    @Test func removeNonRemovableIsRejected() {
        var draft = burgerDraft()
        let result = draft.remove(ingredientID: "burger.patty")
        #expect(result == .rejected(reason: .ingredientNotRemovable))
        #expect(draft.revision == 0)
    }

    @Test func removeUnknownIngredientIsRejected() {
        var draft = burgerDraft()
        let result = draft.remove(ingredientID: "burger.mushrooms")
        #expect(result == .rejected(reason: .unknownIngredient))
    }

    @Test func removeAlreadyRemovedIsNoOp() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        let result = draft.remove(ingredientID: "burger.tomato")
        #expect(result == .rejected(reason: .noStateChange))
        #expect(draft.revision == 1)
    }

    // MARK: - Addition

    @Test func addCheddarSucceeds() {
        var draft = burgerDraft()
        let result = draft.add(ingredientID: "burger.cheddar")
        #expect(result == .changed(revision: 1))
        #expect(draft.presentIngredientIDs.contains("burger.cheddar"))
    }

    @Test func addCheddarCostsFortyRupees() {
        var draft = burgerDraft()
        _ = draft.add(ingredientID: "burger.cheddar")
        #expect(draft.priceDeltaPaise == 4_000)
    }

    @Test func addNonAddableIsRejected() {
        var draft = burgerDraft()
        let result = draft.add(ingredientID: "burger.tomato")
        #expect(result == .rejected(reason: .ingredientNotAddable))
    }

    @Test func addAlreadyPresentIsNoOp() {
        var draft = burgerDraft()
        _ = draft.add(ingredientID: "burger.cheddar")
        let result = draft.add(ingredientID: "burger.cheddar")
        #expect(result == .rejected(reason: .noStateChange))
        #expect(draft.revision == 1)
    }

    @Test func addUnknownIngredientIsRejected() {
        var draft = burgerDraft()
        let result = draft.add(ingredientID: "taco-wrap.guacamole")
        #expect(result == .rejected(reason: .unknownIngredient))
    }

    // MARK: - Restore

    @Test func restoreRemovedIngredient() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        let result = draft.restore(ingredientID: "burger.tomato")
        #expect(result == .changed(revision: 2))
        #expect(draft.presentIngredientIDs.contains("burger.tomato"))
    }

    @Test func restoreAddedIngredient() {
        var draft = burgerDraft()
        _ = draft.add(ingredientID: "burger.cheddar")
        let result = draft.restore(ingredientID: "burger.cheddar")
        #expect(result == .changed(revision: 2))
        #expect(!draft.presentIngredientIDs.contains("burger.cheddar"))
        #expect(draft.priceDeltaPaise == 0)
    }

    @Test func restoreAlreadyDefaultIsNoOp() {
        var draft = burgerDraft()
        let result = draft.restore(ingredientID: "burger.tomato")
        #expect(result == .rejected(reason: .noStateChange))
    }

    // MARK: - Undo / Redo / Reset

    @Test func undoRestoresPreviousState() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        let result = draft.undo()
        #expect(result == .changed(revision: 2))
        #expect(draft.presentIngredientIDs.contains("burger.tomato"))
    }

    @Test func undoWithNoHistoryIsRejected() {
        var draft = burgerDraft()
        let result = draft.undo()
        #expect(result == .rejected(reason: .noStateChange))
    }

    @Test func redoRestoresUndoneState() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.undo()
        let result = draft.redo()
        #expect(result == .changed(revision: 3))
        #expect(!draft.presentIngredientIDs.contains("burger.tomato"))
    }

    @Test func redoWithNoFutureIsRejected() {
        var draft = burgerDraft()
        let result = draft.redo()
        #expect(result == .rejected(reason: .noStateChange))
    }

    @Test func newMutationClearsFuture() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.undo()
        _ = draft.add(ingredientID: "burger.cheddar")
        let result = draft.redo()
        #expect(result == .rejected(reason: .noStateChange))
    }

    @Test func resetRestoresAllDefaults() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.add(ingredientID: "burger.cheddar")
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        let result = draft.reset()
        #expect(result == .changed(revision: 3))
        #expect(draft.presentIngredientIDs == burger.defaultIngredientIDs)
        #expect(draft.priceDeltaPaise == 0)
    }

    @Test func resetWhenAlreadyDefaultIsNoOp() {
        var draft = burgerDraft()
        let result = draft.reset()
        #expect(result == .rejected(reason: .noStateChange))
    }

    // MARK: - Combined operations

    @Test func heroSequenceProducesCorrectPriceDelta() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.add(ingredientID: "burger.cheddar")
        #expect(draft.priceDeltaPaise == 4_000)
    }

    @Test func revisionIncreasesOnlyForAcceptedMutations() {
        var draft = burgerDraft()
        _ = draft.remove(ingredientID: "burger.mushrooms") // rejected
        #expect(draft.revision == 0)
        _ = draft.remove(ingredientID: "burger.tomato")    // accepted
        #expect(draft.revision == 1)
        _ = draft.remove(ingredientID: "burger.tomato")    // no-op
        #expect(draft.revision == 1)
    }

    @Test func modifierSummaryReflectsCurrentState() {
        var draft = burgerDraft()
        #expect(draft.modifierSummary.isEmpty)
        _ = draft.remove(ingredientID: "burger.tomato")
        _ = draft.add(ingredientID: "burger.cheddar")

        let summary = draft.modifierSummary
        #expect(summary.contains { $0.label == "No Tomato" && $0.priceDeltaPaise == 0 })
        #expect(summary.contains { $0.label == "Add Cheddar cheese" && $0.priceDeltaPaise == 4_000 })
    }

    @Test func subMultipleRemovalsAndAdditions() {
        var draft = subDraft()
        _ = draft.remove(ingredientID: "sub.tomato")
        _ = draft.remove(ingredientID: "sub.onion")
        _ = draft.add(ingredientID: "sub.jalapenos")
        _ = draft.add(ingredientID: "sub.olives")
        #expect(draft.priceDeltaPaise == 6_500) // 3000 + 3500
        #expect(draft.revision == 4)
    }
}
