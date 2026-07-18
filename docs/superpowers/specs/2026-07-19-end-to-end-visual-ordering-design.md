# DishEdit End-to-End Visual Ordering Design

## Outcome

DishEdit becomes a complete, native iOS 27 Zomato concept flow for one fictional traditional restaurant and exactly three customizable products:

- The Classic Burger
- Build Your Own Sub
- Taco Wrap

The customer starts on a familiar restaurant menu, taps **Edit visually** beside the normal Add control, directly manipulates an exploded photographic representation of the food, reviews a deterministic instruction draft, optionally describes preferences in natural language, and reaches a local mock checkout with every selected modifier and instruction already carried forward.

The memorable interaction remains:

> The dish opens into its ingredients. Touch an ingredient to remove it, drag a restaurant-approved ingredient into the stack, and watch the food reassemble into the customer’s version.

This is a concept component Eternal could embed in Zomato or Bistro. It is not a Zomato clone, production ordering client, allergy system, payment implementation, or claim that generated pixels are the order.

## Locked product scope

### Restaurant and menu

Use one fictional restaurant named **Copper & Crumb**. The menu is an original Zomato-inspired interface rather than a pixel copy. It contains a compact restaurant header, rating, delivery estimate, cuisine summary, and three product cards. Public Zomato screenshots may be studied for information hierarchy, but scraped screenshots, logos, restaurant photographs, and proprietary assets must not be bundled.

Every product card has:

- Dish photograph, title, description, dietary marker, price, and rating.
- Normal **Add** control, which adds the default dish without visual editing.
- Secondary **Edit visually** control, which opens DishEdit.

No restaurant search, account system, address selection, recommendations, reviews, delivery tracking, real payment, or network-backed cart is included.

### Visual editor

The assembled food photograph fills the canvas. Opening the editor runs a short unwrapping animation:

- Burger layers separate vertically with restrained depth.
- Sub bread opens and the fillings spread into a compact assembly line inspired by the in-person sandwich-counter conversation.
- Taco Wrap opens and its fillings fan into a shallow arc above the tortilla.

Each visible ingredient is a merchant-defined `IngredientDefinition`, not a label inferred by AI. It has a stable catalog ID, display name, price delta, default presence, dietary/allergen metadata, authored hit region, visual layer asset, allowable placement slot, and accessibility description.

The customer can:

- Tap a present ingredient to remove or restore it.
- Drag an allowed add-on from the lower tray into an approved slot.
- Tap an accessible Add/Remove action instead of dragging.
- Pinch to inspect, pan while zoomed, tilt for restrained parallax, and long-press to compare with the original.
- Undo, redo, reset, and inspect a live deterministic price.
- Confirm and watch the ingredients reassemble.

Visual intelligence is optional refinement. Catalog data always determines the order. A Vision mask may determine which pixels animate, but it must never create a catalog modifier or price.

### Dish catalogs

The prototype must use curated, bounded catalogs so every action is testable and stage-safe.

#### Burger

Default layers, bottom to top:

1. Bottom brioche bun
2. House sauce
3. Beef patty
4. Tomato
5. Red onion
6. Lettuce
7. Top brioche bun

Supported changes:

- Remove tomato
- Remove onion
- Remove lettuce
- Add cheddar cheese, +₹40
- Add jalapeños, +₹30

Hero demo transition: remove tomato, then add cheddar.

#### Build Your Own Sub

Default layers:

1. Toasted sub bread
2. Grilled paneer
3. Cheddar
4. Lettuce
5. Tomato
6. Onion
7. Cucumber
8. Chipotle sauce

Supported changes:

- Remove tomato
- Remove onion
- Remove cucumber
- Remove chipotle sauce
- Add jalapeños, +₹30
- Add olives, +₹35
- Add mint mayonnaise, +₹20

The interaction should feel like ordering at a sandwich counter: bread opens, ingredients occupy named slots, and sauce is applied with a short path animation. Do not use or imply Subway branding.

#### Taco Wrap

Default layers:

1. Soft tortilla
2. Spiced beans
3. Grilled vegetables
4. Tomato salsa
5. Onion
6. Lettuce
7. Chipotle crema

Supported changes:

- Remove onion
- Remove lettuce
- Remove chipotle crema
- Add cheese, +₹40
- Add jalapeños, +₹30
- Add guacamole, +₹60

The tortilla opens, ingredients fan out, and confirmation folds it back into the finished wrap.

### Instruction review

After confirming the visual edit, show an **Instruction Review** screen rather than immediately opening checkout.

The screen contains:

- A read-only structured summary generated from selected modifier IDs.
- An editable customer note.
- A natural-language field titled **Tell us in your own words**.
- A small Apple Intelligence availability indicator.
- A **Draft with Apple Intelligence** action.
- A review card showing proposed removals, additions, and note text before applying anything.
- A confirm button.

Example input:

> I have a nut allergy and don’t like onions.

Expected draft:

- Propose removing onion only if onion is a supported present ingredient.
- Add “Customer reports a nut allergy” to the note.
- Mark the draft as requiring allergy acknowledgement.
- Never claim the dish is safe, allergen-free, or that the restaurant can comply.

The user must approve the draft. Foundation Models output is untrusted proposal data. Modifier IDs must be validated against the current merchant catalog before they can change the cart.

If Foundation Models is unavailable, use a transparent local keyword parser for the demo phrases and retain fully manual editing. Never pretend that the fallback used Apple Intelligence.

### Allergy confirmation

Whenever the customer mentions an allergy, show this exact prominent draft before continuing:

> **Important allergy note**
>
> This request will be shared with the restaurant. The restaurant cannot guarantee an allergen-free preparation or prevent cross-contact. If your allergy is severe, contact the restaurant before ordering.

Require an explicit **I understand** confirmation. The checkout must retain the reported allergy as a customer note and repeat a shorter warning. Do not infer medical severity, guarantee ingredient absence, automatically remove suspected allergens, or describe the flow as allergy protection.

### Checkout

The local mock checkout displays:

- Restaurant and three possible products, with only cart items expanded.
- Base dish, quantity, selected removal/addition labels, price deltas, and total.
- Customer instruction note.
- Allergy acknowledgement when present.
- Mock address, delivery estimate, taxes, and fee rows clearly labeled as concept data.
- Disabled or concept-only payment row.
- **Place demo order** action producing a local success screen.

There is no real order, payment, authentication, address lookup, delivery estimate, restaurant availability, or Eternal API.

## Visual language

The menu and checkout use a light, food-commerce surface with red accents and original spacing/type hierarchy. The editor transitions to a cinematic warm-black canvas so the food dominates. Liquid Glass is reserved for the ingredient tray, navigation controls, engine selector, and compact summary. Do not use generic AI glows, chat bubbles, dashboard cards, excessive gradients, or multiple competing hero animations.

The first ten seconds of the demo must show:

1. The burger card in the menu.
2. A tap on **Edit visually**.
3. The burger physically unwrapping into labeled layers.
4. A tap on tomato that removes it with immediate haptic and visible motion.

The image refinement animation may take 5–6 seconds, but the structured order must change in under 100 ms and a high-quality deterministic preview must appear quickly enough that the interface never looks frozen.

## Technical architecture

Preserve and evolve the existing SwiftUI/Observation project. Do not rewrite the working prototype from scratch.

### Feature boundaries

- `Restaurant`: fictional restaurant catalog and menu/product cards.
- `Customization`: ingredient catalog, exploded layouts, hit testing, drag/drop, reassembly, edit history, and visual preview.
- `Instructions`: Foundation Models adapter, deterministic fallback parser, proposal validation, allergy acknowledgement, and note drafting.
- `Cart`: local cart state, pricing, checkout, and demo confirmation.
- `Generation`: prepared visual engine, Core AI experimental engine, remote engine adapter, Image Playground bridge, engine selection, cache, diagnostics, and failure policy.
- `Shared`: money formatting, asset loading, availability, logging, and test support.

Existing domain, editing, motion, haptics, mask validation, reconstruction timeline, revision gate, diagnostics, and image geometry code should be retained or moved behind these boundaries only when the move directly supports the new flow.

### Navigation state

Use one `@MainActor @Observable` `AppCoordinator` with explicit routes:

```swift
enum AppRoute: Equatable, Sendable {
    case restaurant
    case customize(productID: String)
    case instructions(productID: String)
    case checkout
    case confirmation(orderID: String)
    case settings
    case diagnostics
}
```

The restaurant catalog and cart are injected into the coordinator. Visual editor state remains revision-based and scoped per product. Back navigation must not silently discard edits; show a compact discard confirmation only when the current draft differs from the cart item.

### Catalog truth

Define stable types equivalent to:

```swift
struct RestaurantDefinition: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let cuisine: String
    let rating: Double
    let deliveryEstimate: String
    let products: [ProductDefinition]
}

struct ProductDefinition: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let basePricePaise: Int
    let assembledAssetName: String
    let presentation: IngredientPresentation
    let ingredients: [IngredientDefinition]
    let visualStates: [VisualStateKey: VisualStateDefinition]
}

struct IngredientDefinition: Identifiable, Codable, Sendable {
    enum Role: String, Codable, Sendable {
        case base
        case protein
        case cheese
        case vegetable
        case sauce
        case topping
    }

    let id: String
    let name: String
    let role: Role
    let defaultPresence: Bool
    let canRemove: Bool
    let canAdd: Bool
    let priceDeltaPaise: Int
    let layerAssetName: String
    let authorMaskAssetName: String?
    let placementSlots: [NormalizedRect]
    let accessibilityDescription: String
}

struct CustomizationDraft: Equatable, Sendable {
    let productID: String
    var presentIngredientIDs: Set<String>
    var revision: UInt64
    var history: [CustomizationSnapshot]
    var future: [CustomizationSnapshot]
}
```

All cart pricing and instructions are derived from these IDs. Generated images are display artifacts only.

## Image and AI architecture

### Engine modes

Expose these settings:

```swift
enum VisualGenerationPreference: String, CaseIterable, Codable, Sendable {
    case automatic
    case onDevice
    case remote
    case reviewedPreview
}
```

Use an engine protocol equivalent to:

```swift
protocol VisualEditEngine: Sendable {
    var kind: VisualEditEngineKind { get }
    func availability() async -> EngineAvailability
    func prepare() async throws
    func render(_ request: VisualEditRequest) async throws -> VisualEditResult
}
```

Every request contains product ID, source image, selected merchant ingredient IDs, optional validated Vision mask, deterministic seed, revision, and crop metadata. Every result declares its engine, duration, whether pixels were generated or prepared, and the revision. Stale results are discarded even if task cancellation fails.

### Reviewed preview engine

This is the guaranteed path. It uses licensed/original prepared visual states or precisely composited ingredient layers. It must work in airplane mode, cold launch, Reduce Motion, and after forced failures. Diagnostics label it `REVIEWED PREVIEW`; never `LIVE AI`.

The hero burger removal-plus-cheese state must have a complete matched destination photograph. The Sub and Taco Wrap need at least their default, hero-removal, hero-addition, and combined hero state. Non-hero combinations may use a high-quality layered composition when no reviewed photograph exists, but that limitation must be disclosed in diagnostics.

### Vision segmentation

Use iOS 27 `GenerateIterativeSegmentationRequest` only after merchant hit testing has resolved ingredient identity. Validate the live mask against the author mask. If assets are unavailable, the mask spills outside the permitted region, or device testing is incomplete, animate with the author mask.

Vision decides shape, never semantics.

### Core AI local engine

Core AI is the experimental silent on-device route. It does not expose Apple’s private Image Playground model. Start from Apple’s official `apple/coreai-models` repository and its `CoreAIDiffusionPipeline`. Evaluate the iOS 512×512 FLUX.2 Klein 4B export first.

The official pipeline currently supplies image-to-image through `startingImage` and `strength`, but no mask parameter. Therefore:

1. Find and expand the validated ingredient mask bounding box.
2. Produce a square 512×512 source crop.
3. Run image-to-image with fixed prompt, seed, four steps, `.half` decode resolution, and a device-tested strength.
4. Resize the result back to source coordinates.
5. Composite only through a cleaned and feathered mask.
6. Copy every pixel outside the region of interest from the original.
7. Reject results that violate simple structural/visual checks and retain the reviewed preview.

This engine is stage-enabled only after real iPhone 16 benchmarks. Support in an Apple repository is not proof of acceptable memory, latency, thermal behavior, or image quality.

### Remote engine

Implement a provider-isolated adapter capable of sending a source crop, mask, fixed prompt, and deterministic request metadata to a mask-capable image-edit API. Do not hard-code secrets or commit credentials. Read debug configuration from an ignored local `.xcconfig`, store runtime credentials in Keychain when necessary, and make the remote engine unavailable when configuration is missing.

Do not make the remote provider a prerequisite for building, testing, or presenting the app. Record provider, model/version, terms, response disclosure, timeout, and license in the research ledger before enabling it.

### Automatic selection

Automatic mode chooses:

```text
Qualified, prepared Core AI engine
    → configured remote engine with acceptable connectivity
    → reviewed preview
```

Stage Safe mode is the reviewed preview. Switching modes never changes commerce state.

### Image Playground

Image Playground is a separate, explicitly user-initiated experiment named **Try Apple Image Playground**. It is not an automatic engine and does not replace the direct-manipulation flow.

Use `imagePlaygroundSheet` with the current dish as `sourceImage`, a fixed edit concept, personalization disabled, low creation variety, and the beta `.editExisting` creation strategy when the installed SDK supports it. The system sheet owns generation and acceptance. Save its temporary output URL if accepted.

Disclose that iOS 27’s high-quality Image Playground model runs on Private Cloud Compute and may have usage limits. Do not describe it as local, silent, mask-constrained, or guaranteed to preserve the dish.

Do not use deprecated `ImageCreator`; Apple says it will not work in iOS 27 production/TestFlight builds.

### Foundation Models

Use the on-device Apple Foundation Model for instruction drafting, not image pixels. Define a constrained generated result containing proposed ingredient IDs, customer note, mentioned allergens, unresolved phrases, and `requiresAllergyAcknowledgement`.

The model receives only the current merchant catalog and user text. Validate every returned ID. Unsupported or ambiguous requests remain plain notes. The model cannot remove ingredients automatically without user approval.

Availability/failure path:

```text
Foundation Models available
    → structured proposal
    → catalog validation
    → explicit user approval

Unavailable/refused/error
    → honest deterministic parser for supported demo phrases
    → manual review
```

## Animation and haptics

### Opening

- Assembled image holds for 120 ms.
- Shadow deepens and container scale reaches approximately 1.015.
- Layers separate over 550–750 ms with staggered springs.
- Labels fade in after layers clear one another.
- One rigid haptic marks the final settled state.

### Removal

- Selection haptic under 100 ms.
- Ingredient edge resolves from authored/live mask.
- Layer lifts 8–12 points and scales approximately 1.03.
- It moves out of the stack or dissolves using a restrained mask-local effect.
- Catalog modifier, chip, and price commit immediately.

### Addition

- Dragged asset lifts to approximately 1.1 scale with a real shadow.
- Only merchant-approved slots highlight.
- Entering a valid slot produces a rigid haptic.
- Drop snaps with a short spring and a soft finishing pulse.
- Invalid drops do not change the order.

### Reassembly and refinement

- Layers return in reverse order.
- Prepared visual preview appears without a blocking spinner.
- Optional visual refinement runs for no more than the configured 5–6 second stage window.
- A mask-local scanning/refraction treatment shows progress honestly as `Preparing visual preview`.
- If a genuine engine completes, crossfade only the approved result.
- If it fails, retain the reviewed preview and record the fallback in diagnostics.

Reduce Motion replaces separation, particles, parallax, and scan motion with short crossfades and static labeled rows.

## Accessibility

- Every ingredient is an accessibility element with present/removed state.
- Custom actions provide Add, Remove, Restore, and Explain price.
- VoiceOver announces modifier and total changes.
- Drag operations always have button alternatives.
- Labels and shape supplement color.
- Dynamic Type is supported outside the photographic canvas.
- Reduce Motion and Reduce Transparency produce complete usable alternatives.
- Natural-language drafting and allergy acknowledgement are fully accessible.
- Haptics never carry required information alone.

## Diagnostics and honesty

Retain a judge-facing diagnostics screen showing:

- App and SDK build.
- Device and OS.
- Selected generation preference.
- Actual engine used for the last result.
- `LIVE VISION` or `AUTHOR MASK`.
- Foundation Models or deterministic parser.
- Model readiness, cache state, latency, revision, and fallback reason.
- Airplane mode status.
- Buttons to force Vision, Core AI, remote, and Foundation Models failure.
- Cache clear and visual-state reset.
- Exportable compact reliability metrics.

Never label a prepared image as generated. Never hide a manual trigger. Never say “Apple AI generated this locally” unless the result actually came from a measured Core AI model running on the phone.

## Validation gates

### Simulator gate

- Project builds with Swift 6.4 complete concurrency.
- Full unit and UI suites pass.
- Restaurant → editor → instructions → checkout → confirmation completes.
- Cart state is deterministic through back navigation and relaunch within the current session.
- No network or credential is needed for the reviewed path.

### Physical iPhone 16 gate

Run at least 20 complete hero loops including cold launch, airplane mode, Reduce Motion, rapid undo, app backgrounding, forced Vision failure, forced Foundation Models failure, forced Core AI failure, remote timeout, and warm-device conditions.

Acceptance:

- 20/20 correct catalog modifier and price state.
- Zero crashes, memory terminations, stale overwrites, or hidden triggers.
- Immediate interaction feedback under 100 ms.
- Zero incorrect checkout instructions.
- Reviewed preview always available.
- Core AI is stage-enabled only with zero crashes and p95 at or below eight seconds in the measured configuration.
- Remote is never the only working path.

## Kill gates

- Hour 4: end-to-end navigation and cart compile; burger editor uses catalog state.
- Hour 8: burger unwrap, tomato removal, cheese addition, instruction review, and checkout work through reviewed assets. If Core AI cannot produce one valid result on iPhone 16, remove it from the stage path.
- Hour 16: Sub and Taco catalogs and exploded layouts work. If full combinatorial photorealism is weak, keep the editor layered and restrict final reviewed images to hero combinations.
- Hour 24: Foundation Models proposal plus deterministic fallback and allergy acknowledgement work. If model output cannot be constrained reliably, keep natural-language text as a draft note and require manual modifier selection.
- Hour 32: accessibility, diagnostics, forced failures, and first 20-run pass.
- Hour 40: feature freeze. No widgets, Live Activities, Watch app, Siri, multiplayer, arbitrary customer photos, restaurant search, real checkout, or extra dishes.

## Demo narrative

Opening:

> “Food customization is still a form. DishEdit turns the food itself into the form.”

Sequence:

1. Show Copper & Crumb and the three menu items.
2. Tap **Edit visually** on the burger.
3. The burger unwraps into labeled layers.
4. Tap tomato: “I touch what I don’t want.”
5. Drag cheddar: “And drag in what I do want.”
6. Confirm; the burger reassembles and the preview resolves.
7. Enter “I have a nut allergy and don’t like onions.”
8. Show the Apple Intelligence proposal, catalog validation, and honest allergy warning.
9. Confirm and show checkout already populated with `No tomato`, `No onion`, `Add cheddar +₹40`, and the allergy note.
10. Open diagnostics briefly and disclose the actual engines.

Close:

> “The picture can be intelligent, but the order is always exact. Eternal already knows what a restaurant can prepare; DishEdit lets the customer touch what they mean.”

## Primary references

- Image Playground WWDC26: https://developer.apple.com/videos/play/wwdc2026/375/
- Image Playground framework: https://developer.apple.com/documentation/imageplayground
- ImageCreator discontinuation: https://developer.apple.com/news/?id=dz9wvq0r
- Image Playground creation strategy: https://developer.apple.com/documentation/imageplayground/imageplaygroundoptions/creationstrategy-swift.property
- Core AI: https://developer.apple.com/documentation/coreai
- Meet Core AI: https://developer.apple.com/videos/play/wwdc2026/324/
- Integrate Core AI models: https://developer.apple.com/videos/play/wwdc2026/326/
- Apple Core AI models repository: https://github.com/apple/coreai-models
- Apple FLUX.2 Core AI recipe: https://github.com/apple/coreai-models/tree/main/models/flux2
- Core AI pipeline configuration: https://github.com/apple/coreai-models/blob/main/swift/Sources/CoreAIDiffusionPipeline/Pipelines/PipelineConfiguration.swift
- FLUX.2 Klein 4B model/license: https://huggingface.co/black-forest-labs/FLUX.2-klein-4B
- Image understanding, Foundation Models, and tap-to-segment: https://developer.apple.com/videos/play/wwdc2026/237/
- Iterative segmentation: https://developer.apple.com/documentation/vision/generateiterativesegmentationrequest
- Core Image mask blending: https://developer.apple.com/documentation/coreimage/ciblendwithmask
