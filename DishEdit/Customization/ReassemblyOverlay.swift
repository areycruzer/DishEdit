import SwiftUI

// MARK: - Reassembly Overlay

struct ReassemblyOverlay: View {
    let product: ProductDefinition
    let modifierSummary: [ModifierSummaryItem]
    let basePricePaise: Int
    let priceDeltaPaise: Int
    let previewAssetName: String?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Assembled image
                BundledImage.image(named: previewAssetName ?? product.assembledAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                Text("Looking good!")
                    .font(.title3.bold())

                if !modifierSummary.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(modifierSummary, id: \.ingredientID) { item in
                            HStack {
                                Image(systemName: item.kind == .removal ? "minus.circle.fill" : "plus.circle.fill")
                                    .foregroundStyle(item.kind == .removal ? .red : .green)
                                    .font(.caption)
                                Text(item.label)
                                    .font(.subheadline)
                                Spacer()
                                if item.priceDeltaPaise != 0 {
                                    Text(INR.formatDelta(item.priceDeltaPaise))
                                        .font(.caption.bold())
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                HStack {
                    Text("Total:")
                        .font(.subheadline)
                    Spacer()
                    Text(INR.format(basePricePaise + priceDeltaPaise))
                        .font(.headline.bold())
                }
                .padding(.horizontal, 20)

                Button(action: onDone) {
                    Text("Confirm Order")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.horizontal, 20)
                .accessibilityIdentifier("reassembly.confirm")
            }
            .padding(.vertical, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .accessibilityIdentifier("reassembly-overlay")
    }
}
