# DishEdit End-to-End Visual Ordering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evolve the working DishEdit prototype into a complete restaurant-menu-to-checkout iOS 27 concept for Burger, Build Your Own Sub, and Taco Wrap while preserving a reliable direct-manipulation hero demo and honest AI fallbacks.

**Architecture:** Preserve the current SwiftUI/Observation app and its deterministic catalog state, revision gate, masks, animation, haptics, and reviewed visual engine. Add bounded Restaurant, Customization, Instructions, Cart, and Generation feature boundaries coordinated by one `@MainActor @Observable` app coordinator. Apple intelligence proposes visual or instruction outputs, but validated merchant catalog IDs remain the only commerce truth.

**Tech Stack:** Swift 6.4 strict concurrency, SwiftUI, Observation, Swift Testing, XCTest UI tests, Vision, Foundation Models, Core Image, Core Motion, Core Haptics, Image Playground, optional Core AI, URLSession, OSLog, no required third-party runtime package.

## Global Constraints

- Project root: `/Users/cruzer/Documents/projects/ios-load/DishEdit`.
- Read and obey `AGENTS.md` before editing.
- Toolchain: `/Applications/Xcode-27.0.0-Beta.3.app`, deployment target iOS 27.0, portrait iPhone, bundle ID `com.swiftdidload.DishEdit`.
- Guaranteed hardware: standard iPhone 16 with iOS 27 beta; Apple Intelligence is enabled, but every feature still needs runtime availability handling.
- One fictional restaurant, Copper & Crumb; exactly Burger, Build Your Own Sub, and Taco Wrap.
- No real Zomato/Eternal API, account, order, payment, address, restaurant availability, or allergy guarantee.
- No private API, hard-coded secret, paid dependency, required internet, hidden trigger, scraped image, or copied Zomato screenshot in the bundle.
- Catalog IDs determine ingredients, pricing, instructions, and cart state. AI output is untrusted proposal or display data.
- Preserve the reviewed preview engine and make it the guaranteed stage path.
- Do not call prepared images `LIVE AI`; diagnostics must disclose the actual engine.
- Do not use deprecated `ImageCreator` on iOS 27.
- Core AI is optional until it passes the physical-device gate; Image Playground is a separate system-sheet experiment.
- Exact allergy copy and acknowledgement behavior come from `docs/superpowers/specs/2026-07-19-end-to-end-visual-ordering-design.md`.
- Write a focused failing test before each behavior change, then run focused and full suites.
- Commit after every independently passing task. Never rewrite or discard the existing three commits.

## Target file map

### Preserve and adapt

- `DishEdit/Domain/DishModels.swift`: migrate legacy dish types into compatibility extensions or delete only after all callers use the new catalog.
- `DishEdit/Domain/ImageGeometry.swift`: retain normalized coordinate and viewport mapping.
- `DishEdit/Editing/*`: retain mask validation, compositing, revision selection, and reviewed engine behavior.
- `DishEdit/Experience/DishEditCoordinator.swift`: reduce to a product-scoped customization coordinator.
- `DishEdit/Experience/MotionController.swift`: retain device parallax.
- `DishEdit/Experience/ReconstructionTimeline.swift`: retain deterministic 5.4-second reviewed transition.
- `DishEdit/Experience/ReconstructionHaptics.swift`: retain and expand named cues.
- `DishEdit/ContentView.swift`: replace monolith with root navigation; move reusable views into feature folders.

### Create

- `DishEdit/App/AppCoordinator.swift`: app route, draft lifecycle, and cart ownership.
- `DishEdit/App/AppRootView.swift`: route rendering and sheets.
- `DishEdit/Restaurant/RestaurantModels.swift`: restaurant/product/ingredient catalog types.
- `DishEdit/Restaurant/DemoRestaurantCatalog.swift`: Copper & Crumb data.
- `DishEdit/Restaurant/RestaurantMenuView.swift`: menu and product cards.
- `DishEdit/Customization/CustomizationDraft.swift`: deterministic ingredient state/history.
- `DishEdit/Customization/CustomizationCoordinator.swift`: revision-safe product editor state.
- `DishEdit/Customization/IngredientLayout.swift`: burger/sub/taco exploded geometry.
- `DishEdit/Customization/VisualEditorView.swift`: stage shell and controls.
- `DishEdit/Customization/ExplodedDishCanvas.swift`: layers, hit testing, gestures, drag/drop.
- `DishEdit/Customization/IngredientLayerView.swift`: one labeled layer.
- `DishEdit/Customization/IngredientTrayView.swift`: merchant-approved additions.
- `DishEdit/Customization/ReassemblyOverlay.swift`: reassembly and visual-preparation status.
- `DishEdit/Instructions/InstructionModels.swift`: proposal and validation types.
- `DishEdit/Instructions/InstructionDrafting.swift`: protocol and validated resolver.
- `DishEdit/Instructions/DeterministicInstructionParser.swift`: honest fallback.
- `DishEdit/Instructions/FoundationModelInstructionDrafter.swift`: Apple Foundation Model adapter.
- `DishEdit/Instructions/InstructionReviewView.swift`: proposal review and note editing.
- `DishEdit/Instructions/AllergyAcknowledgementView.swift`: exact warning and confirmation.
- `DishEdit/Cart/CartModels.swift`: cart item, totals, concept fee rows.
- `DishEdit/Cart/CartStore.swift`: local deterministic cart actor/state.
- `DishEdit/Cart/CheckoutView.swift`: carried-forward order summary.
- `DishEdit/Cart/OrderConfirmationView.swift`: local demo success.
- `DishEdit/Generation/VisualEditModels.swift`: requests, results, availability, and engine modes.
- `DishEdit/Generation/VisualEditEngine.swift`: engine protocol.
- `DishEdit/Generation/ReviewedPreviewEngine.swift`: guaranteed engine.
- `DishEdit/Generation/VisualEngineSelector.swift`: deterministic selection/fallback.
- `DishEdit/Generation/CoreAIVisualEditEngine.swift`: compile-gated optional engine.
- `DishEdit/Generation/RemoteVisualEditEngine.swift`: configuration-gated remote adapter.
- `DishEdit/Generation/ImagePlaygroundBridge.swift`: explicit Apple system sheet support.
- `DishEdit/Generation/GeneratedImageCache.swift`: revision/model-aware local cache.
- `DishEdit/Settings/GenerationSettingsView.swift`: preference and stage-safe controls.
- `DishEdit/Diagnostics/DiagnosticsView.swift`: expand existing diagnostics and failure injection.
- `DishEdit/Shared/INR.swift`: paise formatting.
- `DishEdit/Shared/FeatureAvailability.swift`: Apple framework availability snapshots.
- `DishEdit/Resources/restaurant_catalog.json`: optional serialized catalog mirror if it improves auditability.
- `DishEdit/Resources/Assets/*`: original assembled photographs, transparent ingredient layers, masks, and reviewed destination states.
- `DishEditTests/*`: one focused test file per domain/service boundary.
- `DishEditUITests/EndToEndFlowUITests.swift`: complete hero flow.
- `CORE_AI_RESULTS.md`: device measurements and enable/disable verdict.
- `REMOTE_ENGINE_SETUP.md`: provider, secret configuration, disclosure, and failure behavior.
- `CLAUDE_CODE_HANDOFF.md`: autonomous execution contract.

---

### Task 1: Establish a clean baseline and compatibility safety net

**Files:**
- Modify: `IMPLEMENTATION_STATUS.md`
- Modify: `TEST_REPORT.md`
- Test: existing `DishEditTests` and `DishEditUITests`

**Interfaces:**
- Consumes: existing project and `AGENTS.md` commands.
- Produces: recorded baseline commit, exact test/build output, and screenshot of the current hero loop.

- [ ] **Step 1: Inspect without changing behavior**

Run:

```bash
git status --short
git log -5 --oneline
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcodebuild -list -project DishEdit.xcodeproj
```

Expected: working tree state is understood; project and `DishEdit` scheme are listed.

- [ ] **Step 2: Run the current full suite**

Run the two build/test commands from `AGENTS.md`. Expected: build and current tests pass. If a pre-existing failure appears, record it before making feature changes and fix only when it blocks this plan.

- [ ] **Step 3: Record the baseline**

Add dated command results, simulator/runtime, passing counts, and existing limitations to `TEST_REPORT.md` and `IMPLEMENTATION_STATUS.md`. Do not change old claims into stronger claims.

- [ ] **Step 4: Commit documentation only**

```bash
git add IMPLEMENTATION_STATUS.md TEST_REPORT.md
git commit -m "docs: record DishEdit end-to-end baseline"
```

### Task 2: Introduce restaurant, product, and ingredient catalog truth

**Files:**
- Create: `DishEdit/Restaurant/RestaurantModels.swift`
- Create: `DishEdit/Restaurant/DemoRestaurantCatalog.swift`
- Create: `DishEditTests/RestaurantCatalogTests.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Produces: `RestaurantDefinition`, `ProductDefinition`, `IngredientDefinition`, `IngredientPresentation`, and `DemoRestaurantCatalog.copperAndCrumb`.
- Consumers: customization, instructions, cart, menu, and generation tasks.

- [ ] **Step 1: Write failing catalog invariants**

Create tests that assert:

```swift
@Test func catalogContainsExactlyThreeProducts() {
    let catalog = DemoRestaurantCatalog.copperAndCrumb
    #expect(catalog.products.map(\.id) == ["burger", "sub", "taco-wrap"])
}

@Test func everyIngredientIDIsGloballyStableWithinProduct() {
    for product in DemoRestaurantCatalog.copperAndCrumb.products {
        #expect(Set(product.ingredients.map(\.id)).count == product.ingredients.count)
        #expect(product.ingredients.allSatisfy { $0.id.hasPrefix(product.id + ".") })
    }
}

@Test func requiredHeroModifiersExist() throws {
    let burger = try #require(DemoRestaurantCatalog.copperAndCrumb.product(id: "burger"))
    #expect(burger.ingredient(id: "burger.tomato")?.defaultPresence == true)
    #expect(burger.ingredient(id: "burger.cheddar")?.priceDeltaPaise == 4_000)
}
```

- [ ] **Step 2: Confirm tests fail because types do not exist**

Run the focused test target. Expected: compile failure naming the missing catalog types.

- [ ] **Step 3: Implement focused Sendable catalog types**

Use the exact catalog contents in the design spec. Include helpers:

```swift
nonisolated extension RestaurantDefinition {
    func product(id: String) -> ProductDefinition? {
        products.first { $0.id == id }
    }
}

nonisolated extension ProductDefinition {
    func ingredient(id: String) -> IngredientDefinition? {
        ingredients.first { $0.id == id }
    }
}
```

Reject duplicate IDs with tests rather than runtime invention. Use paise integers only.

- [ ] **Step 4: Add files to the Xcode project and run focused/full tests**

Expected: new tests and legacy tests pass.

- [ ] **Step 5: Commit**

```bash
git add DishEdit/Restaurant DishEditTests/RestaurantCatalogTests.swift DishEdit.xcodeproj/project.pbxproj
git commit -m "feat: add Copper and Crumb merchant catalog"
```

### Task 3: Build deterministic customization drafts and history

**Files:**
- Create: `DishEdit/Customization/CustomizationDraft.swift`
- Create: `DishEditTests/CustomizationDraftTests.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: `ProductDefinition` and stable ingredient IDs.
- Produces: `CustomizationDraft`, `CustomizationSnapshot`, `CustomizationMutation`, `apply`, `undo`, `redo`, `reset`, `priceDeltaPaise`, and `modifierSummary`.

- [ ] **Step 1: Write failing state tests**

Cover removal, restore, priced addition, duplicate no-op, unsupported ID rejection, undo, redo, reset, and exact initial restoration. Assert revision increases only for accepted mutations.

- [ ] **Step 2: Implement mutation result and draft**

Use a result that prevents silent invalid changes:

```swift
enum CustomizationMutation: Equatable, Sendable {
    case changed(revision: UInt64)
    case rejected(reason: Rejection)

    enum Rejection: Equatable, Sendable {
        case unknownIngredient
        case ingredientNotRemovable
        case ingredientNotAddable
        case noStateChange
    }
}
```

Initialize `presentIngredientIDs` from `defaultPresence`. Additions contribute price only when present and not default. Removals never create negative price.

- [ ] **Step 3: Run focused/full tests and commit**

```bash
git add DishEdit/Customization/CustomizationDraft.swift DishEditTests/CustomizationDraftTests.swift DishEdit.xcodeproj/project.pbxproj
git commit -m "feat: add deterministic ingredient customization state"
```

### Task 4: Add cart state and app navigation before UI polish

**Files:**
- Create: `DishEdit/Cart/CartModels.swift`
- Create: `DishEdit/Cart/CartStore.swift`
- Create: `DishEdit/App/AppCoordinator.swift`
- Create: `DishEditTests/CartStoreTests.swift`
- Create: `DishEditTests/AppCoordinatorTests.swift`
- Modify: `DishEdit/DishEditApp.swift`
- Modify: `DishEdit/ContentView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: restaurant catalog and customization draft.
- Produces: `AppRoute`, `CartItem`, `CartStore`, `AppCoordinator`, route methods, draft commit, and checkout totals.

- [ ] **Step 1: Write failing route and cart tests**

Assert default route is `.restaurant`; visual edit creates a product draft; committing creates/updates one cart item; direct Add creates the default item; instruction text survives editor → instruction review → checkout; back navigation preserves cart and asks before discarding a dirty draft.

- [ ] **Step 2: Implement explicit route enum and coordinator**

Use the route definition in the spec. Keep coordinator `@MainActor`; make immutable domain values `Sendable`. Store route transitions as methods rather than setting arbitrary view booleans.

- [ ] **Step 3: Replace root content with a temporary route probe**

Render plain text/buttons for every route so the complete flow can be UI-tested before design work. Keep the existing editor reachable through an adapter route until Task 7 replaces it.

- [ ] **Step 4: Run tests and commit**

```bash
git add DishEdit/App DishEdit/Cart DishEdit/DishEditApp.swift DishEdit/ContentView.swift DishEditTests DishEdit.xcodeproj/project.pbxproj
git commit -m "feat: add end-to-end route and cart state"
```

### Task 5: Implement the original restaurant menu and three product cards

**Files:**
- Create: `DishEdit/App/AppRootView.swift`
- Create: `DishEdit/Restaurant/RestaurantMenuView.swift`
- Create: `DishEdit/Restaurant/ProductCardView.swift`
- Create: `DishEditUITests/RestaurantMenuUITests.swift`
- Modify: `DishEdit/ContentView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: `AppCoordinator`, restaurant catalog, `addDefaultProduct`, and `beginVisualCustomization`.
- Produces: accessibility IDs `menu.product.<id>`, `menu.add.<id>`, and `menu.edit-visually.<id>`.

- [ ] **Step 1: Write failing UI tests**

Launch and assert exactly three cards. Tap `menu.add.burger` and assert cart count is one. Relaunch, tap `menu.edit-visually.burger`, and assert route marker `customization.burger` appears.

- [ ] **Step 2: Build the original light commerce surface**

Use the product-card content specified in the design. Do not bundle Zomato screenshots. Add a debug-only design-reference note to `RESEARCH_DECISIONS.md` recording URLs/screenshots inspected and the decision to produce original UI.

- [ ] **Step 3: Verify Dynamic Type and commit**

Run at standard and accessibility extra-extra-extra-large content sizes. Commit passing menu and UI tests.

### Task 6: Define dish-specific exploded layouts and asset contracts

**Files:**
- Create: `DishEdit/Customization/IngredientLayout.swift`
- Create: `DishEditTests/IngredientLayoutTests.swift`
- Modify: `ASSET_SOURCES.md`
- Modify: `ASSET_CHECKSUMS.md`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: product presentation and ingredient order.
- Produces: deterministic normalized collapsed/expanded transforms and approved drop regions for each ingredient.

- [ ] **Step 1: Write layout invariant tests**

Assert every visible ingredient receives one transform; normalized positions are in range; collapsed order matches catalog order; Sub sauce has a path; Taco and Burger layers do not have identical expanded layouts; Reduce Motion layout is a readable list.

- [ ] **Step 2: Implement pure layout calculations**

Represent a layer without SwiftUI state:

```swift
struct IngredientTransform: Equatable, Sendable {
    let center: NormalizedPoint
    let scale: Double
    let rotationDegrees: Double
    let zIndex: Double
    let labelOffset: NormalizedPoint
}
```

Provide `collapsed`, `expanded`, and `reduceMotion` functions. Keep numbers centralized per presentation.

- [ ] **Step 3: Define asset naming and provenance rules**

Every ingredient asset must be original/generated-for-project or explicitly compatible. Record prompt/source, date, license, dimensions, alpha status, SHA-256, and product/ingredient ID. Do not accept a layer with lighting/perspective inconsistent with its assembled dish.

- [ ] **Step 4: Run tests and commit**

### Task 7: Build the visual editor and preserve the existing hero interaction

**Files:**
- Create: `DishEdit/Customization/CustomizationCoordinator.swift`
- Create: `DishEdit/Customization/VisualEditorView.swift`
- Create: `DishEdit/Customization/ExplodedDishCanvas.swift`
- Create: `DishEdit/Customization/IngredientLayerView.swift`
- Create: `DishEdit/Customization/IngredientTrayView.swift`
- Create: `DishEdit/Customization/ReassemblyOverlay.swift`
- Create: `DishEditTests/CustomizationCoordinatorTests.swift`
- Create: `DishEditUITests/VisualEditorUITests.swift`
- Modify: `DishEdit/Experience/DishEditCoordinator.swift`
- Modify: `DishEdit/ContentView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: draft, layout, motion, haptics, existing mask/geometry/reconstruction services.
- Produces: open/expanded/removing/adding/reassembling/ready phases, revision-bound visual results, and stable accessibility identifiers.

- [ ] **Step 1: Write coordinator failure-first tests**

Cover valid/invalid ingredient selection, valid/invalid drop, immediate catalog mutation, stale visual result rejection, undo during refinement, product switch, reset, and confirmation output.

- [ ] **Step 2: Adapt rather than duplicate the existing coordinator**

Move product-agnostic revision, reconstruction, diagnostic, and history integration behind `CustomizationCoordinator`. Preserve behavior that already passes. Do not weaken concurrency annotations.

- [ ] **Step 3: Build burger opening and hero loop first**

The editor must show the assembled photograph, unwrap into labeled layers, remove tomato, drag cheddar, undo, redo, reset, long-press compare, and confirm. UI tests assert modifier state changes before visual refinement completes.

- [ ] **Step 4: Add Sub counter and Taco fan layouts**

Use the same domain and engine interfaces with distinct layout/motion. Sauce drag is a bounded visual path, not a freehand physics editor.

- [ ] **Step 5: Add non-drag accessibility actions and Reduce Motion**

VoiceOver must be able to complete the hero loop without spatial gestures.

- [ ] **Step 6: Run focused/full/UI tests and commit**

### Task 8: Make the reviewed preview engine the guaranteed complete path

**Files:**
- Create: `DishEdit/Generation/VisualEditModels.swift`
- Create: `DishEdit/Generation/VisualEditEngine.swift`
- Create: `DishEdit/Generation/ReviewedPreviewEngine.swift`
- Create: `DishEdit/Generation/GeneratedImageCache.swift`
- Create: `DishEditTests/ReviewedPreviewEngineTests.swift`
- Modify: `DishEdit/Editing/EditEngines.swift`
- Modify: `DishEdit/Editing/CatalogVisualAssets.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Produces: `VisualEditRequest`, `VisualEditResult`, `EngineAvailability`, `VisualEditEngineKind.reviewedPreview`, and deterministic cache key.

- [ ] **Step 1: Write failing engine tests**

Assert every hero transition resolves offline; result revision equals request; result declares `pixelsWereGenerated == false`; missing exact state uses allowed layer composite; missing all resources returns a typed failure without changing commerce state; cache keys include product, sorted ingredient IDs, seed, engine version, and source checksum.

- [ ] **Step 2: Implement the engine by adapting existing assets**

No timer should block order state. The 5.4-second timeline is presentation only. Result metadata must be honest:

```swift
struct VisualEditResult: Sendable {
    let image: CGImage
    let revision: UInt64
    let engine: VisualEditEngineKind
    let duration: Duration
    let pixelsWereGenerated: Bool
    let disclosure: String
}
```

- [ ] **Step 3: Add required hero assets and verify visually**

Produce exact matched photographs for Burger default/removed/added/combined and at least four equivalent hero states for Sub and Taco. Inspect full-resolution crops for lighting, plate/background continuity, food geometry, seams, and alpha halos.

- [ ] **Step 4: Run airplane-mode simulator tests and commit**

### Task 9: Implement deterministic instruction parsing and proposal validation

**Files:**
- Create: `DishEdit/Instructions/InstructionModels.swift`
- Create: `DishEdit/Instructions/InstructionDrafting.swift`
- Create: `DishEdit/Instructions/DeterministicInstructionParser.swift`
- Create: `DishEditTests/InstructionDraftingTests.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Produces: `InstructionProposal`, `InstructionDrafting`, `ValidatedInstructionResolver`, and fallback parser.

- [ ] **Step 1: Write abuse and ambiguity tests**

Test “no onions,” “I don’t like onions,” “nut allergy,” combined phrase, unsupported “no mushrooms,” negation such as “I am not allergic to nuts,” malicious catalog ID text, duplicate modifiers, and empty input. Unsupported text must remain a note or unresolved phrase; it must never invent an ID.

- [ ] **Step 2: Implement bounded fallback parser**

The fallback returns `source: .deterministicParser`. It uses normalized token/phrase matching only for the known demo catalog and allergy terms. It never claims semantic generality.

- [ ] **Step 3: Implement catalog validation**

Drop unknown IDs, identify impossible changes, preserve reported allergy text, and require explicit user approval before modifying the draft.

- [ ] **Step 4: Run tests and commit**

### Task 10: Integrate Foundation Models for natural-language instruction drafts

**Files:**
- Create: `DishEdit/Instructions/FoundationModelInstructionDrafter.swift`
- Create: `DishEdit/Shared/FeatureAvailability.swift`
- Create: `DishEditTests/FoundationModelInstructionDrafterTests.swift`
- Modify: `RESEARCH_DECISIONS.md`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: current product catalog and free text.
- Produces: `InstructionProposal` with `source: .foundationModels`; typed availability and failure.

- [ ] **Step 1: Verify exact beta SDK signatures locally**

Compile a minimal probe for `LanguageModelSession`, `@Generable`, availability, and generated arrays/fields. Record exact signatures and Xcode build in `RESEARCH_DECISIONS.md`. Do not paste remembered WWDC code blindly.

- [ ] **Step 2: Write protocol-level tests with a fake drafter**

Tests must not require Apple Intelligence. Assert view/coordinator behavior for available proposal, unavailable model, refusal, malformed ID, cancellation, and fallback.

- [ ] **Step 3: Implement constrained schema and prompt**

The schema contains proposed IDs, note, mentioned allergens, unresolved text, and acknowledgement flag. The prompt supplies allowed IDs and explicitly forbids safety claims. Run `ValidatedInstructionResolver` on every result.

- [ ] **Step 4: Test on iPhone 16 and record actual availability**

Do not equate Apple Intelligence enabled with guaranteed Foundation Models availability for every language/region/state.

- [ ] **Step 5: Commit**

### Task 11: Build instruction review and allergy acknowledgement UX

**Files:**
- Create: `DishEdit/Instructions/InstructionReviewView.swift`
- Create: `DishEdit/Instructions/AllergyAcknowledgementView.swift`
- Create: `DishEditUITests/InstructionReviewUITests.swift`
- Modify: `DishEdit/App/AppCoordinator.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: visual draft, drafter, validator, cart.
- Produces: approved structured modifiers, editable note, allergy acknowledgement, and checkout-ready cart item.

- [ ] **Step 1: Write failing UI flow tests**

Enter the exact demo sentence. With a fake Foundation Model, assert onion proposal, nut allergy note, warning visibility, disabled Continue until `I understand`, and final cart note. Repeat with forced unavailable model and deterministic fallback label.

- [ ] **Step 2: Implement proposal-before-application**

Do not modify the draft while text generation is in progress. Present additions/removals as review chips. Apply only after explicit approval.

- [ ] **Step 3: Implement exact warning copy and accessible confirmation**

The warning text must match the design spec exactly. Add VoiceOver heading and hint. Do not hide it in terms text.

- [ ] **Step 4: Run tests and commit**

### Task 12: Build the concept checkout and order confirmation

**Files:**
- Create: `DishEdit/Cart/CheckoutView.swift`
- Create: `DishEdit/Cart/OrderConfirmationView.swift`
- Create: `DishEditUITests/CheckoutUITests.swift`
- Modify: `DishEdit/App/AppRootView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: deterministic cart.
- Produces: concept fee breakdown, retained instructions, local order ID, confirmation route.

- [ ] **Step 1: Write failing UI tests**

Assert Burger no tomato + cheddar and the customer note appear, cheddar adds exactly ₹40, allergy warning repeats when required, concept payment is nonfunctional/disclosed, and Place demo order generates a local ID without network.

- [ ] **Step 2: Implement original Zomato-inspired checkout**

Label concept-only address/fees/estimate. Do not fabricate a payment success. The success screen says “Demo order prepared” rather than claiming a restaurant received it.

- [ ] **Step 3: Run tests and commit**

### Task 13: Add engine settings, selection, and forced-failure behavior

**Files:**
- Create: `DishEdit/Generation/VisualEngineSelector.swift`
- Create: `DishEdit/Settings/GenerationSettingsView.swift`
- Create: `DishEditTests/VisualEngineSelectorTests.swift`
- Modify: `DishEdit/App/AppRootView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: all engine availability values and `VisualGenerationPreference`.
- Produces: selected engine/fallback reason and Stage Safe toggle.

- [ ] **Step 1: Write complete selection matrix tests**

For automatic mode assert qualified local → configured remote → reviewed. For explicit modes assert typed unavailable errors fall back to reviewed while retaining the preference and showing the reason. Stage Safe always selects reviewed.

- [ ] **Step 2: Implement settings without misleading status**

Display `Available`, `Unavailable`, `Unverified`, or `Qualified on this device`. Never show Core AI available merely because the framework imports.

- [ ] **Step 3: Run tests and commit**

### Task 14: Integrate Image Playground only as a user-controlled experiment

**Files:**
- Create: `DishEdit/Generation/ImagePlaygroundBridge.swift`
- Create: `DishEditTests/ImagePlaygroundBridgeTests.swift`
- Modify: `DishEdit/Customization/VisualEditorView.swift`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Produces: framework availability, sheet presentation values, accepted temporary URL persistence, and explicit disclosure.

- [ ] **Step 1: Compile a beta-accurate probe**

Verify `supportsImagePlayground`, `imagePlaygroundSheet`, `creationStrategy = .editExisting`, `.low` variety, `.disabled` personalization, and `.any` style against the installed SDK. If a name differs, use the installed SDK and record the difference.

- [ ] **Step 2: Test bridge state without invoking generation**

Mock accepted URL, cancellation, unsupported device, copy failure, and cleanup. The sheet itself remains a manual device test.

- [ ] **Step 3: Present an optional button away from the hero path**

Copy accepted temporary output into app storage. Label it “Apple Image Playground result” and explain that the system interface created it through Private Cloud Compute. Never merge it automatically into the cart.

- [ ] **Step 4: Commit**

### Task 15: Time-box and qualify the Core AI local image engine

**Files:**
- Create: `DishEdit/Generation/CoreAIVisualEditEngine.swift`
- Create: `DishEditTests/CoreAIVisualEditEngineTests.swift`
- Create: `CORE_AI_RESULTS.md`
- Modify: `Package.swift` or Xcode package references only if the official Apple Swift package is required
- Modify: `MODEL_LICENSES.md`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: Apple `CoreAIDiffusionPipeline`, exported model directory, Vision/author mask, ROI compositor.
- Produces: `.coreAI` result or typed unavailable/unqualified/failure.

- [ ] **Step 1: Install/read Apple’s Core AI agent skill when available**

For Claude Code, follow the official repository instructions:

```text
/plugin marketplace add git@github.com:apple/coreai-models.git
/plugin install coreai-skills@coreai-models
```

If plugin installation is unavailable, clone/read `https://github.com/apple/coreai-models` directly. Pin the exact commit used.

- [ ] **Step 2: Export FLUX.2 for iOS using the official recipe**

```bash
git clone https://github.com/apple/coreai-models.git /tmp/apple-coreai-models
cd /tmp/apple-coreai-models
uv run coreai.diffusion.export flux2-klein-4b --platform iOS
```

Record output size, checksums, source model, Apache-2.0 license/NOTICE requirements, Apple repo BSD license, and export commit. Do not assume repo license covers every model asset without checking metadata.

- [ ] **Step 3: Implement protocol tests with a fake pipeline**

Test crop mapping, deterministic prompt/seed, revision, mask-only composite, pixel equality outside ROI, cancellation, thermal/memory refusal, and reviewed fallback. Automated tests must not load the 4B model.

- [ ] **Step 4: Implement the real compile-gated pipeline**

Use 512×512 `.half`, four steps, fixed prompts, fixed seeds, `startingImage`, and measured strength. The public Apple pipeline has no mask input; composite only through the validated mask after image-to-image.

- [ ] **Step 5: Run the hour-eight iPhone 16 gate**

Run cold/warm trials, monitor memory/thermal state, and measure load, specialization, each diffusion step, decode, and composite. Require one valid result by hour eight or remove the real engine from the stage path. Require 20/20 no-crash and p95 ≤8 seconds before calling it qualified.

- [ ] **Step 6: Record an explicit verdict and commit**

`CORE_AI_RESULTS.md` must say `STAGE ENABLED` or `STAGE DISABLED`, with evidence. A disabled engine may remain behind diagnostics if it cannot affect the demo.

### Task 16: Add a configuration-gated remote masked-edit engine

**Files:**
- Create: `DishEdit/Generation/RemoteVisualEditEngine.swift`
- Create: `DishEdit/Generation/RemoteEngineConfiguration.swift`
- Create: `DishEditTests/RemoteVisualEditEngineTests.swift`
- Create: `REMOTE_ENGINE_SETUP.md`
- Modify: `.gitignore`
- Modify: `MODEL_LICENSES.md`
- Modify: `DishEdit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: source crop, PNG mask, prompt, seed metadata, ignored local credentials.
- Produces: `.remote` result or typed configuration/transport/timeout/validation failure.

- [ ] **Step 1: Research and freeze one current mask-capable provider**

Use primary provider documentation. Verify actual image-edit endpoint, mask format, data retention, model name/version, output rights, rate limits, timeout, and secret handling. Record decision and rejected providers. Do not implement from blog snippets.

- [ ] **Step 2: Write URLProtocol-based tests**

Cover request encoding, mask orientation, authorization omission, 401, 429, 5xx, invalid image, timeout, cancellation, and fallback. No test makes a real network call.

- [ ] **Step 3: Implement secure debug configuration**

Use an ignored `Secrets.xcconfig` and/or Keychain. Never place a secret in source, `Info.plist`, screenshots, logs, or diagnostics export.

- [ ] **Step 4: Validate output before accepting it**

Preserve original pixels outside ROI, reject wrong dimensions/empty response, and keep reviewed preview during request. Connectivity failure must not interrupt checkout.

- [ ] **Step 5: Commit only non-secret files**

### Task 17: Expand diagnostics, disclosures, and accessibility

**Files:**
- Create: `DishEdit/Diagnostics/DiagnosticsView.swift`
- Create: `DishEditTests/DiagnosticsSnapshotTests.swift`
- Modify: existing diagnostics inside `DishEdit/ContentView.swift`
- Modify: `DishEdit/Experience/ReconstructionHaptics.swift`
- Modify: `DishEdit/App/AppRootView.swift`

**Interfaces:**
- Consumes: availability, last engine, last mask, instruction source, metrics, and failure injection.
- Produces: judge-readable truth and 20-run launcher.

- [ ] **Step 1: Write diagnostics truth tests**

Prepared result must show `REVIEWED PREVIEW`; Core AI result must show model/commit/duration; remote result must show provider/model without credentials; Foundation Models fallback must say deterministic parser; forced failures must select reviewed path.

- [ ] **Step 2: Remove old duplicate diagnostics and build one source of truth**

Keep the two-finger long-press/info access. Make screenshots safe by redacting all secret fields.

- [ ] **Step 3: Complete accessibility audit**

Run VoiceOver through menu, visual edit without drag, instruction proposal, allergy acknowledgement, checkout, and confirmation. Test Reduce Motion, Reduce Transparency, Bold Text, Button Shapes, and large Dynamic Type.

- [ ] **Step 4: Commit**

### Task 18: Complete end-to-end tests, device reliability, and presentation handoff

**Files:**
- Create: `DishEditUITests/EndToEndFlowUITests.swift`
- Modify: `PHYSICAL_DEVICE_TEST_PLAN.md`
- Modify: `TEST_REPORT.md`
- Modify: `PERFORMANCE_RESULTS.md`
- Modify: `IMPLEMENTATION_STATUS.md`
- Modify: `KNOWN_LIMITATIONS.md`
- Modify: `DEMO_SCRIPT.md`
- Modify: `README.md`
- Modify: `ASSET_SOURCES.md`
- Modify: `ASSET_CHECKSUMS.md`
- Modify: `MODEL_LICENSES.md`

**Interfaces:**
- Consumes: complete app.
- Produces: tested build, honest status, physical results, assets/licenses, two-minute demo, and recovery playbook.

- [ ] **Step 1: Write the complete UI test before final polish**

Automate menu → Edit visually → remove tomato → add cheddar through accessible alternative → confirm → enter demo sentence → approve proposal → acknowledge allergy → checkout → place demo order. Assert exact IDs, ₹40 price delta, note, and no network dependency in reviewed mode.

- [ ] **Step 2: Run build, unit, and UI tests from a clean invocation**

Use `AGENTS.md` commands. Record exact test counts and runtime. Do not state “all tests pass” without command output from this build.

- [ ] **Step 3: Execute the 20-run physical-device matrix**

Include cold launch, airplane mode, Reduce Motion, rapid undo, background/return, forced Vision, Foundation Models, Core AI and remote failures, and warm device. Require 20/20 correct commerce state and zero stale overwrites/crashes.

- [ ] **Step 4: Capture presentation assets**

Capture one menu screenshot, each exploded dish, instruction warning, checkout, diagnostics for every enabled engine, and a two-minute screen recording. Do not record credentials or private notifications.

- [ ] **Step 5: Reconcile every status claim**

Classify each capability as live, prepared, optional/experimental, disabled, or concept-only. State exactly what is mocked. Update the demo script to disclose actual stage engine.

- [ ] **Step 6: Run final git review and commit**

```bash
git status --short
git diff --check
git diff --stat HEAD~1
git add README.md IMPLEMENTATION_STATUS.md TEST_REPORT.md PERFORMANCE_RESULTS.md \
  KNOWN_LIMITATIONS.md PHYSICAL_DEVICE_TEST_PLAN.md DEMO_SCRIPT.md ASSET_SOURCES.md \
  ASSET_CHECKSUMS.md MODEL_LICENSES.md DishEdit DishEditTests DishEditUITests DishEdit.xcodeproj
git commit -m "feat: complete end-to-end DishEdit ordering concept"
```

Expected: no secret, generated build output, temporary model download, or unrelated user file is committed.

## Completion definition

The work is complete only when:

- The exact restaurant → visual editor → instruction review → checkout loop works on the iPhone 16.
- Burger, Sub, and Taco Wrap use merchant-authored ingredients and distinct animations.
- The tomato-removal-plus-cheddar hero loop is reliable and visually credible.
- Natural-language input produces a reviewable proposal and honest fallback.
- Allergy language never claims safety and requires acknowledgement.
- Every cart modifier and price comes from catalog IDs.
- Airplane mode retains a complete, polished reviewed path.
- Diagnostics reveal the true image, mask, and language engines.
- Core AI and remote paths are enabled only when their evidence gates pass.
- Image Playground remains an optional system-owned experiment.
- Automated and physical-device results, limitations, licenses, screenshots, and demo script are delivered.
