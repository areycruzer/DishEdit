import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

nonisolated struct ImageEditCacheKey: Hashable, Sendable {
    let dishID: String
    let modifierIDs: [String]
    let seed: UInt64
    let modelVersion: String

    init(
        dishID: String,
        modifierIDs: Set<String>,
        seed: UInt64,
        modelVersion: String
    ) {
        self.dishID = dishID
        self.modifierIDs = modifierIDs.sorted()
        self.seed = seed
        self.modelVersion = modelVersion
    }

    var storageKey: String {
        "\(dishID)|\(modifierIDs.joined(separator: ","))|\(seed)|\(modelVersion)"
    }
}

nonisolated enum ImageCompositorError: Error {
    case sizeMismatch
    case outputUnavailable
}

nonisolated enum ImageCompositor {
    static func blend(
        original: CGImage,
        patch: CGImage,
        mask: CGImage,
        context: CIContext = CIContext(options: [
            .cacheIntermediates: false,
            .workingColorSpace: NSNull(),
            .outputColorSpace: NSNull()
        ])
    ) throws -> CGImage {
        guard original.width == patch.width,
              original.height == patch.height,
              original.width == mask.width,
              original.height == mask.height else {
            throw ImageCompositorError.sizeMismatch
        }

        let originalImage = CIImage(cgImage: original)
        let filter = CIFilter.blendWithMask()
        filter.inputImage = CIImage(cgImage: patch)
        filter.backgroundImage = originalImage
        filter.maskImage = CIImage(cgImage: mask)

        guard let output = filter.outputImage?.cropped(to: originalImage.extent) else {
            throw ImageCompositorError.outputUnavailable
        }

        guard let result = context.createCGImage(output, from: originalImage.extent) else {
            throw ImageCompositorError.outputUnavailable
        }

        return result
    }

    static func cutout(
        image: CGImage,
        mask: CGImage,
        context: CIContext = CIContext(options: [
            .cacheIntermediates: false,
            .workingColorSpace: NSNull(),
            .outputColorSpace: NSNull()
        ])
    ) throws -> CGImage {
        guard image.width == mask.width, image.height == mask.height else {
            throw ImageCompositorError.sizeMismatch
        }

        let source = CIImage(cgImage: image)
        let transparent = CIImage(color: .clear).cropped(to: source.extent)
        let filter = CIFilter.blendWithMask()
        filter.inputImage = source
        filter.backgroundImage = transparent
        filter.maskImage = CIImage(cgImage: mask)

        guard let output = filter.outputImage?.cropped(to: source.extent),
              let result = context.createCGImage(output, from: source.extent) else {
            throw ImageCompositorError.outputUnavailable
        }
        return result
    }
}
