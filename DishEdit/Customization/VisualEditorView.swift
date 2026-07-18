import SwiftUI

// MARK: - Visual Editor View

struct VisualEditorView: View {
    @Bindable var appCoordinator: AppCoordinator
    let productID: String
    @State private var coordinator: CustomizationCoordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(appCoordinator: AppCoordinator, productID: String) {
        self.appCoordinator = appCoordinator
        self.productID = productID
        let product = appCoordinator.restaurant.product(id: productID)!
        self._coordinator = State(initialValue: CustomizationCoordinator(product: product))
    }

    var body: some View {
        editorContent(coordinator: coordinator)
            .background(.black)
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func editorContent(coordinator: CustomizationCoordinator) -> some View {
        ZStack {
            VStack(spacing: 0) {
                editorHeader(coordinator: coordinator)

                Spacer(minLength: 0)

                ExplodedDishCanvas(
                    product: coordinator.product,
                    transforms: reduceMotion
                        ? IngredientLayout.reduceMotion(for: coordinator.product)
                        : coordinator.currentTransforms,
                    presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                    onIngredientTap: { ingredientID in
                        handleIngredientTap(coordinator: coordinator, ingredientID: ingredientID)
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 400)

                Spacer(minLength: 0)

                editorToolbar(coordinator: coordinator)

                if coordinator.phase == .expanded {
                    IngredientTrayView(
                        addableIngredients: coordinator.product.addableIngredients,
                        presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                        onAdd: { ingredientID in
                            handleAddTap(coordinator: coordinator, ingredientID: ingredientID)
                        }
                    )
                }
            }

            if coordinator.phase == .reassembling {
                ReassemblyOverlay(
                    product: coordinator.product,
                    modifierSummary: coordinator.modifierSummary,
                    basePricePaise: coordinator.product.basePricePaise,
                    priceDeltaPaise: coordinator.priceDeltaPaise,
                    onDone: {
                        coordinator.finishReassembly()
                        appCoordinator.confirmCustomization(productID: productID)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: reduceMotion ? 0.01 : 0.4), value: coordinator.phase)
        .accessibilityIdentifier("visual-editor.\(productID)")
        // Marker for UI tests
        .overlay {
            Text("").accessibilityIdentifier("customization.\(productID)")
        }
    }

    private func editorHeader(coordinator: CustomizationCoordinator) -> some View {
        HStack {
            Button("Back") { appCoordinator.goBack() }
                .accessibilityIdentifier("editor.back")

            Spacer()

            Text(coordinator.product.name)
                .font(.headline)

            Spacer()

            Text(INR.format(coordinator.product.basePricePaise + coordinator.priceDeltaPaise))
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func editorToolbar(coordinator: CustomizationCoordinator) -> some View {
        HStack(spacing: 16) {
            Button { coordinator.undo() } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(coordinator.draft.history.isEmpty)
            .accessibilityIdentifier("editor.undo")

            Button { coordinator.redo() } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(coordinator.draft.future.isEmpty)
            .accessibilityIdentifier("editor.redo")

            Button { coordinator.reset() } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .disabled(!coordinator.hasChanges)
            .accessibilityIdentifier("editor.reset")

            Spacer()

            if coordinator.phase == .opening {
                Button("Open") {
                    coordinator.expand()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityIdentifier("editor.expand")
            } else if coordinator.phase == .expanded {
                Button("Confirm") {
                    coordinator.confirm()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .accessibilityIdentifier("editor.confirm")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func handleIngredientTap(coordinator: CustomizationCoordinator, ingredientID: String) {
        guard coordinator.phase == .expanded else { return }
        if coordinator.isIngredientPresent(id: ingredientID) {
            coordinator.removeIngredient(id: ingredientID)
        } else {
            coordinator.restoreIngredient(id: ingredientID)
        }
    }

    private func handleAddTap(coordinator: CustomizationCoordinator, ingredientID: String) {
        if coordinator.isIngredientPresent(id: ingredientID) {
            coordinator.restoreIngredient(id: ingredientID)
        } else {
            coordinator.addIngredient(id: ingredientID)
        }
    }
}
