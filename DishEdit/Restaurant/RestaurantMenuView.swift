import SwiftUI

// MARK: - Restaurant Menu View

struct RestaurantMenuView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    restaurantHeaderSection
                    menuSection
                        .padding(.bottom, coordinator.cart.isEmpty ? 24 : 80)
                }
            }
            .background(Color(.systemGroupedBackground))

            if !coordinator.cart.isEmpty {
                cartFloatingBar
            }
        }
    }

    // MARK: - Restaurant Header

    private var restaurantHeaderSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 140)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coordinator.restaurant.name)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Text(coordinator.restaurant.cuisine)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    ratingBadge
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            deliveryInfoBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider()
                .padding(.horizontal, 16)
        }
        .background(Color(.systemBackground))
    }

    private var ratingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(String(format: "%.1f", coordinator.restaurant.rating))
                .font(.caption.bold())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.zomatoGreen, in: RoundedRectangle(cornerRadius: 6))
    }

    private var deliveryInfoBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(coordinator.restaurant.deliveryEstimate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("·")
                .foregroundStyle(.secondary)

            Text("Schedule for later")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Menu")
                .font(.title3.bold())
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)

            LazyVStack(spacing: 1) {
                ForEach(coordinator.restaurant.products) { product in
                    ProductRow(
                        product: product,
                        onAdd: { coordinator.addDefaultProduct(productID: product.id) },
                        onEditVisually: { coordinator.beginVisualCustomization(productID: product.id) }
                    )
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Cart Floating Bar

    private var cartFloatingBar: some View {
        Button { coordinator.showCheckout() } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(coordinator.cart.itemCount) item\(coordinator.cart.itemCount > 1 ? "s" : "") added")
                        .font(.footnote.bold())
                        .foregroundStyle(.white)
                    Text(INR.format(coordinator.cart.itemTotal))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Text("View Cart")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.zomatoGreen, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityIdentifier("menu.cart.banner")
    }
}

// MARK: - Product Row (Zomato-style)

private struct ProductRow: View {
    let product: ProductDefinition
    let onAdd: () -> Void
    let onEditVisually: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    dietaryBadge
                    Text(product.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text(product.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(INR.format(product.basePricePaise))
                            .font(.subheadline.weight(.medium))
                        ratingLabel
                    }
                    .padding(.top, 2)
                }

                Spacer()

                productImageWithButtons
            }
            .padding(16)

            Divider()
                .padding(.leading, 16)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("menu.product.\(product.id)")
    }

    private var dietaryBadge: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(product.dietaryMarker == "Veg" ? Color.green : Color.red, lineWidth: 1.5)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .fill(product.dietaryMarker == "Veg" ? Color.green : Color.red)
                        .frame(width: 7, height: 7)
                )
        }
    }

    private var ratingLabel: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundStyle(.orange)
            Text(String(format: "%.1f", product.rating))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var productImageWithButtons: some View {
        VStack(spacing: 0) {
            BundledImage.image(named: product.assembledAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 6) {
                Button(action: onAdd) {
                    Text("ADD")
                        .font(.caption.bold())
                        .foregroundStyle(Color.zomatoGreen)
                        .frame(width: 52, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.zomatoGreen.opacity(0.4), lineWidth: 1)
                                .fill(Color.zomatoGreen.opacity(0.06))
                        )
                }
                .accessibilityIdentifier("menu.add.\(product.id)")

                Button(action: onEditVisually) {
                    HStack(spacing: 3) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 8))
                        Text("Edit")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .frame(height: 30)
                    .padding(.horizontal, 8)
                    .background(Color.zomatoGreen, in: RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityIdentifier("menu.edit-visually.\(product.id)")
            }
            .padding(.top, 6)
        }
    }
}

