import Foundation
import Testing
@testable import DishEdit

struct DeterministicInstructionParserTests {

    private let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!

    @Test func noChangesProducesEmptyInstructions() {
        let draft = CustomizationDraft(product: burger)
        let parser = DeterministicInstructionParser()

        let proposal = parser.parse(product: burger, draft: draft)

        #expect(proposal.instructions.isEmpty)
        #expect(proposal.isDeterministic)
        #expect(proposal.productID == "burger")
    }

    @Test func removalCreatesOmitInstruction() {
        var draft = CustomizationDraft(product: burger)
        let removable = burger.removableIngredients.first!
        _ = draft.remove(ingredientID: removable.id)

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        #expect(proposal.instructions.count == 1)
        let instruction = proposal.instructions[0]
        #expect(instruction.verb == .omit)
        #expect(instruction.ingredientID == removable.id)
        #expect(instruction.confidence == .deterministic)
    }

    @Test func additionCreatesAddInstruction() {
        var draft = CustomizationDraft(product: burger)
        let addable = burger.addableIngredients.first!
        _ = draft.add(ingredientID: addable.id)

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        #expect(proposal.instructions.count == 1)
        let instruction = proposal.instructions[0]
        #expect(instruction.verb == .add)
        #expect(instruction.ingredientID == addable.id)
        #expect(instruction.confidence == .deterministic)
    }

    @Test func combinedChangesProduceMultipleInstructions() {
        var draft = CustomizationDraft(product: burger)
        let removable = burger.removableIngredients.first!
        let addable = burger.addableIngredients.first!
        _ = draft.remove(ingredientID: removable.id)
        _ = draft.add(ingredientID: addable.id)

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        #expect(proposal.instructions.count == 2)
        #expect(proposal.instructions.contains { $0.verb == .omit })
        #expect(proposal.instructions.contains { $0.verb == .add })
    }

    @Test func allergenFlagsArePopulated() {
        var draft = CustomizationDraft(product: burger)
        let addable = burger.addableIngredients.first!
        _ = draft.add(ingredientID: addable.id)

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        if addable.name.lowercased().contains("cheddar") || addable.name.lowercased().contains("cheese") {
            #expect(proposal.allergenFlags.contains("dairy"))
        }
    }

    @Test func instructionIDsAreUnique() {
        var draft = CustomizationDraft(product: burger)
        for removable in burger.removableIngredients {
            _ = draft.remove(ingredientID: removable.id)
        }
        for addable in burger.addableIngredients {
            _ = draft.add(ingredientID: addable.id)
        }

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        let ids = proposal.instructions.map(\.id)
        #expect(Set(ids).count == ids.count)
    }
}

struct InstructionValidatorTests {

    private let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!

    @Test func validProposalPasses() {
        var draft = CustomizationDraft(product: burger)
        let removable = burger.removableIngredients.first!
        _ = draft.remove(ingredientID: removable.id)

        let parser = DeterministicInstructionParser()
        let proposal = parser.parse(product: burger, draft: draft)

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    @Test func emptyProposalFails() {
        let proposal = InstructionProposal(
            productID: "burger",
            productName: "Burger",
            instructions: [],
            generatedAt: .now,
            isDeterministic: true
        )

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(!result.isValid)
        #expect(result.errors.contains(.emptyProposal))
    }

    @Test func unknownIngredientFails() {
        let badInstruction = KitchenInstruction(
            id: "omit.fake",
            verb: .omit,
            ingredientID: "burger.fake",
            ingredientName: "Fake",
            detail: "Remove fake ingredient",
            confidence: .deterministic,
            allergenFlags: []
        )
        let proposal = InstructionProposal(
            productID: "burger",
            productName: "Burger",
            instructions: [badInstruction],
            generatedAt: .now,
            isDeterministic: false
        )

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(!result.isValid)
        #expect(result.errors.contains(.ingredientNotFound(id: "burger.fake")))
    }

    @Test func duplicateInstructionFails() {
        let removable = burger.removableIngredients.first!
        let instruction = KitchenInstruction(
            id: "omit.\(removable.id)",
            verb: .omit,
            ingredientID: removable.id,
            ingredientName: removable.name,
            detail: "Remove \(removable.name)",
            confidence: .deterministic,
            allergenFlags: []
        )
        let proposal = InstructionProposal(
            productID: "burger",
            productName: "Burger",
            instructions: [instruction, instruction],
            generatedAt: .now,
            isDeterministic: false
        )

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(!result.isValid)
        #expect(result.errors.contains(.duplicateInstruction(ingredientID: removable.id)))
    }

    @Test func allergenWarningsAreGenerated() {
        let addable = burger.addableIngredients.first!
        let instruction = KitchenInstruction(
            id: "add.\(addable.id)",
            verb: .add,
            ingredientID: addable.id,
            ingredientName: addable.name,
            detail: "Add \(addable.name)",
            confidence: .deterministic,
            allergenFlags: ["dairy"]
        )
        let proposal = InstructionProposal(
            productID: "burger",
            productName: "Burger",
            instructions: [instruction],
            generatedAt: .now,
            isDeterministic: true
        )

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(result.isValid)
        #expect(!result.warnings.isEmpty)
        #expect(result.warnings.first?.contains("dairy") == true)
    }

    @Test func lowConfidenceGeneratesWarning() {
        let removable = burger.removableIngredients.first!
        let instruction = KitchenInstruction(
            id: "omit.\(removable.id)",
            verb: .omit,
            ingredientID: removable.id,
            ingredientName: removable.name,
            detail: "Remove \(removable.name)",
            confidence: .low,
            allergenFlags: []
        )
        let proposal = InstructionProposal(
            productID: "burger",
            productName: "Burger",
            instructions: [instruction],
            generatedAt: .now,
            isDeterministic: false
        )

        let validator = InstructionValidator()
        let result = validator.validate(proposal: proposal, against: burger)

        #expect(result.isValid)
        #expect(result.warnings.contains { $0.contains("low confidence") })
    }
}

struct AllergenDatabaseTests {

    @Test func knownAllergensDetected() {
        #expect(AllergenDatabase.allergens(for: "Cheddar Cheese").contains("dairy"))
        #expect(AllergenDatabase.allergens(for: "peanut butter").contains("peanut"))
        #expect(AllergenDatabase.allergens(for: "shrimp tempura").contains("shellfish"))
    }

    @Test func unknownIngredientsReturnEmpty() {
        #expect(AllergenDatabase.allergens(for: "tomato").isEmpty)
        #expect(AllergenDatabase.allergens(for: "lettuce").isEmpty)
    }
}
