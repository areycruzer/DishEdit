import Foundation

// MARK: - Deterministic Instruction Parser

nonisolated struct DeterministicInstructionParser: Sendable {
    func parse(product: ProductDefinition, draft: CustomizationDraft) -> InstructionProposal {
        var instructions: [KitchenInstruction] = []

        for ingredient in product.ingredients {
            let isPresent = draft.presentIngredientIDs.contains(ingredient.id)
            let isDefault = ingredient.defaultPresence

            if isDefault && !isPresent && ingredient.canRemove {
                instructions.append(KitchenInstruction(
                    id: "omit.\(ingredient.id)",
                    verb: .omit,
                    ingredientID: ingredient.id,
                    ingredientName: ingredient.name,
                    detail: "Remove \(ingredient.name) from dish",
                    confidence: .deterministic,
                    allergenFlags: AllergenDatabase.allergens(for: ingredient.name)
                ))
            } else if !isDefault && isPresent && ingredient.canAdd {
                instructions.append(KitchenInstruction(
                    id: "add.\(ingredient.id)",
                    verb: .add,
                    ingredientID: ingredient.id,
                    ingredientName: ingredient.name,
                    detail: "Add \(ingredient.name) to dish",
                    confidence: .deterministic,
                    allergenFlags: AllergenDatabase.allergens(for: ingredient.name)
                ))
            }
        }

        return InstructionProposal(
            productID: product.id,
            productName: product.name,
            instructions: instructions,
            generatedAt: .now,
            isDeterministic: true
        )
    }
}

// MARK: - Instruction Validator

nonisolated struct InstructionValidator: Sendable {
    func validate(
        proposal: InstructionProposal,
        against product: ProductDefinition
    ) -> InstructionValidationResult {
        var errors: [InstructionValidationError] = []
        var warnings: [String] = []
        var seenIngredients: Set<String> = []

        if proposal.instructions.isEmpty {
            errors.append(.emptyProposal)
            return InstructionValidationResult(isValid: false, errors: errors, warnings: warnings)
        }

        for instruction in proposal.instructions {
            if seenIngredients.contains(instruction.ingredientID) {
                errors.append(.duplicateInstruction(ingredientID: instruction.ingredientID))
                continue
            }
            seenIngredients.insert(instruction.ingredientID)

            guard let ingredient = product.ingredient(id: instruction.ingredientID) else {
                errors.append(.ingredientNotFound(id: instruction.ingredientID))
                continue
            }

            switch instruction.verb {
            case .omit:
                if !ingredient.canRemove {
                    errors.append(.ingredientNotRemovable(id: instruction.ingredientID))
                }
            case .add:
                if !ingredient.canAdd {
                    errors.append(.ingredientNotAddable(id: instruction.ingredientID))
                }
            case .substitute:
                if !ingredient.canRemove {
                    errors.append(.ingredientNotRemovable(id: instruction.ingredientID))
                }
            }

            if !instruction.allergenFlags.isEmpty {
                let allergenList = instruction.allergenFlags.sorted().joined(separator: ", ")
                warnings.append("\(instruction.ingredientName) contains: \(allergenList)")
            }

            if instruction.confidence == .low {
                warnings.append("\(instruction.ingredientName): low confidence — review recommended")
            }
        }

        return InstructionValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
}
