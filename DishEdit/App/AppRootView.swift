import SwiftUI

struct AppRootView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            switch coordinator.route {
            case .restaurant:
                RestaurantMenuView(coordinator: coordinator)
            case .customize(let productID):
                DishEditEditorView(dishID: productID, appCoordinator: coordinator)
            case .checkout:
                CheckoutView(coordinator: coordinator)
            case .confirmation(let orderID):
                OrderConfirmationView(coordinator: coordinator, orderID: orderID)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: coordinator.route)
    }
}

#Preview { AppRootView() }
