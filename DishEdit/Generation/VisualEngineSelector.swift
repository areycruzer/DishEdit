import Foundation

// MARK: - Visual Engine Protocol

protocol VisualEditEngineProtocol: Sendable {
    var engineMode: GenerationEngineMode { get }
    func availability() async -> EngineAvailability
    func generate(request: VisualEditRequest) async throws -> VisualEditResult
}

// MARK: - Visual Engine Selector

actor VisualEngineSelector {
    private var preference: VisualGenerationPreference
    private let coreAIAvailability: () async -> EngineAvailability
    private let remoteAvailability: () async -> EngineAvailability
    private let imagePlaygroundAvailability: () async -> EngineAvailability

    init(
        preference: VisualGenerationPreference = .automatic,
        coreAIAvailability: @escaping @Sendable () async -> EngineAvailability = { .unavailable },
        remoteAvailability: @escaping @Sendable () async -> EngineAvailability = { .unavailable },
        imagePlaygroundAvailability: @escaping @Sendable () async -> EngineAvailability = { .unavailable }
    ) {
        self.preference = preference
        self.coreAIAvailability = coreAIAvailability
        self.remoteAvailability = remoteAvailability
        self.imagePlaygroundAvailability = imagePlaygroundAvailability
    }

    func updatePreference(_ newPreference: VisualGenerationPreference) {
        preference = newPreference
    }

    func currentPreference() -> VisualGenerationPreference {
        preference
    }

    func select() async -> EngineSelection {
        switch preference {
        case .stageSafe, .reviewedOnly:
            return .direct(.reviewed)

        case .automatic:
            return await selectAutomatic()

        case .coreAI:
            let availability = await coreAIAvailability()
            if availability == .available || availability == .qualifiedOnDevice {
                return .direct(.coreAI)
            }
            return .fallback(to: .reviewed, reason: "Core AI \(availability.rawValue)")

        case .remote:
            let availability = await remoteAvailability()
            if availability == .available {
                return .direct(.remote)
            }
            return .fallback(to: .reviewed, reason: "Remote \(availability.rawValue)")
        }
    }

    private func selectAutomatic() async -> EngineSelection {
        let coreAI = await coreAIAvailability()
        if coreAI == .available || coreAI == .qualifiedOnDevice {
            return .direct(.coreAI)
        }

        let remote = await remoteAvailability()
        if remote == .available {
            return .direct(.remote)
        }

        return .direct(.reviewed)
    }

    func allAvailability() async -> [GenerationEngineMode: EngineAvailability] {
        let coreAI = await coreAIAvailability()
        let remote = await remoteAvailability()
        let playground = await imagePlaygroundAvailability()

        return [
            .reviewed: .available,
            .coreAI: coreAI,
            .remote: remote,
            .imagePlayground: playground
        ]
    }
}
