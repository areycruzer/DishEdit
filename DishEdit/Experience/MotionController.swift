import CoreMotion
import Observation

@MainActor
@Observable
final class MotionController {
    private(set) var roll = 0.0
    private(set) var pitch = 0.0
    private let manager = CMMotionManager()
    private let alpha = 0.12

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            MainActor.assumeIsolated {
                guard let self, let attitude = motion?.attitude else { return }
                let nextRoll = max(-0.07, min(0.07, attitude.roll))
                let nextPitch = max(-0.07, min(0.07, attitude.pitch))
                self.roll += (nextRoll - self.roll) * self.alpha
                self.pitch += (nextPitch - self.pitch) * self.alpha
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
