import SwiftUI

// MARK: - Restaurant Menu View

struct RestaurantMenuView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                restaurantHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Divider()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                LazyVStack(spacing: 16) {
                    ForEach(coordinator.restaurant.products) { product in
                        ProductCardView(
                            product: product,
                            onAdd: { coordinator.addDefaultProduct(productID: product.id) },
                            onEditVisually: { coordinator.beginVisualCustomization(productID: product.id) }
                        )
                        .accessibilityIdentifier("menu.product.\(product.id)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            if !coordinator.cart.isEmpty {
                cartBanner
            }
        }
    }

    private var restaurantHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(coordinator.restaurant.name)
                        .font(.title.bold())
                    Text(coordinator.restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text(String(format: "%.1f", coordinator.restaurant.rating))
                        .font(.subheadline.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 16) {
                Label(coordinator.restaurant.deliveryEstimate, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var cartBanner: some View {
        Button { coordinator.showCheckout() } label: {
            HStack {
                Text("\(coordinator.cart.itemCount) item\(coordinator.cart.itemCount > 1 ? "s" : "")")
                    .font(.subheadline.bold())
                Spacer()
                Text("View Cart")
                    .font(.subheadline.bold())
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.red, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityIdentifier("menu.cart.banner")
    }
}

// MARK: - Product Card

struct ProductCardView: View {
    let product: ProductDefinition
    let onAdd: () -> Void
    let onEditVisually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: product.dietaryMarker == "Veg" ? "leaf.circle.fill" : "circle.fill")
                            .font(.caption2)
                            .foregroundStyle(product.dietaryMarker == "Veg" ? .green : .red)
                        Text(product.dietaryMarker)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)

                    Text(product.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(INR.format(product.basePricePaise))
                            .font(.subheadline.bold())

                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text(String(format: "%.1f", product.rating))
                                .font(.caption)
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer()

                BundledImage.image(named: product.assembledAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.2), lineWidth: 0.5))
            }

            HStack(spacing: 10) {
                Button(action: onAdd) {
                    Text("Add")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .accessibilityIdentifier("menu.add.\(product.id)")

                Button(action: onEditVisually) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.caption)
                        Text("Edit visually")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityIdentifier("menu.edit-visually.\(product.id)")
            }
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
