import SwiftUI

// MARK: - Ingredient Tray View

struct IngredientTrayView: View {
    let addableIngredients: [IngredientDefinition]
    let presentIngredientIDs: Set<String>
    let onAdd: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(addableIngredients) { ingredient in
                    let isAdded = presentIngredientIDs.contains(ingredient.id)

                    Button {
                        onAdd(ingredient.id)
                    } label: {
                        VStack(spacing: 4) {
                            BundledImage.image(named: ingredient.layerAssetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isAdded ? .green : .secondary.opacity(0.4), lineWidth: isAdded ? 2 : 1)
                                )

                            Text(ingredient.name)
                                .font(.caption2)
                                .foregroundStyle(isAdded ? .primary : .secondary)
                                .lineLimit(1)

                            Text(INR.formatDelta(ingredient.priceDeltaPaise))
                                .font(.system(size: 10).bold())
                                .foregroundStyle(isAdded ? .green : .orange)
                        }
                    }
                    .buttonStyle(.plain)
                    .opacity(isAdded ? 0.5 : 1)
                    .accessibilityLabel(isAdded ? "\(ingredient.name), added" : "Add \(ingredient.name), \(INR.formatDelta(ingredient.priceDeltaPaise))")
                    .accessibilityIdentifier("tray.\(ingredient.id)")
                    .accessibilityAction(named: isAdded ? "Remove \(ingredient.name)" : "Add \(ingredient.name)") {
                        onAdd(ingredient.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .accessibilityIdentifier("ingredient-tray")
    }
}
