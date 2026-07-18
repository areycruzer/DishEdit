import Foundation

nonisolated enum ReconstructionPhase: String, CaseIterable, Equatable, Sendable {
    case understanding
    case reconstructing
    case matchingLight
    case finalizing

    var title: String {
        switch self {
        case .understanding: "Understanding selection"
        case .reconstructing: "Reconstructing texture"
        case .matchingLight: "Matching light & depth"
        case .finalizing: "Finalizing preview"
        }
    }
}

nonisolated struct ReconstructionTimeline: Equatable, Sendable {
    let duration: TimeInterval

    init(duration: TimeInterval = 5.4) {
        self.duration = max(0.1, duration)
    }

    func progress(at elapsed: TimeInterval) -> Double {
        min(1, max(0, elapsed / duration))
    }

    func phase(at elapsed: TimeInterval) -> ReconstructionPhase {
        switch progress(at: elapsed) {
        case ..<0.25: .understanding
        case ..<0.57: .reconstructing
        case ..<0.82: .matchingLight
        default: .finalizing
        }
    }
}

nonisolated struct ReconstructionSession: Identifiable, Equatable, Sendable {
    let dishID: String
    let revision: UInt64
    let sourceStateKey: VisualStateKey
    let destinationStateKey: VisualStateKey
    let modifierID: String
    let maskAssetName: String
    let startedAt: Date
    let timeline: ReconstructionTimeline

    var id: String { "\(dishID):\(revision)" }

    func elapsed(at date: Date) -> TimeInterval {
        max(0, date.timeIntervalSince(startedAt))
    }

    func progress(at date: Date) -> Double {
        timeline.progress(at: elapsed(at: date))
    }

    func phase(at date: Date) -> ReconstructionPhase {
        timeline.phase(at: elapsed(at: date))
    }
}
