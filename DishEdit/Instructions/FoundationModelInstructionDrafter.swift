import Foundation
import FoundationModels

// MARK: - Generable Instruction Schema

@Generable
struct GeneratedInstruction: Sendable {
    @Guide(description: "The action to perform: omit, add, or substitute")
    var verb: String

    @Guide(description: "The ingredient identifier from the product catalog")
    var ingredientID: String

    @Guide(description: "Human-readable name of the ingredient")
    var ingredientName: String

    @Guide(description: "Detailed instruction for the kitchen, one sentence")
    var detail: String
}

@Generable
struct GeneratedInstructionSet: Sendable {
    @Guide(description: "List of kitchen instructions based on the customization")
    var instructions: [GeneratedInstruction]
}

// MARK: - Foundation Model Instruction Drafter

@available(iOS 26.0, *)
actor FoundationModelInstructionDrafter {

    enum DrafterError: Error, Sendable {
        case sessionUnavailable
        case generationFailed(underlying: Error)
        case invalidVerb(String)
    }

    private var session: LanguageModelSession?

    func draft(
        product: ProductDefinition,
        draft: CustomizationDraft
    ) async throws -> InstructionProposal {
        let session = try await resolveSession()

        let prompt = buildPrompt(product: product, draft: draft)
        let response = try await session.respond(to: prompt, generating: GeneratedInstructionSet.self)

        let instructions = response.content.instructions.compactMap { generated -> KitchenInstruction? in
            guard let verb = parseVerb(generated.verb) else { return nil }
            return KitchenInstruction(
                id: "\(verb.rawValue).\(generated.ingredientID)",
                verb: verb,
                ingredientID: generated.ingredientID,
                ingredientName: generated.ingredientName,
                detail: generated.detail,
                confidence: .high,
                allergenFlags: AllergenDatabase.allergens(for: generated.ingredientName)
            )
        }

        return InstructionProposal(
            productID: product.id,
            productName: product.name,
            instructions: instructions,
            generatedAt: .now,
            isDeterministic: false
        )
    }

    private func resolveSession() async throws -> LanguageModelSession {
        if let existing = session { return existing }
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
            throw DrafterError.sessionUnavailable
        }
        let newSession = LanguageModelSession()
        session = newSession
        return newSession
    }

    private func buildPrompt(product: ProductDefinition, draft: CustomizationDraft) -> String {
        var lines: [String] = []
        lines.append("Product: \(product.name)")
        lines.append("Available ingredients:")

        for ingredient in product.ingredients {
            let presence = draft.presentIngredientIDs.contains(ingredient.id) ? "present" : "absent"
            let defaultState = ingredient.defaultPresence ? "default" : "optional"
            lines.append("  - \(ingredient.id): \(ingredient.name) [\(defaultState), currently \(presence)]")
        }

        lines.append("")
        lines.append("Changes from default:")
        let removed = product.ingredients.filter {
            $0.defaultPresence && !draft.presentIngredientIDs.contains($0.id)
        }
        let added = product.ingredients.filter {
            !$0.defaultPresence && draft.presentIngredientIDs.contains($0.id)
        }

        for r in removed {
            lines.append("  - REMOVED: \(r.name) (\(r.id))")
        }
        for a in added {
            lines.append("  - ADDED: \(a.name) (\(a.id))")
        }

        lines.append("")
        lines.append("Generate kitchen instructions for each change. Use verb 'omit' for removals, 'add' for additions.")

        return lines.joined(separator: "\n")
    }

    private func parseVerb(_ raw: String) -> KitchenInstruction.Verb? {
        switch raw.lowercased() {
        case "omit", "remove": .omit
        case "add": .add
        case "substitute", "sub": .substitute
        default: nil
        }
    }

    func resetSession() {
        session = nil
    }
}

// MARK: - Composite Instruction Drafter

@available(iOS 26.0, *)
actor CompositeInstructionDrafter {
    private let deterministicParser = DeterministicInstructionParser()
    private let foundationDrafter = FoundationModelInstructionDrafter()
    private let validator = InstructionValidator()

    enum Strategy: Sendable {
        case deterministicOnly
        case foundationModelWithFallback
    }

    func draft(
        product: ProductDefinition,
        customization: CustomizationDraft,
        strategy: Strategy = .foundationModelWithFallback
    ) async -> InstructionProposal {
        switch strategy {
        case .deterministicOnly:
            return deterministicParser.parse(product: product, draft: customization)

        case .foundationModelWithFallback:
            do {
                let proposal = try await foundationDrafter.draft(product: product, draft: customization)
                let validation = validator.validate(proposal: proposal, against: product)
                if validation.isValid {
                    return proposal
                }
                return deterministicParser.parse(product: product, draft: customization)
            } catch {
                return deterministicParser.parse(product: product, draft: customization)
            }
        }
    }
}
