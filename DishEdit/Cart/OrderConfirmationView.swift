import SwiftUI

// MARK: - Order Confirmation View

struct OrderConfirmationView: View {
    @Bindable var coordinator: AppCoordinator
    let orderID: String

    @State private var animateCheck = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            checkmark
            orderInfo
            estimateCard

            Spacer()

            doneButton
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateCheck = true
            }
        }
        .accessibilityIdentifier("confirmation.\(orderID)")
    }

    private var checkmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 72))
            .foregroundStyle(.green)
            .scaleEffect(animateCheck ? 1.0 : 0.3)
            .opacity(animateCheck ? 1.0 : 0.0)
    }

    private var orderInfo: some View {
        VStack(spacing: 8) {
            Text("Order Placed")
                .font(.title.bold())

            Text(orderID)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
        }
    }

    private var estimateCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundStyle(.orange)
                Text("Estimated Preparation")
                    .font(.subheadline.weight(.medium))
            }

            Text("15–20 minutes")
                .font(.title3.weight(.semibold))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private var doneButton: some View {
        Button {
            coordinator.goBack()
        } label: {
            Text("Done")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .accessibilityIdentifier("doneButton")
    }
}
