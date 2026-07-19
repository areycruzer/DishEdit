import SwiftUI

// MARK: - Checkout View

struct CheckoutView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            if coordinator.cart.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        cartItemsSection
                        totalsSection
                    }
                    .padding(20)
                }
                placeOrderBar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityIdentifier("checkout.title")
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
            }
            .accessibilityLabel("Back")

            Spacer()

            Text("Checkout")
                .font(.headline)

            Spacer()

            Text("\(coordinator.cart.itemCount) items")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Your cart is empty")
                .font(.title3)
                .foregroundStyle(.secondary)
            Button("Browse Menu") { coordinator.goBack() }
                .buttonStyle(.bordered)
            Spacer()
        }
    }

    // MARK: - Cart Items

    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Order")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(coordinator.cart.items) { item in
                CartItemRow(item: item) {
                    coordinator.cart.removeItem(id: item.id)
                }
            }
        }
    }

    // MARK: - Totals

    private var totalsSection: some View {
        let totals = coordinator.cart.totals
        return VStack(spacing: 10) {
            Divider()
            totalRow("Items", amount: totals.itemTotal)
            totalRow("Delivery", amount: totals.deliveryFee)
            totalRow("Platform Fee", amount: totals.platformFee)
            totalRow("Taxes", amount: totals.taxes)
            Divider()
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(INR.format(totals.grandTotal))
                    .font(.headline)
            }
        }
    }

    private func totalRow(_ label: String, amount: Int) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(INR.format(amount))
        }
        .font(.subheadline)
    }

    // MARK: - Place Order

    private var placeOrderBar: some View {
        VStack(spacing: 12) {
            Divider()
            Button {
                _ = coordinator.placeDemoOrder()
            } label: {
                HStack {
                    Text("Place Order")
                        .font(.headline)
                    Text("•")
                    Text(INR.format(coordinator.cart.totals.grandTotal))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .accessibilityIdentifier("placeOrderButton")
        }
    }
}

// MARK: - Cart Item Row

private struct CartItemRow: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.body.weight(.medium))

                if !item.modifiers.isEmpty {
                    Text(item.modifiers.map(\.label).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !item.customerNote.isEmpty {
                    Text("Note: \(item.customerNote)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(INR.format(item.totalPricePaise))
                    .font(.subheadline.weight(.medium))

                Button(role: .destructive) { onRemove() } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
