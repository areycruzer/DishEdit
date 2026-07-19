import Foundation
import CoreGraphics

// MARK: - Generation Engine Mode

nonisolated enum GenerationEngineMode: String, Codable, Sendable, CaseIterable {
    case reviewed = "Reviewed Preview"
    case coreAI = "Core AI"
    case remote = "Remote"
    case imagePlayground = "Image Playground"
}

// MARK: - Generation Preference

nonisolated enum VisualGenerationPreference: String, Codable, Sendable, CaseIterable {
    case automatic = "Automatic"
    case reviewedOnly = "Reviewed Only"
    case coreAI = "Prefer Core AI"
    case remote = "Prefer Remote"
    case stageSafe = "Stage Safe"
}

// MARK: - Engine Availability

nonisolated enum EngineAvailability: String, Sendable {
    case available = "Available"
    case unavailable = "Unavailable"
    case unverified = "Unverified"
    case qualifiedOnDevice = "Qualified on this device"
}

// MARK: - Engine Selection Result

nonisolated struct EngineSelection: Sendable {
    let mode: GenerationEngineMode
    let fallbackReason: String?

    static func direct(_ mode: GenerationEngineMode) -> EngineSelection {
        EngineSelection(mode: mode, fallbackReason: nil)
    }

    static func fallback(to mode: GenerationEngineMode, reason: String) -> EngineSelection {
        EngineSelection(mode: mode, fallbackReason: reason)
    }
}

// MARK: - Visual Edit Request

nonisolated struct VisualEditRequest: Sendable {
    let productID: String
    let removedIngredientIDs: Set<String>
    let addedIngredientIDs: Set<String>
    let revision: UInt64
    let sourceImageName: String?
    let maskImageName: String?
}

// MARK: - Visual Edit Result

nonisolated enum VisualEditResult: Sendable {
    case reviewed(assetName: String)
    case generated(image: CGImage, engine: GenerationEngineMode, durationMs: Int)
    case unavailable(reason: String)
}
