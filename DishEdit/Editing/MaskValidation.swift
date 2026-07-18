import Foundation

nonisolated struct MaskValidationPolicy: Codable, Equatable, Sendable {
    let minimumInsideFraction: Double
    let minimumCoverage: Double
    let minimumAreaRatio: Double
    let maximumAreaRatio: Double

    static let stageDefault = MaskValidationPolicy(
        minimumInsideFraction: 0.82,
        minimumCoverage: 0.65,
        minimumAreaRatio: 0.35,
        maximumAreaRatio: 1.60
    )
}

nonisolated struct MaskMetrics: Equatable, Sendable {
    let containsSeed: Bool
    let insideAuthorFraction: Double
    let authorCoverage: Double
    let areaRatio: Double
    let touchesExcludedRegion: Bool
}

nonisolated enum MaskValidator {
    static func accepts(_ metrics: MaskMetrics, policy: MaskValidationPolicy = .stageDefault) -> Bool {
        metrics.containsSeed
            && metrics.insideAuthorFraction >= policy.minimumInsideFraction
            && metrics.authorCoverage >= policy.minimumCoverage
            && metrics.areaRatio >= policy.minimumAreaRatio
            && metrics.areaRatio <= policy.maximumAreaRatio
            && !metrics.touchesExcludedRegion
    }
}

actor RevisionGate {
    private var current: UInt64 = 0

    func begin(revision: UInt64) { current = revision }
    func accepts(revision: UInt64) -> Bool { revision == current }
    func invalidate() { current &+= 1 }
}
