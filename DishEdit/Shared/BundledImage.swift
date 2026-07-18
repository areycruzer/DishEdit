import SwiftUI
import UIKit

// MARK: - Bundled Image Cache

@MainActor
enum BundledImage {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(named name: String) -> Image {
        if let cached = cache.object(forKey: name as NSString) {
            return Image(uiImage: cached)
        }
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let uiImage = UIImage(contentsOfFile: path) else {
            return Image(systemName: "photo.badge.exclamationmark")
        }
        cache.setObject(uiImage, forKey: name as NSString)
        return Image(uiImage: uiImage)
    }

    static func uiImage(named name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) {
            return cached
        }
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let uiImage = UIImage(contentsOfFile: path) else {
            return nil
        }
        cache.setObject(uiImage, forKey: name as NSString)
        return uiImage
    }
}
