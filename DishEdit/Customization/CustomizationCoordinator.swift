import Foundation
import Observation

// MARK: - Editor Phase

nonisolated enum EditorPhase: Equatable, Sendable {
    case opening
    case expanded
    case reassembling
    case ready
}

// MARK: - Customization Coordinator

@MainActor
@Observable
final class CustomizationCoordinator {
    let product: ProductDefinition
    private(set) var draft: CustomizationDraft
    private(set) var phase: EditorPhase = .opening

    init(product: ProductDefinition) {
        self.product = product
        self.draft = CustomizationDraft(product: product)
    }

    var revision: UInt64 { draft.revision }
    var priceDeltaPaise: Int { draft.priceDeltaPaise }
    var modifierSummary: [ModifierSummaryItem] { draft.modifierSummary }
    var hasChanges: Bool { draft.hasChanges }

    func isIngredientPresent(id: String) -> Bool {
        draft.presentIngredientIDs.contains(id)
    }

    // MARK: - Layout

    var currentTransforms: [String: IngredientTransform] {
        switch phase {
        case .opening, .reassembling, .ready:
            return IngredientLayout.collapsed(for: product)
        case .expanded:
            return IngredientLayout.expanded(for: product)
        }
    }

    // MARK: - Phase Transitions

    func expand() {
        phase = .expanded
    }

    func confirm() {
        phase = .reassembling
    }

    func finishReassembly() {
        phase = .ready
    }

    // MARK: - Mutations

    @discardableResult
    func removeIngredient(id: String) -> CustomizationMutation {
        draft.remove(ingredientID: id)
    }

    @discardableResult
    func addIngredient(id: String) -> CustomizationMutation {
        draft.add(ingredientID: id)
    }

    @discardableResult
    func restoreIngredient(id: String) -> CustomizationMutation {
        draft.restore(ingredientID: id)
    }

    @discardableResult
    func undo() -> CustomizationMutation {
        draft.undo()
    }

    @discardableResult
    func redo() -> CustomizationMutation {
        draft.redo()
    }

    @discardableResult
    func reset() -> CustomizationMutation {
        draft.reset()
    }
}
