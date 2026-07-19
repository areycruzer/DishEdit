import SwiftUI

struct RestaurantMenuView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            DishEditBackdrop()

            ScrollView {
                LazyVStack(spacing: 18) {
                    brandBar
                    restaurantHero
                    visualMenuIntroduction

                    ForEach(coordinator.restaurant.products) { product in
                        ProductExperienceCard(
                            product: product,
                            onAdd: { coordinator.addDefaultProduct(productID: product.id) },
                            onEditVisually: { coordinator.beginVisualCustomization(productID: product.id) }
                        )
                    }

                    proofFooter
                        .padding(.top, 4)
                        .padding(.bottom, coordinator.cart.isEmpty ? 24 : 104)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)

            if !coordinator.cart.isEmpty {
                cartBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: coordinator.cart.itemCount)
    }

    private var brandBar: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.dishRed)
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 1) {
                Text("DishEdit")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                Text("A visual ordering experience")
                    .font(.caption)
                    .foregroundStyle(Color.dishMuted)
            }

            Spacer()

            Button { coordinator.showDiagnostics() } label: {
                Image(systemName: "waveform.path.ecg.rectangle")
            }
            .buttonStyle(DishGlassIconButtonStyle())
            .accessibilityLabel("Open diagnostics")

            Button { coordinator.showSettings() } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .buttonStyle(DishGlassIconButtonStyle())
            .accessibilityLabel("Open preview settings")
        }
    }

    private var restaurantHero: some View {
        ZStack(alignment: .bottomLeading) {
            BundledImage.image(named: "menu_burger_hero")
                .resizable()
                .scaledToFill()
                .frame(height: 218)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            LinearGradient(
                colors: [.clear, Color.dishCanvas.opacity(0.28), Color.dishCanvas.opacity(0.98)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 11) {
                DishStatusPill(icon: "sparkles", text: "VISUAL MENU · iOS 27")

                Text(coordinator.restaurant.name)
                    .font(.system(size: 31, weight: .bold, design: .rounded))

                Text(coordinator.restaurant.cuisine)
                    .font(.subheadline)
                    .foregroundStyle(Color.dishMuted)

                HStack(spacing: 10) {
                    Label(String(format: "%.1f", coordinator.restaurant.rating), systemImage: "star.fill")
                    Label(coordinator.restaurant.deliveryEstimate, systemImage: "clock.fill")
                    Label("₹₹", systemImage: "indianrupeesign.circle.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
            }
            .padding(20)
        }
        .frame(height: 218)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.38), radius: 24, y: 14)
    }

    private var visualMenuIntroduction: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "hand.draw.fill")
                .font(.title2)
                .foregroundStyle(Color.dishRed)
                .frame(width: 42, height: 42)
                .background(Color.dishRed.opacity(0.14), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 4) {
                Text("Don’t describe it. Touch it.")
                    .font(.headline)
                Text("Open any dish, pull its ingredients apart, remove what you dislike, and drag in what you want.")
                    .font(.caption)
                    .foregroundStyle(Color.dishMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .dishCard(radius: 20)
    }

    private var cartBar: some View {
        Button { coordinator.showCheckout() } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(.white.opacity(0.17))
                    Text("\(coordinator.cart.itemCount)")
                        .font(.caption.bold())
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Your order")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.72))
                    Text(INR.format(coordinator.cart.itemTotal))
                        .font(.headline.monospacedDigit())
                }

                Spacer()

                Text("View cart")
                    .font(.subheadline.bold())
                Image(systemName: "arrow.right")
                    .font(.subheadline.bold())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 68)
            .background(
                LinearGradient(
                    colors: [Color.dishRed, Color(red: 0.66, green: 0.015, blue: 0.07)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: Color.dishRed.opacity(0.42), radius: 22, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityIdentifier("menu.cart.banner")
    }

    private var proofFooter: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(Color.dishSuccess)
            Text("Order details always come from the restaurant’s modifier catalog. Visual AI never decides what the kitchen prepares.")
                .font(.caption2)
                .foregroundStyle(Color.dishMuted)
        }
        .padding(.horizontal, 8)
    }
}

private struct ProductExperienceCard: View {
    let product: ProductDefinition
    let onAdd: () -> Void
    let onEditVisually: () -> Void

    @State private var imageScale = 1.02

    var body: some View {
        VStack(spacing: 0) {
            heroImage
            productDetails
        }
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.075), Color.white.opacity(0.025)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.8)
                        .allowsHitTesting(false)
                }
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottomTrailing) {
            editVisuallyButton
                .frame(width: 164)
                .padding(16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { imageScale = 1 }
        }
    }

    private var heroImage: some View {
        ZStack(alignment: .topLeading) {
            BundledImage.image(named: product.assembledAssetName)
                .resizable()
                .scaledToFill()
                .scaleEffect(imageScale)
                .frame(height: 176)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            LinearGradient(
                colors: [.clear, Color.dishCanvas.opacity(0.72)],
                startPoint: UnitPoint(x: 0.5, y: 0.45),
                endPoint: .bottom
            )

            HStack(spacing: 7) {
                dietaryMarker
                Text(String(format: "%.1f", product.rating))
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
            }
            .font(.caption2.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.black.opacity(0.58), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.7))
            .padding(13)
        }
        .frame(height: 176)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 26, topTrailingRadius: 26))
    }

    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.title3.bold())
                        .accessibilityIdentifier("menu.product.\(product.id)")
                    Text(product.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                        .lineLimit(2)
                }

                Spacer(minLength: 12)

                Text(INR.format(product.basePricePaise))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.dishWarm)
            }

            Text(product.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(3)

            HStack(spacing: 10) {
                Button(action: onAdd) {
                    Label("Quick add", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.88))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.white.opacity(0.065), in: RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.12), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("menu.add.\(product.id)")

                Color.clear
                    .frame(maxWidth: .infinity)
                .frame(height: 48)
                    .accessibilityHidden(true)
            }
        }
        .padding(16)
    }

    private var editVisuallyButton: some View {
        Button(action: onEditVisually) {
            HStack(spacing: 7) {
                Image(systemName: "wand.and.stars")
                Text("Edit visually")
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.dishRed, in: RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.dishRed.opacity(0.32), radius: 13, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("menu.edit-visually.\(product.id)")
    }

    private var dietaryMarker: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(product.dietaryMarker == "Veg" ? Color.dishSuccess : Color.dishRed, lineWidth: 1.4)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .fill(product.dietaryMarker == "Veg" ? Color.dishSuccess : Color.dishRed)
                        .frame(width: 6, height: 6)
                }
            Text(product.dietaryMarker.uppercased())
        }
    }
}

#Preview {
    RestaurantMenuView(coordinator: AppCoordinator())
}
