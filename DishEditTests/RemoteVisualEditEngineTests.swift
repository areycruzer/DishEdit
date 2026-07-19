import Testing
@testable import DishEdit

@Suite("Remote Visual Edit Engine Tests")
struct RemoteVisualEditEngineTests {

    @Test func engineModeIsRemote() async {
        let engine = RemoteVisualEditEngine()
        #expect(engine.engineMode == .remote)
    }

    @Test func unconfiguredEngineIsUnavailable() async {
        let engine = RemoteVisualEditEngine()
        let availability = await engine.availability()
        #expect(availability == .unavailable)
    }

    @Test func configuredEngineIsAvailable() async {
        let engine = RemoteVisualEditEngine(endpointURL: URL(string: "https://example.com/edit")!)
        let availability = await engine.availability()
        #expect(availability == .available)
    }

    @Test func generateWithNoConfigReturnsUnavailable() async throws {
        let engine = RemoteVisualEditEngine()
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
            #expect(reason.contains("not configured"))
        } else {
            Issue.record("Expected unavailable result")
        }
    }
}
