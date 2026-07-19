import Testing
@testable import DishEdit

struct RestaurantCatalogTests {
    @Test func catalogContainsExactlyThreeProducts() {
        let catalog = DemoRestaurantCatalog.copperAndCrumb
        #expect(catalog.products.map(\.id) == ["burger", "pizza", "waffle"])
    }

    @Test func eachProductHasValidAsset() {
        for product in DemoRestaurantCatalog.copperAndCrumb.products {
            #expect(!product.assembledAssetName.isEmpty)
        }
    }

    @Test func restaurantLookupReturnsNilForUnknownID() {
        let catalog = DemoRestaurantCatalog.copperAndCrumb
        #expect(catalog.product(id: "unknown") == nil)
    }

    @Test func burgerPriceIs249() {
        let burger = DemoRestaurantCatalog.copperAndCrumb.product(id: "burger")!
        #expect(burger.basePricePaise == 24_900)
    }
}
