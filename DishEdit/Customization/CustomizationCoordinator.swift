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
    private(set) var previewAssetName: String?

    private let previewEngine: ReviewedPreviewEngine

    init(product: ProductDefinition) {
        self.product = product
        self.draft = CustomizationDraft(product: product)
        self.previewEngine = ReviewedPreviewEngine()
        self.previewAssetName = product.assembledAssetName
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
        Task { await updatePreview() }
    }

    func finishReassembly() {
        phase = .ready
    }

    // MARK: - Mutations

    @discardableResult
    func removeIngredient(id: String) -> CustomizationMutation {
        let result = draft.remove(ingredientID: id)
        Task { await updatePreview() }
        return result
    }

    @discardableResult
    func addIngredient(id: String) -> CustomizationMutation {
        let result = draft.add(ingredientID: id)
        Task { await updatePreview() }
        return result
    }

    @discardableResult
    func restoreIngredient(id: String) -> CustomizationMutation {
        let result = draft.restore(ingredientID: id)
        Task { await updatePreview() }
        return result
    }

    @discardableResult
    func undo() -> CustomizationMutation {
        let result = draft.undo()
        Task { await updatePreview() }
        return result
    }

    @discardableResult
    func redo() -> CustomizationMutation {
        let result = draft.redo()
        Task { await updatePreview() }
        return result
    }

    @discardableResult
    func reset() -> CustomizationMutation {
        let result = draft.reset()
        previewAssetName = product.assembledAssetName
        return result
    }

    // MARK: - Preview

    private func updatePreview() async {
        let request = PreviewRequest(
            product: product,
            removedIngredientIDs: draft.removedIngredientIDs,
            addedIngredientIDs: draft.addedIngredientIDs,
            revision: draft.revision
        )
        let result = await previewEngine.previewImage(for: request)
        switch result {
        case .reviewed(let assetName):
            previewAssetName = assetName
        case .generated(_, let cacheKey):
            previewAssetName = cacheKey
        case .unavailable:
            previewAssetName = product.assembledAssetName
        }
    }
}
