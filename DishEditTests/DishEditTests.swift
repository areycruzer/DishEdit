//
//  DishEditTests.swift
//  DishEditTests
//
//  Created by Swyam Sharma on 18/07/26.
//

import CoreGraphics
import Foundation
import Testing
@testable import DishEdit

struct DishEditTests {

    @Test func catalogContainsThreeCuratedDishes() {
        let catalog = DishCatalog.preview

        #expect(catalog.dishes.map(\.id) == ["burger", "pizza", "waffle"])
        #expect(catalog.dishes.allSatisfy { $0.modifiers.count == 2 })
    }

    @Test func removalAndAdditionProduceDeterministicOrderState() throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        var state = DishEditState(dish: burger)

        state.apply(modifierID: "burger.remove.tomato")
        state.apply(modifierID: "burger.add.cheese")

        #expect(state.activeModifierIDs == ["burger.remove.tomato", "burger.add.cheese"])
        #expect(state.visualStateKey == "removed+added")
        #expect(state.totalPricePaise == 28_900)
        #expect(state.revision == 2)
    }

    @Test func undoRestoresImageAndCommerceStateTogether() throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        var state = DishEditState(dish: burger)

        state.apply(modifierID: "burger.remove.tomato")
        state.apply(modifierID: "burger.add.cheese")
        state.undo()

        #expect(state.activeModifierIDs == ["burger.remove.tomato"])
        #expect(state.visualStateKey == "removed")
        #expect(state.totalPricePaise == 24_900)
        #expect(state.revision == 3)
    }

    @Test func unsupportedModifierNeverChangesState() throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        var state = DishEditState(dish: burger)

        state.apply(modifierID: "invented.by.ai")

        #expect(state.activeModifierIDs.isEmpty)
        #expect(state.visualStateKey == "base")
        #expect(state.totalPricePaise == 24_900)
    }

    @Test func aspectFitMappingUsesOnlyVisibleImagePixels() {
        let viewport = ImageViewport(
            containerWidth: 390,
            containerHeight: 520,
            imageWidth: 1_536,
            imageHeight: 1_536
        )

        #expect(viewport.imageFrame == ImageFrame(x: 0, y: 65, width: 390, height: 390))
        #expect(viewport.normalizedPoint(screenX: 195, screenY: 260) == NormalizedPoint(x: 0.5, y: 0.5))
        #expect(viewport.normalizedPoint(screenX: 195, screenY: 20) == nil)
    }

    @Test func magneticAnchorAcceptsOnlyMerchantApprovedPlacement() throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        let cheese = try #require(burger.modifier(id: "burger.add.cheese"))

        #expect(ModifierResolver.acceptsDrop(at: NormalizedPoint(x: 0.50, y: 0.62), modifier: cheese))
        #expect(!ModifierResolver.acceptsDrop(at: NormalizedPoint(x: 0.92, y: 0.15), modifier: cheese))
    }

    @Test func unsafeLiveMaskFallsBackBeforeEditingPixels() {
        let safe = MaskMetrics(
            containsSeed: true,
            insideAuthorFraction: 0.91,
            authorCoverage: 0.78,
            areaRatio: 1.08,
            touchesExcludedRegion: false
        )
        let spill = MaskMetrics(
            containsSeed: true,
            insideAuthorFraction: 0.62,
            authorCoverage: 0.90,
            areaRatio: 1.10,
            touchesExcludedRegion: true
        )

        #expect(MaskValidator.accepts(safe))
        #expect(!MaskValidator.accepts(spill))
    }

    @Test @MainActor func catalogEngineIsGuaranteedWhenLiveModelIsUnvalidated() async throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        let modifier = try #require(burger.modifier(id: "burger.remove.tomato"))
        let request = ImageEditRequest(
            dish: burger,
            modifier: modifier,
            destinationStateKey: "removed",
            revision: 1
        )
        let selector = EditEngineSelector(liveEnabled: true, liveTransitionKeys: ["burger:removed"])

        let engine = await selector.engine(for: request)
        let result = try await engine.edit(request)

        #expect(engine.kind == .catalogPatch)
        #expect(result.assetName == "burger_no_tomato")
    }

    @Test func staleAsyncResultIsRejectedAfterUndo() async {
        let gate = RevisionGate()
        await gate.begin(revision: 7)
        #expect(await gate.accepts(revision: 7))

        await gate.invalidate()

        #expect(!(await gate.accepts(revision: 7)))
    }

    @Test func resetAndRedoRestoreExactStructuredState() throws {
        let burger = try #require(DishCatalog.preview.dish(id: "burger"))
        var state = DishEditState(dish: burger)
        state.apply(modifierID: "burger.remove.tomato")
        state.apply(modifierID: "burger.add.cheese")

        state.reset()
        #expect(state.activeModifierIDs.isEmpty)
        #expect(state.visualAssetName == "burger_base")
        #expect(state.totalPricePaise == 24_900)

        state.undo()
        #expect(state.activeModifierIDs == ["burger.remove.tomato", "burger.add.cheese"])
        state.undo()
        #expect(state.activeModifierIDs == ["burger.remove.tomato"])
        state.redo()
        #expect(state.activeModifierIDs == ["burger.remove.tomato", "burger.add.cheese"])
    }

    @Test func cacheKeyIsStableAcrossSetIterationOrder() {
        let first = ImageEditCacheKey(
            dishID: "burger",
            modifierIDs: ["burger.add.cheese", "burger.remove.tomato"],
            seed: 42,
            modelVersion: "catalog-v1"
        )
        let second = ImageEditCacheKey(
            dishID: "burger",
            modifierIDs: ["burger.remove.tomato", "burger.add.cheese"],
            seed: 42,
            modelVersion: "catalog-v1"
        )

        #expect(first == second)
        #expect(first.storageKey == second.storageKey)
    }

    @Test func maskCompositeKeepsEveryOutsidePixelUnchanged() throws {
        let original = try solidImage(red: 255, green: 0, blue: 0, alpha: 255, width: 8, height: 8)
        let patch = try solidImage(red: 0, green: 0, blue: 255, alpha: 255, width: 8, height: 8)
        let mask = try rectangularMask(width: 8, height: 8, whiteRect: CGRect(x: 3, y: 3, width: 2, height: 2))

        let result = try ImageCompositor.blend(original: original, patch: patch, mask: mask)

        for y in 0 ..< 8 {
            for x in 0 ..< 8 {
                let isInsideMask = (3 ..< 5).contains(x) && (3 ..< 5).contains(y)
                let expected: [UInt8] = isInsideMask ? [0, 0, 255, 255] : [255, 0, 0, 255]
                #expect(try pixel(in: result, x: x, y: y) == expected)
            }
        }
    }

    @Test func authorMaskHitTestingRejectsNearbyNonIngredientPixels() throws {
        let mask = try rectangularMask(
            width: 100,
            height: 100,
            whiteRect: CGRect(x: 40, y: 40, width: 20, height: 20)
        )

        #expect(AuthorMaskHitTester.contains(NormalizedPoint(x: 0.50, y: 0.50), in: mask))
        #expect(!AuthorMaskHitTester.contains(NormalizedPoint(x: 0.25, y: 0.50), in: mask))
    }

    @Test func interactionTransformInvertsCenterBasedZoomAndPan() {
        let transform = ImageInteractionTransform(
            containerWidth: 400,
            containerHeight: 600,
            zoom: 1.5,
            panX: 24,
            panY: -18
        )
        let source = CGPoint(x: 110, y: 230)
        let projected = transform.project(source)
        let restored = transform.unproject(projected)

        #expect(abs(restored.x - source.x) < 0.001)
        #expect(abs(restored.y - source.y) < 0.001)
    }

    @Test func everyCatalogImageAndMaskResourceIsBundled() {
        for dish in DishCatalog.preview.dishes {
            #expect(BundledResource.cgImage(named: dish.baseImageAsset) != nil)
            for state in dish.fallbackStates.values {
                #expect(BundledResource.cgImage(named: state.assetName) != nil)
            }
            for modifier in dish.modifiers {
                #expect(BundledResource.cgImage(named: modifier.authorMaskAsset) != nil)
                if let trayAsset = modifier.trayAsset {
                    #expect(BundledResource.cgImage(named: trayAsset) != nil)
                }
            }
        }
    }

    @Test func curatedAuthorMasksMatchKnownIngredientAndBackgroundPoints() throws {
        let tomato = try #require(BundledResource.cgImage(named: "burger_tomato_mask"))
        let olives = try #require(BundledResource.cgImage(named: "pizza_olives_mask"))
        let strawberries = try #require(BundledResource.cgImage(named: "waffle_strawberries_mask"))

        #expect(AuthorMaskHitTester.contains(NormalizedPoint(x: 0.50, y: 0.58), in: tomato))
        #expect(!AuthorMaskHitTester.contains(NormalizedPoint(x: 0.50, y: 0.40), in: tomato))
        #expect(AuthorMaskHitTester.contains(NormalizedPoint(x: 0.36, y: 0.23), in: olives))
        #expect(!AuthorMaskHitTester.contains(NormalizedPoint(x: 0.50, y: 0.50), in: olives))
        #expect(AuthorMaskHitTester.contains(NormalizedPoint(x: 0.57, y: 0.26), in: strawberries))
        #expect(!AuthorMaskHitTester.contains(NormalizedPoint(x: 0.78, y: 0.55), in: strawberries))
    }

    @Test func reconstructionTimelineClampsProgressAndAdvancesThroughFourPhases() {
        let timeline = ReconstructionTimeline(duration: 5.4)

        #expect(timeline.progress(at: -1) == 0)
        #expect(timeline.progress(at: 8) == 1)
        #expect(timeline.phase(at: 0.2) == .understanding)
        #expect(timeline.phase(at: 1.8) == .reconstructing)
        #expect(timeline.phase(at: 3.4) == .matchingLight)
        #expect(timeline.phase(at: 4.8) == .finalizing)
    }

    @Test @MainActor func commerceCommitsBeforeRevisionBoundVisualReconstructionCompletes() throws {
        let coordinator = DishEditCoordinator(reconstructionDuration: 5.4)
        let tomato = try #require(coordinator.dish.removalModifier)

        coordinator.toggleRemoval(tomato)

        #expect(coordinator.state.visualStateKey == "removed")
        #expect(coordinator.displayedVisualStateKey == "base")
        let reconstruction = try #require(coordinator.reconstruction)
        #expect(reconstruction.destinationStateKey == "removed")
        #expect(coordinator.completeReconstruction(revision: reconstruction.revision))
        #expect(coordinator.displayedVisualStateKey == "removed")
        #expect(coordinator.reconstruction == nil)
    }

    @Test @MainActor func staleReconstructionCannotOverwriteUndo() throws {
        let coordinator = DishEditCoordinator(reconstructionDuration: 5.4)
        let tomato = try #require(coordinator.dish.removalModifier)
        coordinator.toggleRemoval(tomato)
        let staleRevision = try #require(coordinator.reconstruction?.revision)

        coordinator.undo()

        #expect(!coordinator.completeReconstruction(revision: staleRevision))
        #expect(coordinator.state.visualStateKey == "base")
        #expect(coordinator.displayedVisualStateKey == "base")
    }

}

private enum TestImageError: Error {
    case context
    case image
    case bytes
}

private func solidImage(
    red: UInt8,
    green: UInt8,
    blue: UInt8,
    alpha: UInt8,
    width: Int,
    height: Int
) throws -> CGImage {
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    for index in stride(from: 0, to: bytes.count, by: 4) {
        bytes[index] = red
        bytes[index + 1] = green
        bytes[index + 2] = blue
        bytes[index + 3] = alpha
    }
    guard let provider = CGDataProvider(data: Data(bytes) as CFData),
          let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
          ) else { throw TestImageError.image }
    return image
}

private func rectangularMask(width: Int, height: Int, whiteRect: CGRect) throws -> CGImage {
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    ) else { throw TestImageError.context }
    context.setFillColor(gray: 0, alpha: 1)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    context.setFillColor(gray: 1, alpha: 1)
    context.fill(whiteRect)
    guard let image = context.makeImage() else { throw TestImageError.image }
    return image
}

private func pixel(in image: CGImage, x: Int, y: Int) throws -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
    guard let context = CGContext(
        data: &bytes,
        width: image.width,
        height: image.height,
        bitsPerComponent: 8,
        bytesPerRow: image.width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { throw TestImageError.context }
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    let offset = (y * image.width + x) * 4
    guard offset + 3 < bytes.count else { throw TestImageError.bytes }
    return Array(bytes[offset ... offset + 3])
}
