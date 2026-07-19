import Testing
@testable import DishEdit

@Suite("Core AI Visual Edit Engine Tests")
struct CoreAIVisualEditEngineTests {

    @Test func initialAvailabilityIsUnverified() async {
        let engine = CoreAIVisualEditEngine()
        let availability = await engine.availability()
        #expect(availability == .unverified)
    }

    @Test func engineModeIsCoreAI() async {
        let engine = CoreAIVisualEditEngine()
        #expect(engine.engineMode == .coreAI)
    }

    @Test func generateReturnsUnavailableWhenNotValidated() async throws {
        let engine = CoreAIVisualEditEngine()
        let request = VisualEditRequest(
            productID: "burger",
            removedIngredientIDs: ["burger.tomato"],
            addedIngredientIDs: [],
            revision: 1,
            sourceImageName: nil,
            maskImageName: nil
        )
        let result = try await engine.generate(request: request)
        if case .unavailable(let reason) = result {
            #expect(reason.contains("not loaded"))
        } else {
            Issue.record("Expected unavailable result")
        }
    }

    @Test func validateWithLowMemoryReturnsFalse() async {
        let engine = CoreAIVisualEditEngine()
        let passed = await engine.validate(memoryBudgetMB: Int.max)
        #expect(passed == false)
    }

    @Test func afterFailedValidationAvailabilityIsUnavailable() async {
        let engine = CoreAIVisualEditEngine()
        _ = await engine.validate(memoryBudgetMB: Int.max)
        let availability = await engine.availability()
        #expect(availability == .unavailable)
    }
}
