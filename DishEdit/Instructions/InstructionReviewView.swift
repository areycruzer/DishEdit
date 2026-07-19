import SwiftUI

// MARK: - Instruction Review View

struct InstructionReviewView: View {
    @Bindable var coordinator: AppCoordinator
    let productID: String

    @State private var proposal: InstructionProposal?
    @State private var validation: InstructionValidationResult?
    @State private var showAllergySheet = false

    private var product: ProductDefinition? {
        coordinator.restaurant.product(id: productID)
    }

    private var draft: CustomizationDraft? {
        coordinator.drafts[productID]
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 24) {
                    instructionList
                    customerNoteSection
                    if let proposal, !proposal.allergenFlags.isEmpty {
                        allergenBanner
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            commitBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .task { generateProposal() }
        .sheet(isPresented: $showAllergySheet) {
            AllergyAcknowledgementSheet(
                allergens: proposal?.allergenFlags ?? [],
                isAcknowledged: coordinator.allergyAcknowledged,
                onAcknowledge: { coordinator.setAllergyAcknowledged(true) }
            )
            .presentationDetents([.medium])
        }
        .accessibilityIdentifier("instructions.\(productID)")
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
            }
            .accessibilityLabel("Back")

            Spacer()

            Text("Review Order")
                .font(.headline)

            Spacer()

            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Instruction List

    private var instructionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kitchen Instructions")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let proposal {
                ForEach(proposal.instructions) { instruction in
                    InstructionRow(instruction: instruction)
                }
            } else {
                Text("No modifications")
                    .foregroundStyle(.tertiary)
            }

            if let validation, !validation.warnings.isEmpty {
                ForEach(validation.warnings, id: \.self) { warning in
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    // MARK: - Customer Note

    private var customerNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note for Kitchen")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Any special requests...", text: Binding(
                get: { coordinator.customerNote },
                set: { coordinator.updateCustomerNote($0) }
            ), axis: .vertical)
            .lineLimit(2...4)
            .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Allergen Banner

    private var allergenBanner: some View {
        Button { showAllergySheet = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "allergens")
                    .font(.title3)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Allergen Information")
                        .font(.subheadline.weight(.semibold))
                    Text(allergenSummaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if coordinator.allergyAcknowledged {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("allergenBanner")
    }

    private var allergenSummaryText: String {
        guard let flags = proposal?.allergenFlags, !flags.isEmpty else { return "" }
        return "Contains: " + flags.sorted().joined(separator: ", ")
    }

    // MARK: - Commit Bar

    private var commitBar: some View {
        VStack(spacing: 12) {
            Divider()
            Button {
                coordinator.commitToCart(productID: productID)
            } label: {
                Text("Add to Cart")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!canCommit)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .accessibilityIdentifier("commitButton")
        }
    }

    private var canCommit: Bool {
        guard let proposal else { return true }
        if !proposal.allergenFlags.isEmpty && !coordinator.allergyAcknowledged {
            return false
        }
        return true
    }

    // MARK: - Logic

    private func generateProposal() {
        guard let product, let draft else { return }
        let parser = DeterministicInstructionParser()
        let generated = parser.parse(product: product, draft: draft)

        if generated.instructions.isEmpty {
            proposal = nil
            validation = nil
            return
        }

        proposal = generated
        let validator = InstructionValidator()
        validation = validator.validate(proposal: generated, against: product)
    }
}

// MARK: - Instruction Row

private struct InstructionRow: View {
    let instruction: KitchenInstruction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(instruction.displayText)
                    .font(.body)
                if !instruction.allergenFlags.isEmpty {
                    Text(instruction.allergenFlags.sorted().joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            confidenceBadge
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    private var iconName: String {
        switch instruction.verb {
        case .omit: "minus.circle.fill"
        case .add: "plus.circle.fill"
        case .substitute: "arrow.triangle.swap"
        }
    }

    private var iconColor: Color {
        switch instruction.verb {
        case .omit: .red
        case .add: .green
        case .substitute: .blue
        }
    }

    @ViewBuilder
    private var confidenceBadge: some View {
        switch instruction.confidence {
        case .deterministic:
            EmptyView()
        case .high:
            Text("AI")
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.15), in: Capsule())
        case .low:
            Text("Review")
                .font(.caption2.bold())
                .foregroundStyle(.orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.orange.opacity(0.15), in: Capsule())
        }
    }
}

// MARK: - Allergy Acknowledgement Sheet

struct AllergyAcknowledgementSheet: View {
    let allergens: Set<String>
    let isAcknowledged: Bool
    let onAcknowledge: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "allergens")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Allergen Notice")
                .font(.title2.bold())

            Text("Your customization includes ingredients that contain the following allergens:")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                ForEach(allergens.sorted(), id: \.self) { allergen in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(allergen.capitalized)
                            .font(.body.weight(.medium))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer()

            Button {
                onAcknowledge()
                dismiss()
            } label: {
                Text("I Acknowledge")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(isAcknowledged)
            .accessibilityIdentifier("acknowledgeButton")
        }
        .padding(24)
    }
}
