import SwiftUI

struct OrderConfirmationView: View {
    @Bindable var coordinator: AppCoordinator
    let orderID: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateCheck = false
    @State private var animateRoute = false

    var body: some View {
        ZStack {
            DishEditBackdrop()

            VStack(spacing: 25) {
                Spacer()
                successMark
                orderInfo
                liveStatusCard
                Spacer()
                disclosure
                doneButton
            }
            .padding(20)
        }
        .preferredColorScheme(.light)
        .onAppear {
            guard !reduceMotion else {
                animateCheck = true
                animateRoute = true
                return
            }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.72).delay(0.12)) {
                animateCheck = true
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                animateRoute = true
            }
        }
        .onDisappear {
            animateRoute = false
        }
    }

    private var successMark: some View {
        ZStack {
            Circle()
                .fill(Color.dishSuccess.opacity(0.1))
                .frame(width: 116, height: 116)
                .scaleEffect(animateCheck ? 1.08 : 0.72)
            Circle()
                .fill(Color.dishSuccess)
                .frame(width: 82, height: 82)
            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(.white)
        }
        .scaleEffect(animateCheck ? 1 : 0.3)
        .opacity(animateCheck ? 1 : 0)
    }

    private var orderInfo: some View {
        VStack(spacing: 7) {
            DishStatusPill(icon: "checkmark", text: "Order confirmed", tint: .dishSuccess)
            Text("Your order has been placed")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(Color.sushiCoal)
                .multilineTextAlignment(.center)
            Text(orderID)
                .font(.caption.monospaced().bold())
                .foregroundStyle(Color.dishMuted)
        }
    }

    private var liveStatusCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ORDER STATUS")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.3)
                        .foregroundStyle(Color.dishRed)
                    Text("The restaurant has accepted your order")
                        .font(.headline)
                }
                Spacer()
                Text("15–20 min")
                    .font(.subheadline.monospacedDigit().bold())
                    .foregroundStyle(Color.dishWarm)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.sushiDivider)
                    Capsule()
                        .fill(Color.sushiRed)
                        .frame(width: safeFrameDimension(proxy.size.width * (animateRoute ? 0.67 : 0.52)))
                }
            }
            .frame(height: 6)

            HStack {
                Label("Confirmed", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.dishSuccess)
                Spacer()
                Label("Preparing", systemImage: "flame.fill")
                    .foregroundStyle(Color.dishWarm)
            }
            .font(.caption.bold())
        }
        .padding(18)
        .dishCard(radius: 24)
    }

    private var disclosure: some View {
        Text("Demo only — no payment was processed and no real restaurant order was placed.")
            .font(.caption)
            .foregroundStyle(Color.dishMuted)
            .multilineTextAlignment(.center)
    }

    private var doneButton: some View {
        Button { coordinator.goBack() } label: {
            HStack {
                Text("Back to restaurant")
                Image(systemName: "arrow.right")
            }
        }
        .buttonStyle(DishPrimaryButtonStyle())
        .accessibilityIdentifier("doneButton")
    }
}
