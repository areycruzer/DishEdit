import Testing
@testable import DishEdit

@Suite("Image Playground Bridge Tests")
@MainActor
struct ImagePlaygroundBridgeTests {

    @Test func bridgeReportsAvailability() async {
        if #available(iOS 26.0, *) {
            let availability = ImagePlaygroundBridge.engineAvailability()
            #expect(availability == .available || availability == .unavailable)
        }
    }

    @Test func bridgeIsAvailableMatchesFeatureFlag() async {
        if #available(iOS 26.0, *) {
            #expect(ImagePlaygroundBridge.isAvailable == FeatureAvailability.isImagePlaygroundAvailable)
        }
    }
}
