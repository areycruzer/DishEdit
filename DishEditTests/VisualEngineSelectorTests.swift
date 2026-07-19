import Testing
@testable import DishEdit

@Suite("Visual Engine Selector Tests")
struct VisualEngineSelectorTests {

    // MARK: - Stage Safe / Reviewed Only

    @Test func stageSafeAlwaysSelectsReviewed() async {
        let selector = VisualEngineSelector(
            preference: .stageSafe,
            coreAIAvailability: { .available },
            remoteAvailability: { .available }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == nil)
    }

    @Test func reviewedOnlyAlwaysSelectsReviewed() async {
        let selector = VisualEngineSelector(
            preference: .reviewedOnly,
            coreAIAvailability: { .qualifiedOnDevice },
            remoteAvailability: { .available }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == nil)
    }

    // MARK: - Automatic Mode

    @Test func automaticSelectsCoreAIWhenAvailable() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .available },
            remoteAvailability: { .available }
        )
        let selection = await selector.select()
        #expect(selection.mode == .coreAI)
        #expect(selection.fallbackReason == nil)
    }

    @Test func automaticSelectsCoreAIWhenQualified() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .qualifiedOnDevice },
            remoteAvailability: { .unavailable }
        )
        let selection = await selector.select()
        #expect(selection.mode == .coreAI)
    }

    @Test func automaticFallsToRemoteWhenCoreAIUnavailable() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .unavailable },
            remoteAvailability: { .available }
        )
        let selection = await selector.select()
        #expect(selection.mode == .remote)
        #expect(selection.fallbackReason == nil)
    }

    @Test func automaticFallsToReviewedWhenBothUnavailable() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .unavailable },
            remoteAvailability: { .unavailable }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == nil)
    }

    // MARK: - Explicit Core AI

    @Test func explicitCoreAISelectsWhenAvailable() async {
        let selector = VisualEngineSelector(
            preference: .coreAI,
            coreAIAvailability: { .qualifiedOnDevice }
        )
        let selection = await selector.select()
        #expect(selection.mode == .coreAI)
        #expect(selection.fallbackReason == nil)
    }

    @Test func explicitCoreAIFallsToReviewedWithReason() async {
        let selector = VisualEngineSelector(
            preference: .coreAI,
            coreAIAvailability: { .unavailable }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == "Core AI Unavailable")
    }

    @Test func explicitCoreAIFallsWhenUnverified() async {
        let selector = VisualEngineSelector(
            preference: .coreAI,
            coreAIAvailability: { .unverified }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == "Core AI Unverified")
    }

    // MARK: - Explicit Remote

    @Test func explicitRemoteSelectsWhenAvailable() async {
        let selector = VisualEngineSelector(
            preference: .remote,
            remoteAvailability: { .available }
        )
        let selection = await selector.select()
        #expect(selection.mode == .remote)
        #expect(selection.fallbackReason == nil)
    }

    @Test func explicitRemoteFallsToReviewedWithReason() async {
        let selector = VisualEngineSelector(
            preference: .remote,
            remoteAvailability: { .unavailable }
        )
        let selection = await selector.select()
        #expect(selection.mode == .reviewed)
        #expect(selection.fallbackReason == "Remote Unavailable")
    }

    // MARK: - Preference Updates

    @Test func updatePreferenceChangesSelection() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .available }
        )
        let initial = await selector.select()
        #expect(initial.mode == .coreAI)

        await selector.updatePreference(.stageSafe)
        let updated = await selector.select()
        #expect(updated.mode == .reviewed)
    }

    // MARK: - All Availability

    @Test func allAvailabilityReturnsAllEngines() async {
        let selector = VisualEngineSelector(
            preference: .automatic,
            coreAIAvailability: { .qualifiedOnDevice },
            remoteAvailability: { .unavailable },
            imagePlaygroundAvailability: { .available }
        )
        let all = await selector.allAvailability()
        #expect(all[.reviewed] == .available)
        #expect(all[.coreAI] == .qualifiedOnDevice)
        #expect(all[.remote] == .unavailable)
        #expect(all[.imagePlayground] == .available)
    }
}
