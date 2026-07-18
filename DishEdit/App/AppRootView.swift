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
                InstructionPlaceholder(coordinator: coordinator, productID: productID)
            case .checkout:
                CheckoutPlaceholder(coordinator: coordinator)
            case .confirmation(let orderID):
                ConfirmationPlaceholder(coordinator: coordinator, orderID: orderID)
            case .settings:
                SettingsPlaceholder(coordinator: coordinator)
            case .diagnostics:
                DiagnosticsPlaceholder(coordinator: coordinator)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: coordinator.route)
    }
}

// MARK: - Placeholder views (replaced in later tasks)

private struct LegacyEditorBridge: View {
    @Bindable var coordinator: AppCoordinator
    let productID: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Visual Editor: \(productID)")
                .font(.title2.bold())
            Text("Route marker active")
                .accessibilityIdentifier("customization.\(productID)")
            Button("Confirm") { coordinator.confirmCustomization(productID: productID) }
            Button("Back") { coordinator.goBack() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
    }
}

private struct InstructionPlaceholder: View {
    @Bindable var coordinator: AppCoordinator
    let productID: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Instruction Review: \(productID)")
                .font(.title2.bold())
                .accessibilityIdentifier("instructions.\(productID)")
            Button("Commit to Cart") { coordinator.commitToCart(productID: productID) }
            Button("Back") { coordinator.goBack() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
    }
}

private struct CheckoutPlaceholder: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 20) {
            Text("Checkout")
                .font(.title2.bold())
                .accessibilityIdentifier("checkout.title")
            Text("Items: \(coordinator.cart.itemCount)")
            Button("Place Demo Order") {
                _ = coordinator.placeDemoOrder()
            }
            Button("Back") { coordinator.goBack() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
    }
}

private struct ConfirmationPlaceholder: View {
    @Bindable var coordinator: AppCoordinator
    let orderID: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Demo Order Prepared")
                .font(.title2.bold())
            Text(orderID)
                .accessibilityIdentifier("confirmation.\(orderID)")
            Button("Done") { coordinator.goBack() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
    }
}

private struct SettingsPlaceholder: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("Settings").font(.title2.bold())
            Button("Back") { coordinator.goBack() }
        }
    }
}

private struct DiagnosticsPlaceholder: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("Diagnostics").font(.title2.bold())
            Button("Back") { coordinator.goBack() }
        }
    }
}

#Preview { AppRootView() }
