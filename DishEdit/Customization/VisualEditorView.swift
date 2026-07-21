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
            Color.sushiCanvas.ignoresSafeArea()

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
        .preferredColorScheme(.light)
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

    private var isBurger: Bool { productID == "burger" }

    private var productNoun: String {
        switch productID {
        case "burger": "burger"
        case "sub": "sub"
        case "taco-wrap": "taco wrap"
        default: "dish"
        }
    }

    private var header: some View {
        burgerHeader
    }

    private var burgerHeader: some View {
        HStack(spacing: 12) {
            Button {
                persistDraft()
                appCoordinator.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.sushiCoal)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().stroke(Color.sushiDivider, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            .accessibilityIdentifier("editor.back")

            VStack(alignment: .leading, spacing: 2) {
                Text("Customize \(productNoun)")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.sushiCoal)
                    .accessibilityIdentifier("customization.\(productID)")
                Text(coordinator.product.name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.sushiGrey)
                    .lineLimit(1)
            }

            Spacer()

            Text(INR.format(coordinator.product.basePricePaise + coordinator.priceDeltaPaise))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.sushiCoal)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.sushiDivider).frame(height: 1)
        }
    }

    private var cinematicHeader: some View {
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
        burgerOpeningStage
    }

    private var burgerOpeningStage: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.sushiDivider, lineWidth: 1)
                    )

                Circle()
                    .fill(Color(red: 1, green: 0.96, blue: 0.91))
                    .frame(width: 250, height: 250)

                BundledImage.image(named: coordinator.product.assembledAssetName)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .scaleEffect(heroAppeared ? 1 : 0.94)
                    .opacity(heroAppeared ? 1 : 0)
                    .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
                    .accessibilityLabel(coordinator.product.name)
            }
            .frame(height: 390)
            .padding(.horizontal, 16)

            VStack(spacing: 7) {
                Text("Make it yours")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Color.sushiCoal)

                Text("See every layer, remove what you don't want, and add your favourites.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.sushiGrey)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
            }
            .padding(.top, 18)

            Spacer(minLength: 18)

            Button {
                HapticDirector.selection()
                coordinator.expand()
            } label: {
                HStack(spacing: 9) {
                    Text("Start customizing")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.sushiRed, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open")
            .accessibilityIdentifier("editor.expand")
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    private var cinematicOpeningStage: some View {
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
        burgerExpandedEditor
    }

    private var burgerExpandedEditor: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.sushiRed.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.sushiRed)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tap an ingredient to remove it")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.sushiCoal)
                    Text("Tap it again to bring it back")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.sushiGrey)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)

            ExplodedDishCanvas(
                product: coordinator.product,
                transforms: reduceMotion
                    ? IngredientLayout.reduceMotion(for: coordinator.product)
                    : coordinator.currentTransforms,
                presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                onIngredientTap: handleIngredientTap,
                onIngredientDrop: handleAddTap,
                style: .sushiCommerce
            )
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)

            changeRail
                .frame(height: coordinator.modifierSummary.isEmpty ? 30 : 40)

            IngredientTrayView(
                addableIngredients: coordinator.product.addableIngredients,
                presentIngredientIDs: coordinator.draft.presentIngredientIDs,
                onAdd: handleAddTap,
                style: .sushiCommerce
            )

            burgerEditorControls
        }
        .background(Color.sushiCanvas)
    }

    private var cinematicExpandedEditor: some View {
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
                    Text("Your \(productNoun) is unchanged")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.sushiGrey)
                } else {
                    ForEach(coordinator.modifierSummary, id: \.ingredientID) { item in
                        Button { restore(item.ingredientID) } label: {
                            Label(item.label, systemImage: "xmark")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.sushiRed)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 7)
                                .background(Color.sushiRed.opacity(0.08), in: Capsule())
                                .overlay(Capsule().stroke(Color.sushiRed.opacity(0.28), lineWidth: 0.8))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Restore the default ingredient state")
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var burgerEditorControls: some View {
        HStack(spacing: 10) {
            burgerControlButton(icon: "arrow.uturn.backward", label: "Undo", enabled: !coordinator.draft.history.isEmpty) {
                _ = coordinator.undo()
                persistDraft()
            }
            .accessibilityIdentifier("editor.undo")

            burgerControlButton(icon: "arrow.uturn.forward", label: "Redo", enabled: !coordinator.draft.future.isEmpty) {
                _ = coordinator.redo()
                persistDraft()
            }
            .accessibilityIdentifier("editor.redo")

            burgerControlButton(icon: "arrow.counterclockwise", label: "Reset", enabled: coordinator.hasChanges) {
                _ = coordinator.reset()
                persistDraft()
            }
            .accessibilityIdentifier("editor.reset")

            Button {
                persistDraft()
                coordinator.confirm()
            } label: {
                HStack(spacing: 7) {
                    Text("Review changes")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.sushiRed, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Review changes")
            .accessibilityIdentifier("editor.confirm")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.sushiDivider).frame(height: 1)
        }
    }

    private func burgerControlButton(
        icon: String,
        label: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
            }
            .frame(width: 48, height: 52)
            .foregroundStyle(enabled ? Color.sushiCoal : Color.sushiGrey.opacity(0.35))
            .background(Color.sushiCanvas, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(label)
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
