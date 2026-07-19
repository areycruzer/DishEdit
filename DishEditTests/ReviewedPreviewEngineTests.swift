import CoreGraphics
import Foundation
import Testing
@testable import DishEdit

struct ReviewedPreviewEngineTests {

    private let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!

    @Test func baseStateReturnsAssembledAsset() async {
        let engine = ReviewedPreviewEngine()
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: [],
            addedIngredientIDs: [],
            revision: 0
        )

        let result = await engine.previewImage(for: request)
        guard case .reviewed(let assetName) = result else {
            Issue.record("Expected .reviewed, got \(result)")
            return
        }
        #expect(assetName == burger.assembledAssetName)
    }

    @Test func removalStateReturnsReviewedAsset() async {
        let engine = ReviewedPreviewEngine()
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: ["burger.tomato"],
            addedIngredientIDs: [],
            revision: 1
        )

        let result = await engine.previewImage(for: request)
        guard case .reviewed(let assetName) = result else {
            Issue.record("Expected .reviewed, got \(result)")
            return
        }
        #expect(assetName == "burger_no_tomato")
    }

    @Test func additionStateReturnsReviewedAsset() async {
        let engine = ReviewedPreviewEngine()
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: [],
            addedIngredientIDs: ["burger.cheddar"],
            revision: 1
        )

        let result = await engine.previewImage(for: request)
        guard case .reviewed(let assetName) = result else {
            Issue.record("Expected .reviewed, got \(result)")
            return
        }
        #expect(assetName == "burger_with_cheddar")
    }

    @Test func combinedStateReturnsReviewedAsset() async {
        let engine = ReviewedPreviewEngine()
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: ["burger.tomato"],
            addedIngredientIDs: ["burger.cheddar"],
            revision: 2
        )

        let result = await engine.previewImage(for: request)
        guard case .reviewed(let assetName) = result else {
            Issue.record("Expected .reviewed, got \(result)")
            return
        }
        #expect(assetName == "burger_no_tomato_with_cheddar")
    }

    @Test func visualStateKeyMapsCorrectly() {
        let base = PreviewRequest(product: burger, removedIngredientIDs: [], addedIngredientIDs: [], revision: 0)
        #expect(base.visualStateKey == "base")

        let removed = PreviewRequest(product: burger, removedIngredientIDs: ["x"], addedIngredientIDs: [], revision: 0)
        #expect(removed.visualStateKey == "removed")

        let added = PreviewRequest(product: burger, removedIngredientIDs: [], addedIngredientIDs: ["y"], revision: 0)
        #expect(added.visualStateKey == "added")

        let both = PreviewRequest(product: burger, removedIngredientIDs: ["x"], addedIngredientIDs: ["y"], revision: 0)
        #expect(both.visualStateKey == "removed+added")
    }

    @Test func cacheKeyIsDeterministic() {
        let r1 = PreviewRequest(product: burger, removedIngredientIDs: ["b", "a"], addedIngredientIDs: ["d", "c"], revision: 0)
        let r2 = PreviewRequest(product: burger, removedIngredientIDs: ["a", "b"], addedIngredientIDs: ["c", "d"], revision: 0)
        #expect(r1.cacheKey == r2.cacheKey)
    }
}

struct GeneratedImageCacheTests {

    @Test func storesAndRetrievesImages() async {
        let cache = GeneratedImageCache(maxEntries: 5)
        let image = createTestImage()

        await cache.set(key: "test-key", image: image, revision: 1)
        let retrieved = await cache.get(key: "test-key")

        #expect(retrieved != nil)
        #expect(retrieved?.width == image.width)
    }

    @Test func evictsOldestWhenFull() async {
        let cache = GeneratedImageCache(maxEntries: 2)
        let img = createTestImage()

        await cache.set(key: "first", image: img, revision: 1)
        await cache.set(key: "second", image: img, revision: 2)
        await cache.set(key: "third", image: img, revision: 3)

        let count = await cache.count
        #expect(count == 2)

        let evicted = await cache.get(key: "first")
        #expect(evicted == nil)
    }

    @Test func invalidateRemovesEntry() async {
        let cache = GeneratedImageCache(maxEntries: 5)
        let img = createTestImage()

        await cache.set(key: "key", image: img, revision: 1)
        await cache.invalidate(key: "key")

        let result = await cache.get(key: "key")
        #expect(result == nil)
    }

    private func createTestImage() -> CGImage {
        let size = 4
        let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}

struct PreviewEngineSelectorTests {

    private let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!

    @Test func returnsCachedImageWhenAvailable() async {
        let cache = GeneratedImageCache()
        let selector = PreviewEngineSelector(cache: cache)
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: ["burger.tomato"],
            addedIngredientIDs: [],
            revision: 1
        )

        let testImage = createTestImage()
        await selector.cacheGenerated(image: testImage, request: request)

        let result = await selector.preview(for: request)
        guard case .generated(let image, _) = result else {
            Issue.record("Expected .generated, got \(result)")
            return
        }
        #expect(image.width == testImage.width)
    }

    @Test func fallsBackToReviewedWhenNoCacheHit() async {
        let selector = PreviewEngineSelector()
        let request = PreviewRequest(
            product: burger,
            removedIngredientIDs: ["burger.tomato"],
            addedIngredientIDs: [],
            revision: 1
        )

        let result = await selector.preview(for: request)
        guard case .reviewed(let assetName) = result else {
            Issue.record("Expected .reviewed, got \(result)")
            return
        }
        #expect(assetName == "burger_no_tomato")
    }

    private func createTestImage() -> CGImage {
        let size = 4
        let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}
