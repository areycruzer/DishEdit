import SwiftUI

// MARK: - Checkout View

struct CheckoutView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 12) {
                    cartItemsSection
                    addMoreSection
                    billDetailsSection
                    deliverySection
                    cancellationNote
                }
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                checkoutHeader
            }

            placeOrderButton
        }
    }

    // MARK: - Header

    private var checkoutHeader: some View {
        HStack(spacing: 12) {
            Button { coordinator.goBack() } label: {
                Image(systemName: "arrow.left")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(.systemGray6)))
            }

            Text(coordinator.restaurant.name)
                .font(.headline)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Cart Items

    private var cartItemsSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(coordinator.cart.items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 16)
                }
                CartItemRow(item: item, onRemove: { coordinator.cart.removeItem(id: item.id) })
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - Add More / Note

    private var addMoreSection: some View {
        HStack(spacing: 12) {
            Button { coordinator.goBack() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.caption.bold())
                    Text("Add more items")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Color.zomatoGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Bill Details

    private var billDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bill Details")
                .font(.subheadline.bold())

            let totals = coordinator.cart.totals

            BillRow(label: "Item total", amount: totals.itemTotal)
            BillRow(label: "Delivery fee", amount: totals.deliveryFee)
            BillRow(label: "Platform fee", amount: totals.platformFee)
            BillRow(label: "Taxes", amount: totals.taxes)

            Divider()

            HStack {
                Text("To Pay")
                    .font(.subheadline.bold())
                Spacer()
                Text(INR.format(totals.grandTotal))
                    .font(.subheadline.bold())
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - Delivery Info

    private var deliverySection: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.body)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Delivery in \(coordinator.restaurant.deliveryEstimate)")
                    .font(.subheadline.weight(.medium))
                Text("Standard delivery")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - Cancellation

    private var cancellationNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CANCELLATION POLICY")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            Text("A 100% cancellation charge will apply. This helps us compensate the restaurant partner for food preparation.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Place Order CTA

    private var placeOrderButton: some View {
        Button {
            _ = coordinator.placeDemoOrder()
        } label: {
            Text("Place Order")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.zomatoGreen, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityIdentifier("checkout.placeOrder")
    }
}

// MARK: - Cart Item Row

private struct CartItemRow: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "leaf.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.subheadline.weight(.medium))

                if !item.modifiers.isEmpty {
                    Text(item.modifiers.map(\.label).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                quantityStepper
                Text(INR.format(item.totalPricePaise))
                    .font(.caption.weight(.medium))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var quantityStepper: some View {
        HStack(spacing: 12) {
            Button(action: onRemove) {
                Image(systemName: "minus")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.zomatoGreen)
            }
            Text("1")
                .font(.caption.bold())
                .foregroundStyle(Color.zomatoGreen)
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.zomatoGreen)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.zomatoGreen, lineWidth: 1.5)
        )
    }
}

// MARK: - Bill Row

private struct BillRow: View {
    let label: String
    let amount: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(INR.format(amount))
                .font(.caption)
        }
    }
}
