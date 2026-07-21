import SwiftUI

struct IngredientTrayView: View {
    private enum SushiTrayLayout {
        static let horizontalPadding: CGFloat = 18
        static let itemSpacing: CGFloat = 8
        static let cardWidth: CGFloat = 116
        static let cardHorizontalPadding: CGFloat = 6
        static let imageWellWidth: CGFloat = 104
    }

    let addableIngredients: [IngredientDefinition]
    let presentIngredientIDs: Set<String>
    let onAdd: (String) -> Void
    var style: IngredientEditorStyle = .cinematic

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(style == .sushiCommerce ? "Add extras" : "ADD SOMETHING")
                        .font(.system(size: style == .sushiCommerce ? 17 : 10, weight: .bold))
                        .tracking(style == .sushiCommerce ? 0 : 1.5)
                        .foregroundStyle(style == .sushiCommerce ? Color.sushiCoal : Color.dishRed)
                    Text(style == .sushiCommerce ? "Tap to add it to your dish" : "Drag an ingredient into the canvas")
                        .font(style == .sushiCommerce ? .system(size: 12) : .caption)
                        .foregroundStyle(style == .sushiCommerce ? Color.sushiGrey : Color.dishMuted)
                }
                Spacer()
                if style == .cinematic {
                    Image(systemName: "hand.draw.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.dishRed)
                }
            }
            .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: style == .sushiCommerce ? SushiTrayLayout.itemSpacing : 12) {
                    ForEach(addableIngredients) { ingredient in
                        trayItem(ingredient)
                    }
                }
                .padding(.horizontal, style == .sushiCommerce ? SushiTrayLayout.horizontalPadding : 18)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, style == .sushiCommerce ? 12 : 14)
        .background(style == .sushiCommerce ? Color.white : Color.dishSurface.opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style == .sushiCommerce ? Color.sushiDivider : Color.white.opacity(0.08))
                .frame(height: 0.5)
        }
    }

    private func trayItem(_ ingredient: IngredientDefinition) -> some View {
        let isAdded = presentIngredientIDs.contains(ingredient.id)

        return Button {
            HapticDirector.selection()
            onAdd(ingredient.id)
        } label: {
            Group {
                if style == .sushiCommerce {
                    sushiTrayItem(ingredient, isAdded: isAdded)
                } else {
                    cinematicTrayItem(ingredient, isAdded: isAdded)
                }
            }
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

    private func sushiTrayItem(_ ingredient: IngredientDefinition, isAdded: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.sushiCanvas)
                    .frame(width: SushiTrayLayout.imageWellWidth, height: 68)

                BundledImage.image(named: ingredient.layerAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 64)
                    .frame(width: SushiTrayLayout.imageWellWidth, height: 68)
                    .saturation(isAdded ? 0.55 : 1)

                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, isAdded ? Color.zomatoGreen : Color.sushiRed)
                    .background(Color.white, in: Circle())
                    .offset(x: 5, y: -5)
            }

            Text(ingredient.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.sushiCoal)
                .lineLimit(1)

            Text(isAdded ? "Added" : INR.formatDelta(ingredient.priceDeltaPaise))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isAdded ? Color.zomatoGreen : Color.sushiGrey)
        }
        .padding(.horizontal, SushiTrayLayout.cardHorizontalPadding)
        .padding(.vertical, 10)
        .frame(width: SushiTrayLayout.cardWidth, height: 132, alignment: .topLeading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isAdded ? Color.zomatoGreen.opacity(0.55) : Color.sushiDivider, lineWidth: isAdded ? 1.3 : 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
    }

    private func cinematicTrayItem(_ ingredient: IngredientDefinition, isAdded: Bool) -> some View {
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
}
