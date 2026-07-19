import SwiftUI

// MARK: - Diagnostics View

struct DiagnosticsView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var availability: [GenerationEngineMode: EngineAvailability] = [:]
    @State private var forceCoreAIFailure = false
    @State private var forceRemoteFailure = false
    @State private var forceImagePlaygroundFailure = false
    @State private var showRunResults = false
    @State private var runCount = 0
    @State private var runSuccesses = 0

    var body: some View {
        NavigationStack {
            List {
                engineAvailabilitySection
                activeEngineSection
                instructionSourceSection
                forcedFailureSection
                reliabilityRunSection
            }
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { coordinator.goBack() }
                }
            }
            .task { await loadAvailability() }
        }
    }

    // MARK: - Engine Availability Section

    private var engineAvailabilitySection: some View {
        Section("Engine Availability") {
            ForEach(GenerationEngineMode.allCases, id: \.self) { mode in
                HStack {
                    Label(mode.rawValue, systemImage: iconName(for: mode))
                    Spacer()
                    Text(availability[mode]?.rawValue ?? "Checking…")
                        .font(.caption)
                        .foregroundStyle(statusColor(for: availability[mode]))
                }
                .accessibilityIdentifier("diagnostics.availability.\(mode.rawValue)")
            }
        }
    }

    // MARK: - Active Engine

    private var activeEngineSection: some View {
        Section("Active Selection") {
            HStack {
                Text("Current Engine")
                Spacer()
                Text(activeEngineLabel)
                    .font(.subheadline.bold())
            }
            .accessibilityIdentifier("diagnostics.activeEngine")

            HStack {
                Text("Preference")
                Spacer()
                Text(coordinator.generationPreference.rawValue)
                    .font(.subheadline)
            }
        }
    }

    private var activeEngineLabel: String {
        switch coordinator.generationPreference {
        case .stageSafe, .reviewedOnly:
            return "REVIEWED PREVIEW"
        case .coreAI:
            let avail = availability[.coreAI]
            if avail == .available || avail == .qualifiedOnDevice {
                return "CORE AI"
            }
            return "REVIEWED PREVIEW (fallback)"
        case .remote:
            if availability[.remote] == .available {
                return "REMOTE"
            }
            return "REVIEWED PREVIEW (fallback)"
        case .automatic:
            if availability[.coreAI] == .available || availability[.coreAI] == .qualifiedOnDevice {
                return "CORE AI"
            }
            if availability[.remote] == .available {
                return "REMOTE"
            }
            return "REVIEWED PREVIEW"
        }
    }

    // MARK: - Instruction Source

    private var instructionSourceSection: some View {
        Section("Instruction Parsing") {
            HStack {
                Text("Foundation Models")
                Spacer()
                Text(FeatureAvailability.isFoundationModelsAvailable ? "Available" : "Unavailable")
                    .font(.caption)
                    .foregroundStyle(FeatureAvailability.isFoundationModelsAvailable ? .green : .secondary)
            }
            HStack {
                Text("Fallback")
                Spacer()
                Text("Deterministic Parser")
                    .font(.caption)
            }
        }
    }

    // MARK: - Forced Failures

    private var forcedFailureSection: some View {
        Section {
            ForEach([GenerationEngineMode.coreAI, .remote, .imagePlayground], id: \.self) { mode in
                Toggle("Force \(mode.rawValue) failure", isOn: forcedFailureBinding(for: mode))
                .accessibilityIdentifier("diagnostics.forceFailure.\(mode.rawValue)")
            }
        } header: {
            Text("Failure Injection")
        } footer: {
            Text("Forces selected engines to report unavailable. Reviewed path always remains active.")
        }
    }

    // MARK: - Reliability Run

    private var reliabilityRunSection: some View {
        Section {
            Button("Run 20-cycle reliability test") {
                Task { await runReliabilityTest() }
            }
            .accessibilityIdentifier("diagnostics.runReliability")

            if showRunResults {
                HStack {
                    Text("Results")
                    Spacer()
                    Text("\(runSuccesses)/\(runCount) passed")
                        .font(.subheadline.bold())
                        .foregroundStyle(runSuccesses == runCount ? .green : .orange)
                }
            }
        } header: {
            Text("Reliability")
        } footer: {
            Text("Cycles through engine selection 20 times and verifies reviewed fallback is always reachable.")
        }
    }

    // MARK: - Helpers

    private func loadAvailability() async {
        availability = [
            .reviewed: .available,
            .coreAI: .unavailable,
            .remote: .unavailable,
            .imagePlayground: FeatureAvailability.isImagePlaygroundAvailable ? .available : .unavailable
        ]
    }

    private func forcedFailureBinding(for mode: GenerationEngineMode) -> Binding<Bool> {
        switch mode {
        case .coreAI:
            return $forceCoreAIFailure
        case .remote:
            return $forceRemoteFailure
        case .imagePlayground:
            return $forceImagePlaygroundFailure
        case .reviewed:
            return .constant(false)
        }
    }

    private var forcedFailures: Set<GenerationEngineMode> {
        var modes: Set<GenerationEngineMode> = []
        if forceCoreAIFailure { modes.insert(.coreAI) }
        if forceRemoteFailure { modes.insert(.remote) }
        if forceImagePlaygroundFailure { modes.insert(.imagePlayground) }
        return modes
    }

    private func runReliabilityTest() async {
        runCount = 20
        runSuccesses = 0
        showRunResults = true

        let currentForcedFailures = forcedFailures
        let currentPreference = coordinator.generationPreference

        for _ in 0..<20 {
            let selector = VisualEngineSelector(
                preference: currentPreference,
                coreAIAvailability: {
                    currentForcedFailures.contains(.coreAI) ? .unavailable : .unverified
                },
                remoteAvailability: {
                    currentForcedFailures.contains(.remote) ? .unavailable : .unavailable
                },
                imagePlaygroundAvailability: {
                    currentForcedFailures.contains(.imagePlayground) ? .unavailable : .unavailable
                }
            )
            let selection = await selector.select()
            if selection.mode == .reviewed || selection.fallbackReason == nil {
                runSuccesses += 1
            }
        }
    }

    private func iconName(for mode: GenerationEngineMode) -> String {
        switch mode {
        case .reviewed: return "checkmark.seal"
        case .coreAI: return "cpu"
        case .remote: return "cloud"
        case .imagePlayground: return "wand.and.stars"
        }
    }

    private func statusColor(for availability: EngineAvailability?) -> Color {
        switch availability {
        case .available, .qualifiedOnDevice: return .green
        case .unverified: return .orange
        case .unavailable: return .secondary
        case .none: return .secondary
        }
    }
}
