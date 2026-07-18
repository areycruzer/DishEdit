import Foundation

nonisolated enum EditEngineKind: String, Codable, Sendable {
    case liveLCM = "LIVE LCM"
    case catalogPatch = "CATALOG PATCH"
    case compositeOnly = "COMPOSITE ONLY"
}

nonisolated struct ImageEditRequest: Sendable {
    let dish: DishDefinition
    let modifier: ModifierDefinition
    let destinationStateKey: VisualStateKey
    let revision: UInt64
}

nonisolated struct ImageEditResult: Sendable {
    let assetName: String
    let engine: EditEngineKind
    let durationMilliseconds: Int
    let revision: UInt64
}

protocol ImageEditEngine: Sendable {
    nonisolated var kind: EditEngineKind { get }
    func prepare() async throws
    func edit(_ request: ImageEditRequest) async throws -> ImageEditResult
}

protocol EditEngineSelecting: Sendable {
    func engine(for request: ImageEditRequest) async -> any ImageEditEngine
}

nonisolated enum ImageEditError: Error, Equatable, Sendable {
    case modelUnavailable
    case unsupportedTransition
    case missingCatalogState
}

actor CatalogPatchEngine: ImageEditEngine {
    nonisolated let kind = EditEngineKind.catalogPatch

    func prepare() async throws {}

    func edit(_ request: ImageEditRequest) async throws -> ImageEditResult {
        guard let state = request.dish.fallbackStates[request.destinationStateKey] else {
            throw ImageEditError.missingCatalogState
        }
        return ImageEditResult(
            assetName: state.assetName,
            engine: kind,
            durationMilliseconds: 0,
            revision: request.revision
        )
    }
}

/// Kept behind the same production interface. It is deliberately unavailable until
/// a pinned model passes the physical iPhone 16 memory and latency gate.
actor LCMInpaintingEngine: ImageEditEngine {
    nonisolated let kind = EditEngineKind.liveLCM
    private let isDeviceValidated: Bool

    init(isDeviceValidated: Bool = false) {
        self.isDeviceValidated = isDeviceValidated
    }

    func prepare() async throws {
        guard isDeviceValidated else { throw ImageEditError.modelUnavailable }
    }

    func edit(_ request: ImageEditRequest) async throws -> ImageEditResult {
        throw ImageEditError.modelUnavailable
    }
}

actor CompositePreviewEngine: ImageEditEngine {
    nonisolated let kind = EditEngineKind.compositeOnly

    func prepare() async throws {}

    func edit(_ request: ImageEditRequest) async throws -> ImageEditResult {
        guard let state = request.dish.fallbackStates[request.destinationStateKey] else {
            throw ImageEditError.missingCatalogState
        }
        return ImageEditResult(
            assetName: state.assetName,
            engine: kind,
            durationMilliseconds: 0,
            revision: request.revision
        )
    }
}

actor EditEngineSelector: EditEngineSelecting {
    private let liveEngine: LCMInpaintingEngine
    private let catalogEngine: CatalogPatchEngine
    private let liveTransitionKeys: Set<String>
    private let liveEnabled: Bool

    init(
        liveEnabled: Bool,
        liveTransitionKeys: Set<String> = []
    ) {
        self.liveEnabled = liveEnabled
        self.liveTransitionKeys = liveTransitionKeys
        liveEngine = LCMInpaintingEngine()
        catalogEngine = CatalogPatchEngine()
    }

    func engine(for request: ImageEditRequest) async -> any ImageEditEngine {
        let transitionKey = "\(request.dish.id):\(request.destinationStateKey)"
        guard liveEnabled, liveTransitionKeys.contains(transitionKey) else {
            return catalogEngine
        }
        do {
            try await liveEngine.prepare()
            return liveEngine
        } catch {
            return catalogEngine
        }
    }
}
