import Foundation

// MARK: - Feature Availability

nonisolated enum FeatureAvailability {
    static var isFoundationModelsAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    static var isImagePlaygroundAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    static var isCoreMLAvailable: Bool {
        true
    }
}
