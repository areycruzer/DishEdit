import Foundation
import FoundationModels

@MainActor
struct InstructionGenerator {
    static func generate(
        dishName: String,
        modifiers: [ModifierDefinition]
    ) async -> String? {
        guard !modifiers.isEmpty else { return nil }

        let removals = modifiers.filter { $0.kind == .removal }.map(\.name)
        let additions = modifiers.filter { $0.kind == .addition }.map(\.name)

        var parts: [String] = []
        if !removals.isEmpty {
            parts.append("Removed: \(removals.joined(separator: ", "))")
        }
        if !additions.isEmpty {
            parts.append("Added: \(additions.joined(separator: ", "))")
        }
        let editSummary = parts.joined(separator: ". ")

        let prompt = """
        A customer customized their \(dishName) order with these edits: \(editSummary).
        Write a short, natural kitchen instruction (1-2 sentences max) that a restaurant would understand. \
        Use casual phrasing like "no tomato, extra cheese on top" — not formal sentences. \
        Only mention what changed, not the base dish ingredients.
        """

        do {
            let session = LanguageModelSession(
                instructions: "You are a helpful assistant that converts food customization edits into brief kitchen instructions. Keep it under 20 words."
            )
            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? fallbackInstruction(removals: removals, additions: additions) : text
        } catch {
            return fallbackInstruction(removals: removals, additions: additions)
        }
    }

    private static func fallbackInstruction(removals: [String], additions: [String]) -> String {
        var parts: [String] = []
        for r in removals { parts.append("no \(r.lowercased())") }
        for a in additions { parts.append("add \(a.lowercased())") }
        return parts.joined(separator: ", ")
    }
}
