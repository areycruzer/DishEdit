import CoreGraphics
import Vision

nonisolated enum MaskSource: String, Sendable {
    case liveVision = "LIVE VISION"
    case catalog = "CATALOG MASK"
}

nonisolated struct MaskResult: @unchecked Sendable {
    let image: CGImage
    let source: MaskSource
    let durationMilliseconds: Int
}

protocol IngredientMasking: Sendable {
    func prepare() async throws
    func mask(
        image: CGImage,
        seed: NormalizedPoint,
        authorMask: CGImage
    ) async throws -> MaskResult
}

nonisolated enum IngredientMaskError: Error, Equatable, Sendable {
    case noMask
    case unavailable
}

/// iOS 27's public point-seeded segmentation request. The caller resolves the
/// ingredient from catalog metadata before invoking this visual-only service.
actor VisionIngredientMasker: IngredientMasking {
    private var prepared = false

    func prepare() async throws {
        let seed = Vision.NormalizedPoint(x: 0.5, y: 0.5)
        let request = GenerateIterativeSegmentationRequest(seedPoint: seed)
        request.qualityLevel = .balanced
        guard await request.assetStatus == .ready else { throw IngredientMaskError.unavailable }
        prepared = true
    }

    func mask(
        image: CGImage,
        seed: NormalizedPoint,
        authorMask: CGImage
    ) async throws -> MaskResult {
        if !prepared { try await prepare() }
        let clock = ContinuousClock()
        let start = clock.now
        // UI coordinates use a top-left origin; Vision normalized coordinates use bottom-left.
        let visionSeed = Vision.NormalizedPoint(x: seed.x, y: 1 - seed.y)
        let request = GenerateIterativeSegmentationRequest(seedPoint: visionSeed)
        request.qualityLevel = .balanced
        let handler = ImageRequestHandler(image, orientation: .up)
        guard let observation = try await handler.perform(request) else {
            throw IngredientMaskError.noMask
        }
        let result = try observation.cgImage
        let elapsed = start.duration(to: clock.now).components
        let milliseconds = Int(elapsed.seconds * 1_000 + elapsed.attoseconds / 1_000_000_000_000_000)
        return MaskResult(image: result, source: .liveVision, durationMilliseconds: milliseconds)
    }
}

/// Deliberate presentation-safe implementation used whenever live segmentation is
/// unavailable or has not passed the per-dish overlap checks.
actor CatalogIngredientMasker: IngredientMasking {
    func prepare() async throws {}

    func mask(
        image: CGImage,
        seed: NormalizedPoint,
        authorMask: CGImage
    ) async throws -> MaskResult {
        MaskResult(image: authorMask, source: .catalog, durationMilliseconds: 0)
    }
}
