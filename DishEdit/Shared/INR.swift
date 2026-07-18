import Foundation

// MARK: - Indian Rupee Formatting

nonisolated enum INR {
    static func format(_ paise: Int) -> String {
        "₹\(paise / 100)"
    }

    static func formatDelta(_ paise: Int) -> String {
        if paise == 0 { return "Included" }
        return "+₹\(paise / 100)"
    }
}
