import Foundation

// MARK: - Customization Draft

nonisolated struct CustomizationDraft: Equatable, Sendable {
    let productID: String
    private let product: ProductDefinition
    private(set) var presentIngredientIDs: Set<String>
    private(set) var revision: UInt64 = 0
    private(set) var history: [CustomizationSnapshot] = []
    private(set) var future: [CustomizationSnapshot] = []

    init(product: ProductDefinition) {
        self.productID = product.id
        self.product = product
        self.presentIngredientIDs = product.defaultIngredientIDs
    }

    var priceDeltaPaise: Int {
        product.ingredients
            .filter { ingredient in
                let isPresent = presentIngredientIDs.contains(ingredient.id)
                let isDefault = ingredient.defaultPresence
                if ingredient.canAdd && !isDefault && isPresent {
                    return true
                }
                return false
            }
            .reduce(0) { $0 + $1.priceDeltaPaise }
    }

    var modifierSummary: [ModifierSummaryItem] {
        var items: [ModifierSummaryItem] = []
        for ingredient in product.ingredients {
            let isPresent = presentIngredientIDs.contains(ingredient.id)
            if ingredient.defaultPresence && !isPresent && ingredient.canRemove {
                items.append(ModifierSummaryItem(
                    ingredientID: ingredient.id,
                    label: "No \(ingredient.name)",
                    kind: .removal,
                    priceDeltaPaise: 0
                ))
            } else if !ingredient.defaultPresence && isPresent && ingredient.canAdd {
                items.append(ModifierSummaryItem(
                    ingredientID: ingredient.id,
                    label: "Add \(ingredient.name)",
                    kind: .addition,
                    priceDeltaPaise: ingredient.priceDeltaPaise
                ))
            }
        }
        return items
    }

    var hasChanges: Bool {
        presentIngredientIDs != product.defaultIngredientIDs
    }

    var removedIngredientIDs: Set<String> {
        product.defaultIngredientIDs.subtracting(presentIngredientIDs)
    }

    var addedIngredientIDs: Set<String> {
        presentIngredientIDs.subtracting(product.defaultIngredientIDs)
    }

    // MARK: - Mutations

    mutating func remove(ingredientID: String) -> CustomizationMutation {
        guard let ingredient = product.ingredient(id: ingredientID) else {
            return .rejected(reason: .unknownIngredient)
        }
        guard ingredient.canRemove else {
            return .rejected(reason: .ingredientNotRemovable)
        }
        guard presentIngredientIDs.contains(ingredientID) else {
            return .rejected(reason: .noStateChange)
        }
        pushHistory()
        presentIngredientIDs.remove(ingredientID)
        revision &+= 1
        return .changed(revision: revision)
    }

    mutating func add(ingredientID: String) -> CustomizationMutation {
        guard let ingredient = product.ingredient(id: ingredientID) else {
            return .rejected(reason: .unknownIngredient)
        }
        guard ingredient.canAdd else {
            return .rejected(reason: .ingredientNotAddable)
        }
        guard !presentIngredientIDs.contains(ingredientID) else {
            return .rejected(reason: .noStateChange)
        }
        pushHistory()
        presentIngredientIDs.insert(ingredientID)
        revision &+= 1
        return .changed(revision: revision)
    }

    mutating func restore(ingredientID: String) -> CustomizationMutation {
        guard let ingredient = product.ingredient(id: ingredientID) else {
            return .rejected(reason: .unknownIngredient)
        }
        let isPresent = presentIngredientIDs.contains(ingredientID)
        let isDefault = ingredient.defaultPresence

        if isPresent == isDefault {
            return .rejected(reason: .noStateChange)
        }

        pushHistory()
        if isDefault {
            presentIngredientIDs.insert(ingredientID)
        } else {
            presentIngredientIDs.remove(ingredientID)
        }
        revision &+= 1
        return .changed(revision: revision)
    }

    mutating func undo() -> CustomizationMutation {
        guard let previous = history.popLast() else {
            return .rejected(reason: .noStateChange)
        }
        future.append(CustomizationSnapshot(presentIngredientIDs: presentIngredientIDs))
        presentIngredientIDs = previous.presentIngredientIDs
        revision &+= 1
        return .changed(revision: revision)
    }

    mutating func redo() -> CustomizationMutation {
        guard let next = future.popLast() else {
            return .rejected(reason: .noStateChange)
        }
        history.append(CustomizationSnapshot(presentIngredientIDs: presentIngredientIDs))
        presentIngredientIDs = next.presentIngredientIDs
        revision &+= 1
        return .changed(revision: revision)
    }

    mutating func reset() -> CustomizationMutation {
        guard hasChanges else {
            return .rejected(reason: .noStateChange)
        }
        pushHistory()
        presentIngredientIDs = product.defaultIngredientIDs
        revision &+= 1
        return .changed(revision: revision)
    }

    private mutating func pushHistory() {
        history.append(CustomizationSnapshot(presentIngredientIDs: presentIngredientIDs))
        future.removeAll()
    }
}

// MARK: - Supporting Types

nonisolated struct CustomizationSnapshot: Equatable, Sendable {
    let presentIngredientIDs: Set<String>
}

nonisolated enum CustomizationMutation: Equatable, Sendable {
    case changed(revision: UInt64)
    case rejected(reason: Rejection)

    nonisolated enum Rejection: Equatable, Sendable {
        case unknownIngredient
        case ingredientNotRemovable
        case ingredientNotAddable
        case noStateChange
    }
}

nonisolated struct ModifierSummaryItem: Equatable, Sendable {
    let ingredientID: String
    let label: String
    let kind: ModifierSummaryKind
    let priceDeltaPaise: Int
}

nonisolated enum ModifierSummaryKind: Equatable, Sendable {
    case removal
    case addition
}
