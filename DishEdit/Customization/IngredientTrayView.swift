import SwiftUI

struct IngredientTrayView: View {
    let addableIngredients: [IngredientDefinition]
    let presentIngredientIDs: Set<String>
    let onAdd: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ADD SOMETHING")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.5)
                        .foregroundStyle(Color.dishRed)
                    Text("Drag an ingredient into the canvas")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                }
                Spacer()
                Image(systemName: "hand.draw.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.dishRed)
            }
            .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(addableIngredients) { ingredient in
                        trayItem(ingredient)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 14)
        .background(Color.dishSurface.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
        }
    }

    private func trayItem(_ ingredient: IngredientDefinition) -> some View {
        let isAdded = presentIngredientIDs.contains(ingredient.id)

        return Button {
            HapticDirector.selection()
            onAdd(ingredient.id)
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(isAdded ? Color.dishSuccess.opacity(0.13) : Color.white.opacity(0.055))
                        .frame(width: 50, height: 50)

                    BundledImage.image(named: ingredient.layerAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .saturation(isAdded ? 0.45 : 1)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(ingredient.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(isAdded ? "Added" : INR.formatDelta(ingredient.priceDeltaPaise))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isAdded ? Color.dishSuccess : Color.dishWarm)
                }

                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .foregroundStyle(isAdded ? Color.dishSuccess : Color.dishRed)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(minWidth: 150, alignment: .leading)
            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isAdded ? Color.dishSuccess.opacity(0.48) : Color.white.opacity(0.09), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .draggable(ingredient.id) {
            HStack(spacing: 8) {
                BundledImage.image(named: ingredient.layerAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                Text(ingredient.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(10)
            .background(.black.opacity(0.88), in: Capsule())
        }
        .accessibilityLabel(isAdded ? "\(ingredient.name), added" : "Add \(ingredient.name), \(INR.formatDelta(ingredient.priceDeltaPaise))")
        .accessibilityIdentifier("tray.\(ingredient.id)")
        .accessibilityAction(named: isAdded ? "Remove \(ingredient.name)" : "Add \(ingredient.name)") {
            onAdd(ingredient.id)
        }
    }
}
