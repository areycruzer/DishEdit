import SwiftUI

// MARK: - Exploded Dish Canvas

struct ExplodedDishCanvas: View {
    let product: ProductDefinition
    let transforms: [String: IngredientTransform]
    let presentIngredientIDs: Set<String>
    let onIngredientTap: (String) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(sortedIngredients) { ingredient in
                    let transform = transforms[ingredient.id] ?? fallbackTransform
                    let isPresent = presentIngredientIDs.contains(ingredient.id)
                    let canToggle = ingredient.canRemove && isPresent

                    IngredientLayerView(
                        ingredient: ingredient,
                        transform: transform,
                        isPresent: isPresent,
                        canToggle: canToggle,
                        onTap: { onIngredientTap(ingredient.id) }
                    )
                    .frame(height: 90)
                }
            }
            .padding(.vertical, 12)
        }
        .accessibilityIdentifier("exploded-canvas.\(product.id)")
    }

    private var sortedIngredients: [IngredientDefinition] {
        product.ingredients.sorted { lhs, rhs in
            let lz = transforms[lhs.id]?.zIndex ?? 0
            let rz = transforms[rhs.id]?.zIndex ?? 0
            return lz < rz
        }
    }

    private var fallbackTransform: IngredientTransform {
        IngredientTransform(center: NormalizedPoint(x: 0.5, y: 0.5))
    }
}
