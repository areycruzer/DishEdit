import Foundation

typealias VisualStateKey = String

nonisolated struct NormalizedPoint: Codable, Equatable, Sendable {
    let x: Double
    let y: Double
}

nonisolated struct NormalizedRect: Codable, Equatable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    func contains(_ point: NormalizedPoint) -> Bool {
        point.x >= x && point.x <= x + width
            && point.y >= y && point.y <= y + height
    }
}

nonisolated struct DepthLayerDefinition: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let assetName: String
    let depth: Double
}

nonisolated struct VisualStateDefinition: Codable, Equatable, Sendable {
    let assetName: String
    let accessibilityDescription: String
}

nonisolated struct ModifierDefinition: Identifiable, Codable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case removal
        case addition
    }

    let id: String
    let name: String
    let shortLabel: String
    let kind: Kind
    let priceDeltaPaise: Int
    let authorMaskAsset: String
    let trayAsset: String?
    let approvedAnchors: [NormalizedRect]
    let removalPrompt: String?
    let integrationPrompt: String?
    let deterministicSeed: UInt64
}

nonisolated struct DishDefinition: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let basePricePaise: Int
    let baseImageAsset: String
    let depthLayers: [DepthLayerDefinition]
    let modifiers: [ModifierDefinition]
    let fallbackStates: [VisualStateKey: VisualStateDefinition]

    func modifier(id: String) -> ModifierDefinition? {
        modifiers.first { $0.id == id }
    }

    var removalModifier: ModifierDefinition? {
        modifiers.first { $0.kind == .removal }
    }

    var additionModifier: ModifierDefinition? {
        modifiers.first { $0.kind == .addition }
    }
}

nonisolated struct DishCatalog: Sendable {
    let dishes: [DishDefinition]

    func dish(id: String) -> DishDefinition? {
        dishes.first { $0.id == id }
    }

    static let preview = DishCatalog(dishes: [.burger, .pizza, .waffle])
}

nonisolated struct EditSnapshot: Equatable, Sendable {
    let activeModifierIDs: Set<String>
}

nonisolated struct DishEditState: Equatable, Sendable {
    let dish: DishDefinition
    private(set) var activeModifierIDs: Set<String> = []
    private(set) var revision: UInt64 = 0
    private(set) var history: [EditSnapshot] = []
    private(set) var future: [EditSnapshot] = []

    init(dish: DishDefinition) {
        self.dish = dish
    }

    var visualStateKey: VisualStateKey {
        let hasRemoval = dish.removalModifier.map { activeModifierIDs.contains($0.id) } ?? false
        let hasAddition = dish.additionModifier.map { activeModifierIDs.contains($0.id) } ?? false

        return switch (hasRemoval, hasAddition) {
        case (false, false): "base"
        case (true, false): "removed"
        case (false, true): "added"
        case (true, true): "removed+added"
        }
    }

    var visualAssetName: String {
        dish.fallbackStates[visualStateKey]?.assetName ?? dish.baseImageAsset
    }

    var totalPricePaise: Int {
        dish.basePricePaise + dish.modifiers
            .filter { activeModifierIDs.contains($0.id) }
            .reduce(0) { $0 + $1.priceDeltaPaise }
    }

    var canUndo: Bool { !history.isEmpty }
    var canRedo: Bool { !future.isEmpty }

    mutating func apply(modifierID: String) {
        guard dish.modifier(id: modifierID) != nil,
              !activeModifierIDs.contains(modifierID) else {
            return
        }

        history.append(EditSnapshot(activeModifierIDs: activeModifierIDs))
        future.removeAll()
        activeModifierIDs.insert(modifierID)
        revision &+= 1
    }

    mutating func restore(modifierID: String) {
        guard activeModifierIDs.contains(modifierID) else { return }
        history.append(EditSnapshot(activeModifierIDs: activeModifierIDs))
        future.removeAll()
        activeModifierIDs.remove(modifierID)
        revision &+= 1
    }

    mutating func undo() {
        guard let previous = history.popLast() else { return }
        future.append(EditSnapshot(activeModifierIDs: activeModifierIDs))
        activeModifierIDs = previous.activeModifierIDs
        revision &+= 1
    }

    mutating func redo() {
        guard let next = future.popLast() else { return }
        history.append(EditSnapshot(activeModifierIDs: activeModifierIDs))
        activeModifierIDs = next.activeModifierIDs
        revision &+= 1
    }

    mutating func reset() {
        guard !activeModifierIDs.isEmpty else { return }
        history.append(EditSnapshot(activeModifierIDs: activeModifierIDs))
        future.removeAll()
        activeModifierIDs.removeAll()
        revision &+= 1
    }
}

private extension DishDefinition {
    nonisolated static let burger = DishDefinition(
        id: "burger",
        name: "The Classic",
        subtitle: "Charred beef · brioche · house sauce",
        basePricePaise: 24_900,
        baseImageAsset: "burger_base",
        depthLayers: [
            DepthLayerDefinition(id: "burger.body", assetName: "burger_base", depth: 0.45)
        ],
        modifiers: [
            ModifierDefinition(
                id: "burger.remove.tomato",
                name: "Remove tomato",
                shortLabel: "No tomato",
                kind: .removal,
                priceDeltaPaise: 0,
                authorMaskAsset: "burger_tomato_mask",
                trayAsset: nil,
                approvedAnchors: [],
                removalPrompt: "Reconstruct lettuce and patty where the tomato was removed while preserving the burger.",
                integrationPrompt: nil,
                deterministicSeed: 4_021
            ),
            ModifierDefinition(
                id: "burger.add.cheese",
                name: "Add cheese",
                shortLabel: "Cheese",
                kind: .addition,
                priceDeltaPaise: 4_000,
                authorMaskAsset: "burger_cheese_mask",
                trayAsset: "cheese_addon",
                approvedAnchors: [NormalizedRect(x: 0.18, y: 0.47, width: 0.64, height: 0.28)],
                removalPrompt: nil,
                integrationPrompt: "Integrate one cheddar slice between the tomato or lettuce and patty.",
                deterministicSeed: 9_117
            )
        ],
        fallbackStates: [
            "base": VisualStateDefinition(assetName: "burger_base", accessibilityDescription: "Burger with tomato and no cheese"),
            "removed": VisualStateDefinition(assetName: "burger_no_tomato", accessibilityDescription: "Burger without tomato"),
            "added": VisualStateDefinition(assetName: "burger_cheese", accessibilityDescription: "Burger with tomato and cheese"),
            "removed+added": VisualStateDefinition(assetName: "burger_no_tomato_cheese", accessibilityDescription: "Burger without tomato and with cheese")
        ]
    )

    nonisolated static let pizza = DishDefinition(
        id: "pizza",
        name: "Midnight Margherita",
        subtitle: "Fire-roasted tomato · basil · mozzarella",
        basePricePaise: 39_900,
        baseImageAsset: "pizza_base",
        depthLayers: [DepthLayerDefinition(id: "pizza.body", assetName: "pizza_base", depth: 0.42)],
        modifiers: [
            ModifierDefinition(
                id: "pizza.remove.olives",
                name: "Remove olives",
                shortLabel: "No olives",
                kind: .removal,
                priceDeltaPaise: 0,
                authorMaskAsset: "pizza_olives_mask",
                trayAsset: nil,
                approvedAnchors: [],
                removalPrompt: "Remove all olives and reconstruct cheese and sauce.",
                integrationPrompt: nil,
                deterministicSeed: 5_309
            ),
            ModifierDefinition(
                id: "pizza.add.jalapeno",
                name: "Add jalapeños",
                shortLabel: "Jalapeños",
                kind: .addition,
                priceDeltaPaise: 5_000,
                authorMaskAsset: "pizza_jalapeno_mask",
                trayAsset: "jalapeno_addon",
                approvedAnchors: [NormalizedRect(x: 0.20, y: 0.24, width: 0.60, height: 0.54)],
                removalPrompt: nil,
                integrationPrompt: "Integrate sliced jalapenos across the pizza with matched heat and shadows.",
                deterministicSeed: 7_703
            )
        ],
        fallbackStates: [
            "base": VisualStateDefinition(assetName: "pizza_base", accessibilityDescription: "Pizza with black olives"),
            "removed": VisualStateDefinition(assetName: "pizza_no_olives", accessibilityDescription: "Pizza without olives"),
            "added": VisualStateDefinition(assetName: "pizza_jalapeno", accessibilityDescription: "Pizza with olives and jalapeños"),
            "removed+added": VisualStateDefinition(assetName: "pizza_no_olives_jalapeno", accessibilityDescription: "Pizza without olives and with jalapeños")
        ]
    )

    nonisolated static let waffle = DishDefinition(
        id: "waffle",
        name: "After Dark Waffle",
        subtitle: "Belgian waffle · berries · maple",
        basePricePaise: 29_900,
        baseImageAsset: "waffle_base",
        depthLayers: [DepthLayerDefinition(id: "waffle.body", assetName: "waffle_base", depth: 0.48)],
        modifiers: [
            ModifierDefinition(
                id: "waffle.remove.strawberries",
                name: "Remove strawberries",
                shortLabel: "No strawberries",
                kind: .removal,
                priceDeltaPaise: 0,
                authorMaskAsset: "waffle_strawberries_mask",
                trayAsset: nil,
                approvedAnchors: [],
                removalPrompt: "Remove strawberries and reconstruct waffle, cream and plate.",
                integrationPrompt: nil,
                deterministicSeed: 3_113
            ),
            ModifierDefinition(
                id: "waffle.add.icecream",
                name: "Add vanilla ice cream",
                shortLabel: "Ice cream",
                kind: .addition,
                priceDeltaPaise: 7_000,
                authorMaskAsset: "waffle_icecream_mask",
                trayAsset: "icecream_addon",
                approvedAnchors: [NormalizedRect(x: 0.50, y: 0.29, width: 0.28, height: 0.32)],
                removalPrompt: nil,
                integrationPrompt: "Integrate one vanilla ice cream scoop on the waffle.",
                deterministicSeed: 8_809
            )
        ],
        fallbackStates: [
            "base": VisualStateDefinition(assetName: "waffle_base", accessibilityDescription: "Waffle with strawberries and no ice cream"),
            "removed": VisualStateDefinition(assetName: "waffle_no_strawberries", accessibilityDescription: "Waffle without strawberries"),
            "added": VisualStateDefinition(assetName: "waffle_icecream", accessibilityDescription: "Waffle with strawberries and ice cream"),
            "removed+added": VisualStateDefinition(assetName: "waffle_no_strawberries_icecream", accessibilityDescription: "Waffle without strawberries and with ice cream")
        ]
    )
}
