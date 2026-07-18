import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import OSLog
import UIKit

nonisolated enum BundledResource {
    static func cgImage(named name: String, bundle: Bundle = .main) -> CGImage? {
        guard let url = bundle.url(forResource: name, withExtension: "png"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}

nonisolated enum AuthorMaskHitTester {
    static func contains(
        _ point: NormalizedPoint,
        in mask: CGImage,
        threshold: UInt8 = 128
    ) -> Bool {
        guard (0 ... 1).contains(point.x), (0 ... 1).contains(point.y) else { return false }

        let width = mask.width
        let height = mask.height
        let x = min(width - 1, max(0, Int(point.x * Double(width - 1))))
        let y = min(height - 1, max(0, Int(point.y * Double(height - 1))))

        if mask.bitsPerPixel == 8,
           mask.bitsPerComponent == 8,
           let data = mask.dataProvider?.data {
            let bytes = CFDataGetBytePtr(data)
            return (bytes?[y * mask.bytesPerRow + x] ?? 0) >= threshold
        }

        var pixels = [UInt8](repeating: 0, count: width * height)
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return false }

        context.interpolationQuality = .none
        context.draw(mask, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels[y * width + x] >= threshold
    }
}

@MainActor
enum CatalogVisualRenderer {
    private static let renderedCache = NSCache<NSString, UIImage>()
    private static let cutoutCache = NSCache<NSString, UIImage>()
    private static let signposter = OSSignposter(
        subsystem: "com.swiftdidload.DishEdit",
        category: "compositing"
    )
    private static let context = CIContext(options: [
        .cacheIntermediates: true,
        .workingColorSpace: NSNull(),
        .outputColorSpace: NSNull()
    ])

    static func image(for dish: DishDefinition, state: DishEditState) -> UIImage? {
        image(for: dish, visualStateKey: state.visualStateKey)
    }

    static func image(
        for dish: DishDefinition,
        visualStateKey: VisualStateKey
    ) -> UIImage? {
        let cacheKey = "render:\(dish.id):\(visualStateKey)" as NSString
        if let cached = renderedCache.object(forKey: cacheKey) { return cached }
        let signpostID = signposter.makeSignpostID()
        let interval = signposter.beginInterval("Catalog mask compositing", id: signpostID)
        defer { signposter.endInterval("Catalog mask compositing", interval) }
        guard var result = BundledResource.cgImage(named: dish.baseImageAsset) else { return nil }

        let hasRemoval = visualStateKey == "removed" || visualStateKey == "removed+added"
        let hasAddition = visualStateKey == "added" || visualStateKey == "removed+added"

        if let removal = dish.removalModifier,
           hasRemoval,
           let removalAsset = dish.fallbackStates["removed"]?.assetName,
           let patch = BundledResource.cgImage(named: removalAsset),
           let mask = BundledResource.cgImage(named: removal.authorMaskAsset),
           let composite = try? ImageCompositor.blend(
               original: result,
               patch: patch,
               mask: mask,
               context: context
           ) {
            result = composite
        }

        if let addition = dish.additionModifier,
           hasAddition,
           let patchAsset = dish.fallbackStates[visualStateKey]?.assetName,
           let patch = BundledResource.cgImage(named: patchAsset),
           let mask = BundledResource.cgImage(named: addition.authorMaskAsset),
           let composite = try? ImageCompositor.blend(
               original: result,
               patch: patch,
               mask: mask,
               context: context
           ) {
            result = composite
        }

        let image = UIImage(cgImage: result)
        renderedCache.setObject(image, forKey: cacheKey)
        return image
    }

    static func ingredientCutout(imageAsset: String, maskAsset: String) -> UIImage? {
        let cacheKey = "cutout:\(imageAsset):\(maskAsset)" as NSString
        if let cached = cutoutCache.object(forKey: cacheKey) { return cached }
        guard let image = BundledResource.cgImage(named: imageAsset),
              let mask = BundledResource.cgImage(named: maskAsset),
              let cutout = try? ImageCompositor.cutout(image: image, mask: mask, context: context) else {
            return nil
        }
        let result = UIImage(cgImage: cutout)
        cutoutCache.setObject(result, forKey: cacheKey)
        return result
    }

    static func maskContains(_ point: NormalizedPoint, assetName: String) -> Bool {
        guard let mask = BundledResource.cgImage(named: assetName) else { return false }
        return AuthorMaskHitTester.contains(point, in: mask)
    }
}
