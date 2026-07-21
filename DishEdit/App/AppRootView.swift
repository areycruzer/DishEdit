import SwiftUI

// MARK: - App Root View

struct AppRootView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            switch coordinator.route {
            case .restaurant:
                RestaurantMenuView(coordinator: coordinator)
            case .customize(let productID):
                VisualEditorView(appCoordinator: coordinator, productID: productID)
            case .instructions(let productID):
                InstructionReviewView(coordinator: coordinator, productID: productID)
            case .checkout:
                CheckoutView(coordinator: coordinator)
            case .confirmation(let orderID):
                OrderConfirmationView(coordinator: coordinator, orderID: orderID)
            case .settings:
                GenerationSettingsView(coordinator: coordinator)
            case .diagnostics:
                DiagnosticsView(coordinator: coordinator)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: coordinator.route)
        .preferredColorScheme(.light)
        .tint(Color.sushiRed)
    }
}


#Preview { AppRootView() }
