import CoreHaptics
import UIKit

nonisolated enum ReconstructionHapticMode: Equatable, Sendable {
    case continuousProcessing
    case selectionFallback

    static func preferred(supportsCoreHaptics: Bool) -> Self {
        supportsCoreHaptics ? .continuousProcessing : .selectionFallback
    }
}

@MainActor
final class ReconstructionHaptics {
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?

    func start(duration: TimeInterval) {
        stop()
        let supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard ReconstructionHapticMode.preferred(supportsCoreHaptics: supportsCoreHaptics) == .continuousProcessing else {
            HapticDirector.selection()
            return
        }

        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            let safeDuration = max(0.2, duration - 0.12)
            var events = [
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.12),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.08)
                    ],
                    relativeTime: 0,
                    duration: safeDuration
                )
            ]
            for relativeTime in [0.18, safeDuration * 0.31, safeDuration * 0.59, safeDuration * 0.84] {
                events.append(
                    CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.32),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.42)
                        ],
                        relativeTime: relativeTime
                    )
                )
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try engine.start()
            try player.start(atTime: CHHapticTimeImmediate)
            self.engine = engine
            self.player = player
        } catch {
            HapticDirector.selection()
        }
    }

    func complete() {
        stop()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func stop() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
        engine?.stop(completionHandler: nil)
        engine = nil
    }
}
