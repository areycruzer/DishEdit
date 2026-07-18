import Foundation
import Observation
import OSLog
import UIKit

@MainActor
@Observable
final class DishEditCoordinator {
    enum Phase: String, Sendable {
        case ready
        case resolvingModifier
        case animatingImmediatePreview
        case committed
    }

    let catalog: DishCatalog
    private(set) var selectedDishID: String
    private(set) var states: [String: DishEditState]
    private(set) var phase = Phase.ready
    private(set) var lastEngine = EditEngineKind.catalogPatch
    private(set) var lastMaskSource = "CATALOG MASK"
    private(set) var lastDurationMilliseconds = 0
    private(set) var lastActionDescription = "Ready"
    private(set) var reconstruction: ReconstructionSession?
    private(set) var rejectedTapPulse = 0
    private(set) var acceptedEditPulse = 0
    var forceCatalogFallback = true

    private var displayedVisualStateKeys: [String: VisualStateKey]
    private let reconstructionTimeline: ReconstructionTimeline
    @ObservationIgnored private var reconstructionTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "com.swiftdidload.DishEdit", category: "editing")
    private let signposter = OSSignposter(subsystem: "com.swiftdidload.DishEdit", category: "editing")

    init(
        catalog: DishCatalog = .preview,
        reconstructionDuration: TimeInterval? = nil
    ) {
        self.catalog = catalog
        let firstID = catalog.dishes.first?.id ?? "burger"
        selectedDishID = firstID
        states = Dictionary(uniqueKeysWithValues: catalog.dishes.map { ($0.id, DishEditState(dish: $0)) })
        displayedVisualStateKeys = Dictionary(uniqueKeysWithValues: catalog.dishes.map { ($0.id, "base") })
        let usesFastTimeline = ProcessInfo.processInfo.arguments.contains("-DishEditFastReconstruction")
        reconstructionTimeline = ReconstructionTimeline(
            duration: reconstructionDuration ?? (usesFastTimeline ? 0.16 : 5.4)
        )
    }

    var dish: DishDefinition {
        catalog.dish(id: selectedDishID) ?? catalog.dishes[0]
    }

    var state: DishEditState {
        states[selectedDishID] ?? DishEditState(dish: dish)
    }

    var activeModifiers: [ModifierDefinition] {
        dish.modifiers.filter { state.activeModifierIDs.contains($0.id) }
    }

    var imageAssetName: String { state.visualAssetName }
    var displayedVisualStateKey: VisualStateKey {
        displayedVisualStateKeys[selectedDishID] ?? "base"
    }
    var totalPricePaise: Int { state.totalPricePaise }

    func selectDish(_ id: String) {
        guard catalog.dish(id: id) != nil else { return }
        settleReconstructionImmediately()
        selectedDishID = id
        phase = .ready
        lastActionDescription = "Selected \(dish.name)"
    }

    func toggleRemoval(_ modifier: ModifierDefinition) {
        guard modifier.kind == .removal, dish.modifier(id: modifier.id) != nil else {
            rejectIngredientTap()
            return
        }

        if state.activeModifierIDs.contains(modifier.id) {
            restore(modifierID: modifier.id)
        } else {
            apply(modifier: modifier)
        }
    }

    func rejectIngredientTap() {
        phase = .ready
        rejectedTapPulse &+= 1
        HapticDirector.reject()
        lastActionDescription = "Nothing editable there"
    }

    func add(_ modifier: ModifierDefinition, at point: NormalizedPoint) -> Bool {
        guard ModifierResolver.acceptsDrop(at: point, modifier: modifier) else {
            rejectedTapPulse &+= 1
            HapticDirector.reject()
            lastActionDescription = "Drop on the highlighted food zone"
            return false
        }

        guard !state.activeModifierIDs.contains(modifier.id) else {
            HapticDirector.selection()
            return true
        }
        apply(modifier: modifier)
        return true
    }

    func addAccessibly(_ modifier: ModifierDefinition) {
        guard let anchor = modifier.approvedAnchors.first else { return }
        let point = NormalizedPoint(x: anchor.x + anchor.width / 2, y: anchor.y + anchor.height / 2)
        _ = add(modifier, at: point)
    }

    func restore(modifierID: String) {
        guard let modifier = dish.modifier(id: modifierID), state.activeModifierIDs.contains(modifierID) else {
            return
        }
        let sourceStateKey = displayedVisualStateKey
        mutateState { $0.restore(modifierID: modifierID) }
        acceptedEditPulse &+= 1
        phase = .committed
        lastActionDescription = "Restored ingredient"
        HapticDirector.selection()
        announce("Ingredient restored. Total \(formattedTotal).")
        logger.info("Restored modifier \(modifierID, privacy: .public)")
        startReconstruction(from: sourceStateKey, modifier: modifier)
    }

    func undo() {
        guard state.canUndo else { return }
        let sourceStateKey = displayedVisualStateKey
        let changedModifier = changedModifierForUndo()
        mutateState { $0.undo() }
        acceptedEditPulse &+= 1
        phase = .committed
        lastActionDescription = "Undid edit"
        HapticDirector.selection()
        announce("Edit undone. Total \(formattedTotal).")
        startReconstruction(from: sourceStateKey, modifier: changedModifier)
    }

    func redo() {
        guard state.canRedo else { return }
        let sourceStateKey = displayedVisualStateKey
        let previousIDs = state.activeModifierIDs
        mutateState { $0.redo() }
        acceptedEditPulse &+= 1
        phase = .committed
        lastActionDescription = "Redid edit"
        HapticDirector.selection()
        announce("Edit redone. Total \(formattedTotal).")
        let changedID = state.activeModifierIDs.symmetricDifference(previousIDs).first
        startReconstruction(from: sourceStateKey, modifier: changedID.flatMap(dish.modifier(id:)))
    }

    func reset() {
        let sourceStateKey = displayedVisualStateKey
        let modifier = activeModifiers.first
        mutateState { $0.reset() }
        acceptedEditPulse &+= 1
        phase = .ready
        lastActionDescription = "Dish reset"
        HapticDirector.selection()
        announce("Dish reset. Total \(formattedTotal).")
        startReconstruction(from: sourceStateKey, modifier: modifier)
    }

    private func apply(modifier: ModifierDefinition) {
        let signpostID = signposter.makeSignpostID()
        let interval = signposter.beginInterval("Immediate catalog preview", id: signpostID)
        defer { signposter.endInterval("Immediate catalog preview", interval) }
        let clock = ContinuousClock()
        let start = clock.now
        let sourceStateKey = displayedVisualStateKey
        phase = .animatingImmediatePreview
        mutateState { $0.apply(modifierID: modifier.id) }
        lastMaskSource = "CATALOG MASK"
        lastEngine = .catalogPatch
        lastDurationMilliseconds = Int(start.duration(to: clock.now).components.attoseconds / 1_000_000_000_000_000)
        acceptedEditPulse &+= 1
        phase = .committed
        lastActionDescription = modifier.shortLabel
        HapticDirector.commit(kind: modifier.kind)
        announce("\(modifier.shortLabel). Total \(formattedTotal).")
        logger.info("Committed modifier \(modifier.id, privacy: .public) at revision \(self.state.revision)")
        startReconstruction(from: sourceStateKey, modifier: modifier)
    }

    @discardableResult
    func completeReconstruction(revision: UInt64) -> Bool {
        guard let session = reconstruction,
              session.dishID == selectedDishID,
              session.revision == revision,
              state.revision == revision else {
            return false
        }
        displayedVisualStateKeys[session.dishID] = session.destinationStateKey
        reconstruction = nil
        reconstructionTask = nil
        phase = .committed
        lastActionDescription = "Visual preview ready"
        HapticDirector.selection()
        announce("Visual preview ready.")
        return true
    }

    private func startReconstruction(
        from sourceStateKey: VisualStateKey,
        modifier: ModifierDefinition?
    ) {
        reconstructionTask?.cancel()
        reconstructionTask = nil
        let destination = state.visualStateKey
        guard sourceStateKey != destination, let modifier else {
            displayedVisualStateKeys[selectedDishID] = destination
            reconstruction = nil
            return
        }

        let session = ReconstructionSession(
            dishID: selectedDishID,
            revision: state.revision,
            sourceStateKey: sourceStateKey,
            destinationStateKey: destination,
            modifierID: modifier.id,
            maskAssetName: modifier.authorMaskAsset,
            startedAt: Date(),
            timeline: reconstructionTimeline
        )
        reconstruction = session
        phase = .animatingImmediatePreview
        announce("Rebuilding visual preview on device.")
        reconstructionTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(session.timeline.duration))
            guard !Task.isCancelled else { return }
            self?.completeReconstruction(revision: session.revision)
        }
    }

    private func settleReconstructionImmediately() {
        reconstructionTask?.cancel()
        reconstructionTask = nil
        displayedVisualStateKeys[selectedDishID] = state.visualStateKey
        reconstruction = nil
    }

    private func changedModifierForUndo() -> ModifierDefinition? {
        guard let previousIDs = state.history.last?.activeModifierIDs else { return activeModifiers.last }
        let changedID = state.activeModifierIDs.symmetricDifference(previousIDs).first
        return changedID.flatMap(dish.modifier(id:))
    }

    private func mutateState(_ mutation: (inout DishEditState) -> Void) {
        guard var value = states[selectedDishID] else { return }
        mutation(&value)
        states[selectedDishID] = value
    }

    private var formattedTotal: String { "₹\(totalPricePaise / 100)" }

    private func announce(_ message: String) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

@MainActor
enum HapticDirector {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func reject() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func anchor() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.75)
    }

    static func commit(kind: ModifierDefinition.Kind) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = kind == .removal ? .medium : .soft
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: 0.9)
    }
}
