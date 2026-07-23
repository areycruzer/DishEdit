import SwiftUI

struct InstructionReviewView: View {
    @Bindable var coordinator: AppCoordinator
    let productID: String

    @State private var proposal: InstructionProposal?
    @State private var validation: InstructionValidationResult?
    @State private var showAllergySheet = false
    @State private var commitsItemAfterAcknowledgement = false
    @State private var isDrafting = true
    @FocusState private var isCustomerNoteFocused: Bool

    private var product: ProductDefinition? { coordinator.restaurant.product(id: productID) }
    private var draft: CustomizationDraft? { coordinator.drafts[productID] }

    var body: some View {
        ZStack(alignment: .bottom) {
            DishEditBackdrop()

            VStack(spacing: 0) {
                headerBar
                ScrollView {
                    VStack(spacing: 16) {
                        dishRecap
                        kitchenInstructionCard
                        customerNoteCard
                        allergenNotice
                        intelligenceDisclosure
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            commitBar
        }
        .preferredColorScheme(.light)
        .task { await generateProposal() }
        .sheet(isPresented: $showAllergySheet) {
            AllergyAcknowledgementSheet(
                allergens: proposal?.allergenFlags ?? [],
                isAcknowledged: coordinator.allergyAcknowledged,
                onAcknowledge: {
                    coordinator.setAllergyAcknowledged(true)
                    if commitsItemAfterAcknowledgement {
                        commitsItemAfterAcknowledgement = false
                        coordinator.commitToCart(productID: productID)
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isCustomerNoteFocused = false
                }
                .accessibilityIdentifier("customerNote.done")
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(DishGlassIconButtonStyle())
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 1) {
                Text("CUSTOMISATION")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(Color.dishRed)
                Text("Cooking instructions")
                    .font(.headline)
            }

            Spacer()

            Image(systemName: "text.document.fill")
                .foregroundStyle(Color.sushiRed)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var dishRecap: some View {
        if let product {
            HStack(spacing: 14) {
                BundledImage.image(named: product.visualPreviewAsset(
                    removedIngredientIDs: draft?.removedIngredientIDs ?? [],
                    addedIngredientIDs: draft?.addedIngredientIDs ?? []
                ) ?? product.assembledAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 106, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    DishStatusPill(icon: "checkmark", text: "Customisation saved", tint: .dishSuccess)
                    Text(product.name)
                        .font(.title3.bold())
                    Text("Review what the restaurant will receive with your order.")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .dishCard(radius: 24)
        }
    }

    private var kitchenInstructionCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR CHANGES")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.4)
                        .foregroundStyle(Color.dishRed)
                    Text("Based on your selected ingredients")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                }
                Spacer()
                if isDrafting {
                    ProgressView().tint(Color.dishRed)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.dishSuccess)
                }
            }

            if let proposal, !proposal.instructions.isEmpty {
                ForEach(proposal.instructions) { instruction in
                    InstructionRow(instruction: instruction)
                }
            } else if isDrafting {
                HStack(spacing: 10) {
                    ProgressView().tint(Color.sushiRed)
                    Text("Preparing your instructions…")
                        .font(.subheadline)
                        .foregroundStyle(Color.dishMuted)
                }
                .padding(.vertical, 10)
            } else {
                Label("Prepare as listed by the restaurant", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.dishSuccess)
            }

            if let validation, !validation.warnings.isEmpty {
                ForEach(validation.warnings, id: \.self) { warning in
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.dishWarm)
                }
            }
        }
        .padding(17)
        .dishCard(radius: 22)
    }

    private var customerNoteCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ADD A COOKING REQUEST")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(Color.dishRed)
                    Text("Optional note for the restaurant")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                }
                Spacer()
                Text("Optional")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.sushiGrey)
            }

            TextField(
                "For example: I don't like onions. Please pack sauce separately.",
                text: Binding(
                    get: { coordinator.customerNote },
                    set: { coordinator.updateCustomerNote($0) }
                ),
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .font(.body)
            .lineLimit(3...5)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .background(Color.sushiCanvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.sushiDivider, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .focused($isCustomerNoteFocused)
            .submitLabel(.done)
            .onSubmit { isCustomerNoteFocused = false }
            .accessibilityLabel("Kitchen note")
            .accessibilityIdentifier("customerNote")

            Label("This note is sent with your selected customisations.", systemImage: "text.bubble.fill")
                .font(.system(size: 9))
                .foregroundStyle(Color.dishMuted)
        }
        .padding(17)
        .dishCard(radius: 22)
    }

    private var allergenNotice: some View {
        Button { showAllergySheet = true } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.dishWarm)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Allergen confirmation")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.sushiCoal)
                    Text("The restaurant cannot guarantee an allergen-free preparation. Contact the restaurant if you have a severe allergy.")
                        .font(.caption)
                        .foregroundStyle(Color.dishMuted)
                        .fixedSize(horizontal: false, vertical: true)
                    if let flags = proposal?.allergenFlags, !flags.isEmpty {
                        Text("Catalog flags: \(flags.sorted().joined(separator: ", "))")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.dishWarm)
                    } else if noteMentionsAllergy {
                        Text("Your kitchen note mentions an allergy — acknowledgement required")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.dishWarm)
                    }
                }

                Spacer(minLength: 4)
                Image(systemName: coordinator.allergyAcknowledged ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(coordinator.allergyAcknowledged ? Color.dishSuccess : Color.dishMuted)
            }
            .padding(16)
            .background(Color.dishWarm.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.dishWarm.opacity(0.28), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("allergenBanner")
    }

    private var intelligenceDisclosure: some View {
        Label(
            "Your ingredient selections remain unchanged when this note is added.",
            systemImage: "checkmark.shield.fill"
        )
        .font(.caption)
        .foregroundStyle(Color.dishMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private var commitBar: some View {
        VStack(spacing: 8) {
            Button {
                commitItem()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("ADD ITEM")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1)
                        Text(requiresAllergyAcknowledgement ? "Review allergen notice" : "Customisations included")
                            .font(.caption.bold())
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(DishPrimaryButtonStyle())
            .disabled(isDrafting)
            .accessibilityIdentifier("commitButton")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .top) { Rectangle().fill(Color.sushiDivider).frame(height: 1) }
    }

    private var requiresAllergyAcknowledgement: Bool {
        let catalogFlags = proposal?.allergenFlags ?? []
        return !catalogFlags.isEmpty || noteMentionsAllergy
    }

    private func commitItem() {
        guard !isDrafting else { return }
        guard requiresAllergyAcknowledgement, !coordinator.allergyAcknowledged else {
            coordinator.commitToCart(productID: productID)
            return
        }

        commitsItemAfterAcknowledgement = true
        showAllergySheet = true
    }

    private var noteMentionsAllergy: Bool {
        let note = coordinator.customerNote.lowercased()
        let signals = ["allergy", "allergic", "peanut", "nuts", "nut allergy", "gluten", "dairy allergy", "shellfish"]
        return signals.contains { note.contains($0) }
    }

    @MainActor
    private func generateProposal() async {
        guard let product, let draft else {
            isDrafting = false
            return
        }

        let drafter = CompositeInstructionDrafter()
        let generated = await drafter.draft(
            product: product,
            customization: draft,
            strategy: .foundationModelWithFallback
        )
        guard !Task.isCancelled else { return }

        proposal = generated
        validation = InstructionValidator().validate(proposal: generated, against: product)
        isDrafting = false
    }
}

private struct InstructionRow: View {
    let instruction: KitchenInstruction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(instruction.displayText)
                    .font(.subheadline.bold())
                Text(instruction.detail)
                    .font(.caption)
                    .foregroundStyle(Color.dishMuted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption.bold())
                .foregroundStyle(Color.dishSuccess)
        }
        .padding(12)
        .background(Color.sushiCanvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.sushiDivider, lineWidth: 1))
    }

    private var iconName: String {
        switch instruction.verb {
        case .omit: "minus"
        case .add: "plus"
        case .substitute: "arrow.triangle.swap"
        }
    }

    private var iconColor: Color {
        instruction.verb == .omit ? .dishRed : .dishSuccess
    }
}

struct AllergyAcknowledgementSheet: View {
    let allergens: Set<String>
    let isAcknowledged: Bool
    let onAcknowledge: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DishEditBackdrop()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 43))
                    .foregroundStyle(Color.dishWarm)

                Text("Allergen notice")
                    .font(.title2.bold())

                Text("The restaurant cannot guarantee an allergen-free preparation. Cross-contact may occur in a shared kitchen.")
                    .font(.body)
                    .foregroundStyle(Color.dishMuted)
                    .multilineTextAlignment(.center)

                if !allergens.isEmpty {
                    Text("Catalog flags: \(allergens.sorted().joined(separator: ", "))")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.dishWarm)
                }

                Spacer()

                Button {
                    onAcknowledge()
                    dismiss()
                } label: {
                    Text(isAcknowledged ? "Acknowledged" : "I understand")
                }
                .buttonStyle(DishPrimaryButtonStyle())
                .disabled(isAcknowledged)
                .accessibilityIdentifier("acknowledgeButton")
            }
            .padding(24)
        }
        .preferredColorScheme(.light)
    }
}
