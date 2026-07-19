import Foundation
import CoreGraphics

// MARK: - Core AI Visual Edit Engine

#if canImport(CoreML)
actor CoreAIVisualEditEngine: VisualEditEngineProtocol {
    nonisolated let engineMode: GenerationEngineMode = .coreAI

    private var isValidated: Bool = false
    private var modelLoaded: Bool = false

    func availability() async -> EngineAvailability {
        guard FeatureAvailability.isCoreMLAvailable else {
            return .unavailable
        }
        guard isValidated else {
            return .unverified
        }
        return modelLoaded ? .qualifiedOnDevice : .unavailable
    }

    func validate(memoryBudgetMB: Int = 2048, latencyThresholdMs: Int = 3000) async -> Bool {
        let deviceMemoryMB = ProcessInfo.processInfo.physicalMemory / (1024 * 1024)
        guard deviceMemoryMB >= memoryBudgetMB else {
            isValidated = true
            modelLoaded = false
            return false
        }
        isValidated = true
        modelLoaded = false
        return false
    }

    func generate(request: VisualEditRequest) async throws -> VisualEditResult {
        guard modelLoaded else {
            return .unavailable(reason: "Core AI model not loaded or validated")
        }
        return .unavailable(reason: "Core AI generation not yet implemented")
    }
}
#endif
