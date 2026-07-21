import SwiftUI

struct CheckoutView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            DishEditBackdrop()

            VStack(spacing: 0) {
                checkoutHeader
                ScrollView {
                    VStack(spacing: 15) {
                        arrivalCard
                        cartItemsSection
                        addMoreSection
                        billDetailsSection
                        deliverySection
                        cancellationNote
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 124)
                }
            }

            placeOrderButton
        }
        .preferredColorScheme(.light)
    }

    private var checkoutHeader: some View {
        HStack(spacing: 12) {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(DishGlassIconButtonStyle())
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 1) {
                Text("YOUR ORDER")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(Color.dishRed)
                Text("Your cart")
                    .font(.headline)
            }

            Spacer()

            Text("\(coordinator.cart.itemCount) ITEM")
                .font(.system(size: 9, weight: .black))
                .tracking(1)
                .foregroundStyle(Color.dishMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var arrivalCard: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle().fill(Color.dishRed.opacity(0.14))
                Image(systemName: "scooter")
                    .font(.title3)
                    .foregroundStyle(Color.dishRed)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text("Arrives in \(coordinator.restaurant.deliveryEstimate)")
                    .font(.headline)
                Text("From \(coordinator.restaurant.name) · standard delivery")
                    .font(.caption)
                    .foregroundStyle(Color.dishMuted)
            }
            Spacer()
            Image(systemName: "location.fill")
                .foregroundStyle(Color.dishWarm)
        }
        .padding(16)
        .dishCard(radius: 22)
    }

    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("YOUR ORDER")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(Color.dishRed)
                Spacer()
                Label("Customisations included", systemImage: "checkmark.circle.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.dishSuccess)
            }

            ForEach(coordinator.cart.items) { item in
                CartItemRow(
                    item: item,
                    imageAsset: coordinator.restaurant.product(id: item.productID)?.assembledAssetName,
                    onRemove: { coordinator.cart.removeItem(id: item.id) }
                )
            }
        }
        .padding(16)
        .dishCard(radius: 22)
    }

    private var addMoreSection: some View {
        Button { coordinator.goBack() } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.dishRed)
                Text("Add another dish")
                    .font(.subheadline.bold())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color.dishMuted)
            }
            .foregroundStyle(Color.sushiCoal)
            .padding(15)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.sushiDivider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var billDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BILL DETAILS")
                .font(.system(size: 10, weight: .black))
                .tracking(1.4)
                .foregroundStyle(Color.dishRed)

            let totals = coordinator.cart.totals
            BillRow(label: "Item total", amount: totals.itemTotal)
            BillRow(label: "Delivery fee", amount: totals.deliveryFee)
            BillRow(label: "Platform fee", amount: totals.platformFee)
            BillRow(label: "Taxes", amount: totals.taxes)

            Rectangle().fill(Color.sushiDivider).frame(height: 1)

            HStack {
                Text("To Pay")
                    .font(.headline)
                Spacer()
                Text(INR.format(totals.grandTotal))
                    .font(.title3.monospacedDigit().bold())
                    .foregroundStyle(Color.sushiCoal)
            }
        }
        .padding(17)
        .dishCard(radius: 22)
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Delivering to", systemImage: "house.fill")
                .font(.caption.bold())
                .foregroundStyle(Color.dishRed)
            Text("Home")
                .font(.headline)
            Text("12, Demo Street · Bengaluru")
                .font(.caption)
                .foregroundStyle(Color.dishMuted)
            Label("Leave at the door · Ring once", systemImage: "bell.badge.fill")
                .font(.caption)
                .foregroundStyle(Color.dishMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .dishCard(radius: 22)
    }

    private var cancellationNote: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CANCELLATION POLICY")
                .font(.system(size: 9, weight: .black))
                .tracking(1.1)
                .foregroundStyle(Color.dishMuted)
            Text("A cancellation charge may apply after preparation begins. This prototype does not process a real payment or restaurant order.")
                .font(.caption)
                .foregroundStyle(Color.dishMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private var placeOrderButton: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 1) {
                Text("TOTAL")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1)
                    .foregroundStyle(Color.dishMuted)
                Text(INR.format(coordinator.cart.totals.grandTotal))
                    .font(.title3.monospacedDigit().bold())
            }

            Button {
                _ = coordinator.placeDemoOrder()
            } label: {
                HStack {
                    Text("Place demo order")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(DishPrimaryButtonStyle())
            .disabled(coordinator.cart.isEmpty)
            .opacity(coordinator.cart.isEmpty ? 0.45 : 1)
            .accessibilityIdentifier("checkout.placeOrder")
        }
        .padding(.horizontal, 16)
        .padding(.top, 11)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .top) { Rectangle().fill(Color.sushiDivider).frame(height: 1) }
    }
}

private struct CartItemRow: View {
    let item: CartItem
    let imageAsset: String?
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageAsset {
                BundledImage.image(named: imageAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(item.productName)
                    .font(.subheadline.bold())

                if item.modifiers.isEmpty {
                    Text("Restaurant recipe")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                } else {
                    ForEach(item.modifiers, id: \.ingredientID) { modifier in
                        Label(
                            modifier.label,
                            systemImage: modifier.kind == .removal ? "minus.circle.fill" : "plus.circle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(modifier.kind == .removal ? Color.dishRed : Color.dishSuccess)
                    }
                }

                if !item.customerNote.isEmpty {
                    Text("“\(item.customerNote)”")
                        .font(.caption2.italic())
                        .foregroundStyle(Color.dishWarm)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 8) {
                Text(INR.format(item.totalPricePaise))
                    .font(.caption.monospacedDigit().bold())
                Button(action: onRemove) {
                    Image(systemName: "minus")
                        .font(.caption.bold())
                        .frame(width: 30, height: 28)
                        .background(Color.dishRed.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))
                }
                .foregroundStyle(Color.dishRed)
                .accessibilityLabel("Remove \(item.productName)")
            }
        }
        .padding(11)
        .background(Color.sushiCanvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.sushiDivider, lineWidth: 1))
    }
}

private struct BillRow: View {
    let label: String
    let amount: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.dishMuted)
            Spacer()
            Text(INR.format(amount))
                .font(.caption.monospacedDigit())
        }
    }
}
