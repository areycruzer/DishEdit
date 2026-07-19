import Foundation

// MARK: - Kitchen Instruction Models

nonisolated struct KitchenInstruction: Identifiable, Equatable, Sendable {
    enum Verb: String, Codable, Sendable {
        case omit
        case add
        case substitute
    }

    enum Confidence: Comparable, Sendable {
        case deterministic
        case high
        case low
    }

    let id: String
    let verb: Verb
    let ingredientID: String
    let ingredientName: String
    let detail: String
    let confidence: Confidence
    let allergenFlags: Set<String>

    var displayText: String {
        switch verb {
        case .omit: "No \(ingredientName)"
        case .add: "Add \(ingredientName)"
        case .substitute: "Sub: \(detail)"
        }
    }
}

nonisolated struct InstructionProposal: Equatable, Sendable {
    let productID: String
    let productName: String
    let instructions: [KitchenInstruction]
    let generatedAt: Date
    let isDeterministic: Bool

    var allergenFlags: Set<String> {
        instructions.reduce(into: Set<String>()) { $0.formUnion($1.allergenFlags) }
    }

    var hasLowConfidence: Bool {
        instructions.contains { $0.confidence == .low }
    }
}

// MARK: - Validation

nonisolated enum InstructionValidationError: Error, Equatable, Sendable {
    case ingredientNotFound(id: String)
    case ingredientNotRemovable(id: String)
    case ingredientNotAddable(id: String)
    case duplicateInstruction(ingredientID: String)
    case emptyProposal
}

nonisolated struct InstructionValidationResult: Equatable, Sendable {
    let isValid: Bool
    let errors: [InstructionValidationError]
    let warnings: [String]
}

// MARK: - Allergen Database

nonisolated enum AllergenDatabase {
    static let ingredientAllergens: [String: Set<String>] = [
        "cheese": ["dairy"],
        "cheddar": ["dairy"],
        "mozzarella": ["dairy"],
        "paneer": ["dairy"],
        "cream": ["dairy"],
        "butter": ["dairy"],
        "egg": ["egg"],
        "mayo": ["egg"],
        "peanut": ["peanut"],
        "almond": ["tree_nut"],
        "cashew": ["tree_nut"],
        "walnut": ["tree_nut"],
        "wheat": ["gluten"],
        "bread": ["gluten"],
        "bun": ["gluten"],
        "soy": ["soy"],
        "tofu": ["soy"],
        "shrimp": ["shellfish"],
        "prawn": ["shellfish"],
        "fish": ["fish"],
    ]

    static func allergens(for ingredientName: String) -> Set<String> {
        let lower = ingredientName.lowercased()
        var result: Set<String> = []
        for (key, flags) in ingredientAllergens {
            if lower.contains(key) { result.formUnion(flags) }
        }
        return result
    }
}
