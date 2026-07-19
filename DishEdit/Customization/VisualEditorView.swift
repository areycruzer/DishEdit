import SwiftUI

struct VisualEditorView: View {
    @Bindable var appCoordinator: AppCoordinator
    let productID: String

    @State private var coordinator: CustomizationCoordinator
    @State private var heroAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(appCoordinator: AppCoordinator, productID: String) {
        self.appCoordinator = appCoordinator
        self.productID = productID
        let product = appCoordinator.restaurant.product(id: productID)!
        self._coordinator = State(initialValue: CustomizationCoordinator(
            product: product,
            draft: appCoordinator.draft(for: productID)
        ))
    }

    var body: some View {
        ZStack {
            DishEditBackdrop()

            VStack(spacing: 0) {
                header

                if coordinator.phase == .opening {
                    openingStage
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    expandedEditor
                        .transition(.opacity)
                }
            }

            if coordinator.phase == .reassembling {
                ReassemblyOverlay(
                    product: coordinator.product,
                    modifierSummary: coordinator.modifierSummary,
                    basePricePaise: coordinator.product.basePricePaise,
                    priceDeltaPaise: coordinator.priceDeltaPaise,
                    previewAssetName: curatedPreviewAsset,
                    onDone: finishCustomization
                )
                .transition(.opacity.combined(with: .scale(scale: 1.02)))
                .zIndex(20)
            }
        }
        .preferredColorScheme(.dark)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.52, dampingFraction: 0.86), value: coordinator.phase)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { heroAppeared = true }
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-DishEditDemoReassembly") {
                coordinator.expand()
                if let removal = coordinator.product.removableIngredients.first {
                    _ = coordinator.removeIngredient(id: removal.id)
                }
                if let addition = coordinator.product.addableIngredients.first {
                    _ = coordinator.addIngredient(id: addition.id)
                }
                persistDraft()
                coordinator.confirm()
            } else if arguments.contains("-DishEditDemoExpanded") {
                coordinator.expand()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                persistDraft()
                appCoordinator.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
            }
            .buttonStyle(DishGlassIconButtonStyle())
            .accessibilityLabel("Back")
            .accessibilityIdentifier("editor.back")

            VStack(alignment: .leading, spacing: 1) {
                Text("DishEdit")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.dishRed)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .accessibilityIdentifier("customization.\(productID)")
                Text(coordinator.product.name)
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("YOUR DISH")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.dishMuted)
                    .tracking(0.8)
                Text(INR.format(coordinator.product.basePricePaise + coordinator.priceDeltaPaise))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.dishWarm)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var openingStage: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)

            ZStack(alignment: .bottom) {
                Circle()
                    .fill(Color.dishRed.opacity(0.19))
                    .frame(width: 280, height: 280)
                    .blur(radius: 55)

                BundledImage.image(named: coordinator.product.assembledAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 430)
                    .scaleEffect(heroAppeared ? 1 : 0.92)
                    .opacity(heroAppeared ? 1 : 0)
                    .shadow(color: .black.opacity(0.7), radius: 28, y: 18)
                    .accessibilityLabel(coordinator.product.name)

                LinearGradient(
                    colors: [.clear, Color.dishCanvas.opacity(0.88)],
                    startPoint: UnitPoint(x: 0.5, y: 0.68),
                    endPoint: .bottom
                )
                .frame(height: 100)
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 430)
            .clipped()

            VStack(spacing: 10) {
                DishStatusPill(icon: "hand.tap.fill", text: "THE DISH IS THE CONTROL")

                Text("Touch your food")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("Pull it apart, tap an ingredient to remove it, or drag a new one into the recipe.")
                    .font(.subheadline)
                    .foregroundStyle(Color.dishMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 18)

            Button {
                HapticDirector.selection()
                coordinator.expand()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.3.layers.3d.down.right")
                    Text("Open ingredients")
                    Image(systemName: "arrow.up.right")
                        .font(.subheadline.bold())
                }
            }
            .buttonStyle(DishPrimaryButtonStyle())
            .accessibilityLabel("Open")
            .accessibilityIdentifier("editor.expand")
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }

    private var expandedEditor: some View {
        VStack(spacing: 0) {
            instructionRail

            ExplodedDishCanvas(
                product: coordinator.product,
                transforms: reduceMotion
                    ? IngredientLayout.reduceMotion(for: coordinator.product)
                    : coordinator.currentTransforms,
                presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                onIngredientTap: handleIngredientTap,
                onIngredientDrop: handleAddTap
            )
            .frame(maxWidth: .infinity)
            .frame(height: 410)
            .padding(.horizontal, 10)

            changeRail
                .frame(height: 42)

            editorControls

            IngredientTrayView(
                addableIngredients: coordinator.product.addableIngredients,
                presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                onAdd: handleAddTap
            )
            .padding(.bottom, 6)
        }
    }

    private var instructionRail: some View {
        HStack(spacing: 8) {
            DishStatusPill(icon: "hand.tap", text: "TAP TO REMOVE", tint: .dishRed)
            DishStatusPill(icon: "hand.draw", text: "DRAG TO ADD", tint: .dishWarm)
            Spacer()
            Text("\(coordinator.draft.presentIngredientIDs.count) layers")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Color.dishMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var changeRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if coordinator.modifierSummary.isEmpty {
                    Label("No changes yet", systemImage: "circle.dashed")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                } else {
                    ForEach(coordinator.modifierSummary, id: \.ingredientID) { item in
                        Button { restore(item.ingredientID) } label: {
                            Label(item.label, systemImage: "xmark")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 7)
                                .background(Color.dishRed.opacity(0.17), in: Capsule())
                                .overlay(Capsule().stroke(Color.dishRed.opacity(0.38), lineWidth: 0.8))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Restore the default ingredient state")
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var editorControls: some View {
        HStack(spacing: 10) {
            controlButton(icon: "arrow.uturn.backward", label: "Undo", enabled: !coordinator.draft.history.isEmpty) {
                _ = coordinator.undo()
                persistDraft()
            }
            .accessibilityIdentifier("editor.undo")

            controlButton(icon: "arrow.uturn.forward", label: "Redo", enabled: !coordinator.draft.future.isEmpty) {
                _ = coordinator.redo()
                persistDraft()
            }
            .accessibilityIdentifier("editor.redo")

            controlButton(icon: "arrow.counterclockwise", label: "Reset", enabled: coordinator.hasChanges) {
                _ = coordinator.reset()
                persistDraft()
            }
            .accessibilityIdentifier("editor.reset")

            Spacer(minLength: 4)

            Button {
                persistDraft()
                coordinator.confirm()
            } label: {
                HStack(spacing: 8) {
                    Text("Confirm")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(height: 46)
                .background(Color.dishRed, in: RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.dishRed.opacity(0.32), radius: 14, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("editor.confirm")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func controlButton(
        icon: String,
        label: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(.white.opacity(0.1), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
        .foregroundStyle(enabled ? Color.white : Color.white.opacity(0.24))
        .disabled(!enabled)
        .accessibilityLabel(label)
    }

    private var curatedPreviewAsset: String {
        coordinator.product.visualPreviewAsset(
            removedIngredientIDs: coordinator.draft.removedIngredientIDs,
            addedIngredientIDs: coordinator.draft.addedIngredientIDs
        ) ?? coordinator.product.assembledAssetName
    }

    private func handleIngredientTap(_ ingredientID: String) {
        guard coordinator.phase == .expanded,
              let ingredient = coordinator.product.ingredient(id: ingredientID) else { return }

        if coordinator.isIngredientPresent(id: ingredientID) {
            if ingredient.defaultPresence {
                guard ingredient.canRemove else {
                    HapticDirector.reject()
                    return
                }
                _ = coordinator.removeIngredient(id: ingredientID)
            } else if ingredient.canAdd {
                _ = coordinator.restoreIngredient(id: ingredientID)
            } else {
                HapticDirector.reject()
                return
            }
        } else {
            _ = coordinator.restoreIngredient(id: ingredientID)
        }
        persistDraft()
    }

    private func handleAddTap(_ ingredientID: String) {
        guard coordinator.phase == .expanded else { return }
        if coordinator.isIngredientPresent(id: ingredientID) {
            _ = coordinator.restoreIngredient(id: ingredientID)
        } else {
            _ = coordinator.addIngredient(id: ingredientID)
        }
        persistDraft()
    }

    private func restore(_ ingredientID: String) {
        _ = coordinator.restoreIngredient(id: ingredientID)
        persistDraft()
    }

    private func persistDraft() {
        appCoordinator.replaceDraft(coordinator.draft, for: productID)
    }

    private func finishCustomization() {
        persistDraft()
        coordinator.finishReassembly()
        appCoordinator.confirmCustomization(productID: productID)
    }
}

#Preview {
    VisualEditorView(appCoordinator: AppCoordinator(), productID: "burger")
}
