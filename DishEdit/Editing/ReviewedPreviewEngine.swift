import Foundation
import CoreGraphics

// MARK: - Visual Edit Engine Protocol

protocol VisualEditEngine: Sendable {
    func previewImage(for request: PreviewRequest) async -> PreviewResult
}

nonisolated struct PreviewRequest: Sendable {
    let product: ProductDefinition
    let removedIngredientIDs: Set<String>
    let addedIngredientIDs: Set<String>
    let revision: UInt64

    var visualStateKey: String {
        let hasRemovals = !removedIngredientIDs.isEmpty
        let hasAdditions = !addedIngredientIDs.isEmpty

        return switch (hasRemovals, hasAdditions) {
        case (false, false): "base"
        case (true, false): "removed"
        case (false, true): "added"
        case (true, true): "removed+added"
        }
    }

    var cacheKey: String {
        let removed = removedIngredientIDs.sorted().joined(separator: ",")
        let added = addedIngredientIDs.sorted().joined(separator: ",")
        return "\(product.id)|r:\(removed)|a:\(added)"
    }
}

nonisolated enum PreviewResult: Sendable {
    case reviewed(assetName: String)
    case generated(image: CGImage, cacheKey: String)
    case unavailable
}

// MARK: - Reviewed Preview Engine

struct ReviewedPreviewEngine: VisualEditEngine {
    func previewImage(for request: PreviewRequest) async -> PreviewResult {
        let stateKey = request.visualStateKey
        if stateKey == "base" {
            return .reviewed(assetName: request.product.assembledAssetName)
        }
        guard let assetName = request.product.reviewedPreviewAsset(for: stateKey) else {
            return .unavailable
        }
        return .reviewed(assetName: assetName)
    }
}

// MARK: - Generated Image Cache

actor GeneratedImageCache {
    private var entries: [String: CacheEntry] = [:]
    private let maxEntries: Int

    init(maxEntries: Int = 20) {
        self.maxEntries = maxEntries
    }

    struct CacheEntry: Sendable {
        let image: CGImage
        let timestamp: Date
        let revision: UInt64
    }

    func get(key: String) -> CGImage? {
        entries[key]?.image
    }

    func set(key: String, image: CGImage, revision: UInt64) {
        if entries.count >= maxEntries {
            evictOldest()
        }
        entries[key] = CacheEntry(image: image, timestamp: .now, revision: revision)
    }

    func invalidate(key: String) {
        entries.removeValue(forKey: key)
    }

    func invalidateAll() {
        entries.removeAll()
    }

    var count: Int { entries.count }

    private func evictOldest() {
        guard let oldest = entries.min(by: { $0.value.timestamp < $1.value.timestamp }) else { return }
        entries.removeValue(forKey: oldest.key)
    }
}

// MARK: - Preview Engine Selector

actor PreviewEngineSelector {
    private let reviewedEngine: ReviewedPreviewEngine
    private let cache: GeneratedImageCache

    init(cache: GeneratedImageCache = .init()) {
        self.reviewedEngine = ReviewedPreviewEngine()
        self.cache = cache
    }

    func preview(for request: PreviewRequest) async -> PreviewResult {
        if let cached = await cache.get(key: request.cacheKey) {
            return .generated(image: cached, cacheKey: request.cacheKey)
        }
        return await reviewedEngine.previewImage(for: request)
    }

    func cacheGenerated(image: CGImage, request: PreviewRequest) async {
        await cache.set(key: request.cacheKey, image: image, revision: request.revision)
    }
}

// MARK: - ProductDefinition Preview Extension

extension ProductDefinition {
    nonisolated func reviewedPreviewAsset(for stateKey: String) -> String? {
        let removable = ingredients.first(where: \.canRemove)
        let addable = ingredients.first(where: { $0.canAdd && !$0.defaultPresence })

        switch stateKey {
        case "removed":
            guard let ingredient = removable else { return nil }
            let suffix = ingredient.id.components(separatedBy: ".").last ?? ingredient.id
            return "\(id)_no_\(suffix)"
        case "added":
            guard let ingredient = addable else { return nil }
            let suffix = ingredient.id.components(separatedBy: ".").last ?? ingredient.id
            return "\(id)_with_\(suffix)"
        case "removed+added":
            guard let rem = removable, let add = addable else { return nil }
            let remSuffix = rem.id.components(separatedBy: ".").last ?? rem.id
            let addSuffix = add.id.components(separatedBy: ".").last ?? add.id
            return "\(id)_no_\(remSuffix)_with_\(addSuffix)"
        default:
            return nil
        }
    }
}
