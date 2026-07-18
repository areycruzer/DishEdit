import CoreGraphics
import Foundation

nonisolated struct ImageFrame: Equatable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    func contains(x screenX: Double, y screenY: Double) -> Bool {
        screenX >= x && screenX <= x + width
            && screenY >= y && screenY <= y + height
    }
}

/// Maps touches to source-image space while respecting an aspect-fit presentation.
/// The view layer supplies points after safe-area and gesture transforms are removed.
nonisolated struct ImageViewport: Equatable, Sendable {
    let containerWidth: Double
    let containerHeight: Double
    let imageWidth: Double
    let imageHeight: Double

    var imageFrame: ImageFrame {
        guard containerWidth > 0, containerHeight > 0, imageWidth > 0, imageHeight > 0 else {
            return ImageFrame(x: 0, y: 0, width: 0, height: 0)
        }

        let scale = min(containerWidth / imageWidth, containerHeight / imageHeight)
        let width = imageWidth * scale
        let height = imageHeight * scale
        return ImageFrame(
            x: (containerWidth - width) / 2,
            y: (containerHeight - height) / 2,
            width: width,
            height: height
        )
    }

    func normalizedPoint(screenX: Double, screenY: Double) -> NormalizedPoint? {
        let frame = imageFrame
        guard frame.width > 0, frame.height > 0, frame.contains(x: screenX, y: screenY) else {
            return nil
        }

        return NormalizedPoint(
            x: (screenX - frame.x) / frame.width,
            y: (screenY - frame.y) / frame.height
        )
    }

    func screenPoint(for point: NormalizedPoint) -> (x: Double, y: Double) {
        let frame = imageFrame
        return (
            x: frame.x + point.x * frame.width,
            y: frame.y + point.y * frame.height
        )
    }
}

/// Projects and unprojects points using the same center-based scale and translation
/// that SwiftUI applies to the dish stage. This keeps taps, drops, and anchor
/// rendering in one coordinate system.
nonisolated struct ImageInteractionTransform: Equatable, Sendable {
    let containerWidth: Double
    let containerHeight: Double
    let zoom: Double
    let panX: Double
    let panY: Double

    func project(_ point: CGPoint) -> CGPoint {
        let centerX = containerWidth / 2
        let centerY = containerHeight / 2
        return CGPoint(
            x: centerX + (point.x - centerX) * zoom + panX,
            y: centerY + (point.y - centerY) * zoom + panY
        )
    }

    func unproject(_ point: CGPoint) -> CGPoint {
        guard zoom > 0 else { return point }
        let centerX = containerWidth / 2
        let centerY = containerHeight / 2
        return CGPoint(
            x: centerX + (point.x - centerX - panX) / zoom,
            y: centerY + (point.y - centerY - panY) / zoom
        )
    }
}

nonisolated enum ModifierResolver {
    static func acceptsDrop(at point: NormalizedPoint, modifier: ModifierDefinition) -> Bool {
        guard modifier.kind == .addition else { return false }
        return modifier.approvedAnchors.contains { $0.contains(point) }
    }
}
