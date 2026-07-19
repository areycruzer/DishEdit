import SwiftUI

// MARK: - Generation Settings View

struct GenerationSettingsView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var preference: VisualGenerationPreference = .automatic
    @State private var availability: [GenerationEngineMode: EngineAvailability] = [
        .reviewed: .available,
        .coreAI: .unavailable,
        .remote: .unavailable,
        .imagePlayground: .unavailable
    ]

    var body: some View {
        NavigationStack {
            List {
                preferencePicker
                engineStatusSection
                stageSafeSection
            }
            .navigationTitle("Generation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { coordinator.goBack() }
                }
            }
        }
    }

    // MARK: - Preference Picker

    private var preferencePicker: some View {
        Section {
            Picker("Engine Selection", selection: $preference) {
                ForEach(VisualGenerationPreference.allCases, id: \.self) { pref in
                    Text(pref.rawValue).tag(pref)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: preference) { _, newValue in
                coordinator.generationPreference = newValue
            }
        } header: {
            Text("Preview Engine")
        } footer: {
            Text(preferenceDescription)
        }
    }

    private var preferenceDescription: String {
        switch preference {
        case .automatic:
            return "Selects the best available engine: Core AI if qualified, then Remote if configured, otherwise Reviewed."
        case .reviewedOnly:
            return "Always uses pre-reviewed preview assets. No generation."
        case .coreAI:
            return "Prefers on-device Core AI generation. Falls back to Reviewed if unavailable."
        case .remote:
            return "Prefers remote generation service. Falls back to Reviewed if unconfigured."
        case .stageSafe:
            return "Locks to Reviewed previews for stage presentations. No live generation."
        }
    }

    // MARK: - Engine Status

    private var engineStatusSection: some View {
        Section("Engine Status") {
            ForEach(GenerationEngineMode.allCases, id: \.self) { mode in
                HStack {
                    Text(mode.rawValue)
                    Spacer()
                    Text(statusLabel(for: mode))
                        .foregroundStyle(statusColor(for: mode))
                        .font(.subheadline)
                }
                .accessibilityIdentifier("settings.engine.\(mode.rawValue)")
            }
        }
    }

    private func statusLabel(for mode: GenerationEngineMode) -> String {
        availability[mode]?.rawValue ?? "Unknown"
    }

    private func statusColor(for mode: GenerationEngineMode) -> Color {
        switch availability[mode] {
        case .available, .qualifiedOnDevice:
            return .green
        case .unavailable:
            return .secondary
        case .unverified:
            return .orange
        case .none:
            return .secondary
        }
    }

    // MARK: - Stage Safe

    private var stageSafeSection: some View {
        Section {
            Toggle("Stage Safe Mode", isOn: Binding(
                get: { preference == .stageSafe },
                set: { enabled in
                    preference = enabled ? .stageSafe : .automatic
                    coordinator.generationPreference = preference
                }
            ))
        } footer: {
            Text("When enabled, locks all generation to reviewed previews. Use for live demos.")
        }
    }
}
