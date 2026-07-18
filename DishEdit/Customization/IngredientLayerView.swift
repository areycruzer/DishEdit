import SwiftUI

// MARK: - Ingredient Layer View

struct IngredientLayerView: View {
    let ingredient: IngredientDefinition
    let transform: IngredientTransform
    let isPresent: Bool
    let canToggle: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            BundledImage.image(named: ingredient.layerAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 80 * transform.scale, height: 80 * transform.scale)
                .opacity(isPresent ? transform.opacity : 0.3)
                .saturation(isPresent ? 1 : 0.3)
                .rotationEffect(.degrees(transform.rotationDegrees))

            Text(ingredient.name)
                .font(.caption2.bold())
                .foregroundStyle(isPresent ? .primary : .secondary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ingredient.accessibilityDescription)
        .accessibilityAddTraits(canToggle ? .isButton : .isStaticText)
        .accessibilityValue(isPresent ? "present" : "removed")
        .accessibilityHint(canToggle ? (isPresent ? "Double-tap to remove" : "Double-tap to add back") : "")
        .accessibilityIdentifier("layer.\(ingredient.id)")
        .accessibilityAction(named: isPresent ? "Remove" : "Restore") {
            onTap()
        }
    }
}
