import SwiftUI

struct ExplodedDishCanvas: View {
    let product: ProductDefinition
    let transforms: [String: IngredientTransform]
    let presentIngredientIDs: Set<String>
    let onIngredientTap: (String) -> Void
    let onIngredientDrop: (String) -> Void
    var style: IngredientEditorStyle = .cinematic

    @State private var isDropTargeted = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                canvasBackdrop

                if isDropTargeted {
                    dropTarget
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                ForEach(visibleIngredients) { ingredient in
                    let transform = transforms[ingredient.id] ?? fallbackTransform
                    IngredientLayerView(
                        ingredient: ingredient,
                        transform: transform,
                        canvasSize: geometry.size,
                        isPresent: presentIngredientIDs.contains(ingredient.id),
                        canToggle: ingredient.canRemove || ingredient.canAdd,
                        style: style,
                        onTap: { onIngredientTap(ingredient.id) }
                    )
                    .zIndex(transform.zIndex)
                }

                VStack {
                    HStack {
                        if style == .cinematic {
                            Label(canvasTitle, systemImage: presentationIcon)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(.black.opacity(0.42), in: Capsule())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
                .allowsHitTesting(false)
            }
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .dropDestination(for: String.self) { ingredientIDs, _ in
                guard let ingredientID = ingredientIDs.first,
                      product.addableIngredients.contains(where: { $0.id == ingredientID }) else {
                    return false
                }
                HapticDirector.anchor()
                onIngredientDrop(ingredientID)
                return true
            } isTargeted: { targeted in
                withAnimation(.spring(response: 0.26, dampingFraction: 0.78)) {
                    isDropTargeted = targeted
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: style == .sushiCommerce ? 20 : 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: style == .sushiCommerce ? 20 : 28, style: .continuous)
                .stroke(
                    isDropTargeted
                        ? Color.sushiRed.opacity(0.85)
                        : (style == .sushiCommerce ? Color.sushiDivider : Color.white.opacity(0.11)),
                    lineWidth: isDropTargeted ? 1.6 : 0.8
                )
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(style == .sushiCommerce ? 0.08 : 0.42), radius: style == .sushiCommerce ? 8 : 22, y: style == .sushiCommerce ? 3 : 12)
        .animation(.spring(response: 0.48, dampingFraction: 0.82), value: presentIngredientIDs)
    }

    private var canvasBackdrop: some View {
        Group {
            if style == .sushiCommerce {
                ZStack {
                    Color.white
                    RadialGradient(
                        colors: [Color(red: 1, green: 0.97, blue: 0.92), .white],
                        center: .center,
                        startRadius: 15,
                        endRadius: 270
                    )
                }
            } else {
                cinematicBackdrop
            }
        }
    }

    private var cinematicBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white.opacity(0.055), Color.white.opacity(0.015)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.dishRed.opacity(0.16), .clear],
                center: .center,
                startRadius: 4,
                endRadius: 230
            )

            Canvas { context, size in
                var path = Path()
                let step: CGFloat = 28
                stride(from: 0, through: size.width, by: step).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                stride(from: 0, through: size.height, by: step).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(.white.opacity(0.022)), lineWidth: 0.5)
            }
        }
    }

    private var dropTarget: some View {
        ZStack {
            Circle()
                .fill((style == .sushiCommerce ? Color.sushiRed : Color.dishRed).opacity(0.1))
                .frame(width: 170, height: 170)
                .blur(radius: 8)
            Circle()
                .stroke(style == .sushiCommerce ? Color.sushiRed : Color.dishRed, style: StrokeStyle(lineWidth: 2, dash: [7, 7]))
                .frame(width: 130, height: 130)
            VStack(spacing: 7) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Drop to add")
                    .font(.caption.bold())
            }
            .foregroundStyle(style == .sushiCommerce ? Color.sushiCoal : .white)
        }
        .allowsHitTesting(false)
    }

    private var visibleIngredients: [IngredientDefinition] {
        product.ingredients.filter { ingredient in
            ingredient.defaultPresence || presentIngredientIDs.contains(ingredient.id)
        }
    }

    private var fallbackTransform: IngredientTransform {
        IngredientTransform(center: NormalizedPoint(x: 0.5, y: 0.5))
    }

    private var canvasTitle: String {
        switch product.presentation {
        case .explodedLayers: "EXPLODED RECIPE"
        case .sandwichCounter: "COUNTER VIEW"
        case .tacoFan: "OPEN WRAP"
        }
    }

    private var presentationIcon: String {
        switch product.presentation {
        case .explodedLayers: "square.3.layers.3d"
        case .sandwichCounter: "rectangle.3.group"
        case .tacoFan: "circle.hexagongrid"
        }
    }
}
