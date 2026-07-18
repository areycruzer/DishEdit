# Claude Code Autonomous Handoff — DishEdit

Copy the prompt below into Claude Code while its working directory is `/Users/cruzer/Documents/projects/ios-load/DishEdit`.

---
You are the principal iOS engineer, interaction designer, visual-computing engineer, test owner, and demo producer taking over an existing SwiftDidLoad hackathon project named **DishEdit**.

Work autonomously from repository inspection through implementation, testing, physical-device qualification, documentation, and demo preparation. Do not stop after producing another plan. Do not ask routine questions. Make conservative in-scope decisions when reliability and scope conflict. Ask only when a missing choice would authorize an irreversible or materially different action.

## Mission

Build a complete native iOS 27 concept showing how Eternal could replace food-modifier forms with direct manipulation of food:

> The dish opens into its ingredients. The customer touches what they do not want, drags in what they do want, and the exact instructions arrive at checkout.

The first ten seconds must be visually memorable:

1. Show a familiar food-commerce menu card.
2. Tap **Edit visually**.
3. The burger unwraps into labeled photographic layers.
4. Tap the tomato and watch it physically leave.

The complete flow is:

```text
Copper & Crumb restaurant menu
    → Edit visually on Burger / Build Your Own Sub / Taco Wrap
    → exploded ingredient canvas
    → confirm and reassemble
    → instruction review
    → optional natural-language Apple Intelligence draft
    → honest allergy acknowledgement when relevant
    → concept checkout with all modifiers and notes carried forward
    → local demo confirmation
```

The experience should make judges say, “This is surprising, understandable, technically honest, and something Eternal could ship.” A hackathon result cannot be guaranteed; optimize for immediate comprehension, polish, stage reliability, and production judgment.

## Start here

Read these files completely before editing:

1. `AGENTS.md`
2. `docs/superpowers/specs/2026-07-19-end-to-end-visual-ordering-design.md`
3. `docs/superpowers/plans/2026-07-19-end-to-end-visual-ordering.md`
4. `README.md`
5. `IMPLEMENTATION_STATUS.md`
6. `KNOWN_LIMITATIONS.md`
7. `TEST_REPORT.md`
8. `PERFORMANCE_RESULTS.md`
9. `RESEARCH_DECISIONS.md`
10. `MODEL_LICENSES.md`
11. `ASSET_SOURCES.md`
12. `PHYSICAL_DEVICE_TEST_PLAN.md`
13. `DEMO_SCRIPT.md`

Then inspect all source files, tests, the Xcode project, `git status`, and the last five commits. Preserve the existing working prototype and its history. Do not rewrite from scratch, reset, or discard user changes.

The current repository already has:

- A native SwiftUI iOS 27 project using Swift 6.4 strict concurrency.
- A working full-screen food editor for Burger, Pizza, and Waffle.
- Merchant-authored hit masks.
- Tap-to-remove, native drag/drop, magnetic placement, undo/redo/reset, price changes, before/after scrub, pinch/pan, Core Motion depth, haptics, Liquid Glass, accessibility actions, and diagnostics.
- Revision-bound asynchronous state that rejects stale results.
- A 5.4-second mask-local reconstruction presentation.
- Reviewed, complete destination images providing a reliable offline fallback.
- iOS 27 iterative Vision segmentation code that compiles but is not yet stage-qualified.
- No bundled live image-generation model, real backend, payment, or Eternal API.

The existing Pizza and Waffle product scope is being replaced—not merely renamed—by:

- Build Your Own Sub
- Taco Wrap

Keep the strongest reusable architecture and interaction work.

## Locked product decisions

- One fictional traditional restaurant: **Copper & Crumb**.
- Exactly three products: The Classic Burger, Build Your Own Sub, and Taco Wrap.
- The word Sub describes a sandwich format; do not use or imply Subway branding.
- Menu and checkout should feel structurally familiar to a Zomato customer, but use original UI and assets. You may inspect public Zomato screenshots as design references. Do not bundle screenshots, scrape restaurant photos, copy layouts pixel-for-pixel, or imply a production integration.
- Every product card has normal **Add** and secondary **Edit visually** actions.
- Burger and Taco use exploded layers; the Sub opens into a compact digital sandwich-counter assembly experience.
- Ingredient identity, availability, placement, modifier ID, and price come only from the merchant catalog.
- Vision may create a visual mask after catalog hit testing. Vision never decides what was ordered.
- AI can draft text or preview pixels. AI never creates an order modifier without catalog validation and explicit approval.
- The app must work in airplane mode through reviewed assets.
- No arbitrary customer image, free-text image prompt, real order, payment, account, address, delivery, restaurant availability, nutrition, biometric, fraud, medical, or safety claim.
- Use original/generated-for-project or explicitly compatible licensed assets. Maintain full provenance and checksums.
- Portrait iPhone, iOS 27 minimum, Xcode 27 beta 3, standard iPhone 16 stage hardware.

## Required catalog

Use the exact dish ingredients, additions, removals, and prices in the design spec. Stable product IDs are:

```text
burger
sub
taco-wrap
```

Stable ingredient IDs must begin with the product ID. The hero burger path is:

```text
burger.tomato: default present, removable, ₹0
burger.cheddar: default absent, addable, +₹40
```

Cart, pricing, summary, instruction, accessibility, diagnostics, and cache values must all derive from stable IDs—not image output or localized labels.

## Natural-language instructions and allergy behavior

Use Apple Foundation Models to propose structured customer instructions when available. The demo phrase is:

> I have a nut allergy and don’t like onions.

The expected behavior is:

- Propose removing onion only if it is a supported, present merchant ingredient.
- Preserve “Customer reports a nut allergy” as a note.
- Require customer review before changing any modifier.
- Require explicit allergy acknowledgement.
- Label whether Foundation Models or the deterministic fallback parser produced the proposal.

Display this exact warning:

> **Important allergy note**
>
> This request will be shared with the restaurant. The restaurant cannot guarantee an allergen-free preparation or prevent cross-contact. If your allergy is severe, contact the restaurant before ordering.

Never infer allergy severity, guarantee safety, claim that ingredient removal prevents cross-contact, or silently apply the model’s output.

If Foundation Models is unavailable, refused, cancelled, or malformed, use an honest deterministic parser for supported demo phrases and manual review. Do not fake Apple Intelligence.

## Correct Apple image-generation strategy

There are four distinct paths. Keep them separate in code and in judge-facing language.

### 1. Reviewed Preview — mandatory and stage-safe

This is the complete offline path using matched destination photographs or high-quality merchant ingredient composites. It must always work and must be labeled `REVIEWED PREVIEW`, never `LIVE AI`.

### 2. Core AI — experimental silent on-device generation

iOS 27 Core AI can run developer-supplied models locally. It does **not** expose Apple’s private Image Playground model. Evaluate Apple’s official Core AI FLUX.2 pipeline on the physical iPhone 16.

Official repository:

https://github.com/apple/coreai-models

For Claude Code, install Apple’s official Core AI skill when available:

```text
/plugin marketplace add git@github.com:apple/coreai-models.git
/plugin install coreai-skills@coreai-models
```

If plugin installation is unavailable, inspect a pinned clone directly.

Primary model recipe:

https://github.com/apple/coreai-models/tree/main/models/flux2

The official iOS pipeline supports FLUX.2 Klein 4B, 512×512, four-step generation, and image-to-image through `startingImage`/`strength`. Its public `PipelineConfiguration` currently has no inpainting-mask input:

https://github.com/apple/coreai-models/blob/main/swift/Sources/CoreAIDiffusionPipeline/Pipelines/PipelineConfiguration.swift

Therefore, for DishEdit:

1. Resolve ingredient semantics with merchant metadata.
2. Acquire/validate a Vision or author mask.
3. Compute a tight, expanded square ROI.
4. Run 512×512 image-to-image with fixed prompt and seed.
5. Composite the result only through the feathered mask.
6. Preserve every pixel outside the ROI.
7. Reject weak output and retain Reviewed Preview.

Do not assume acceptable performance because Apple marks the model iOS-compatible. Measure model size, specialization, memory, thermal behavior, image quality, and p50/p95 on the actual iPhone 16. Core AI enters the stage path only after 20/20 no-crash loops and p95 ≤8 seconds. If it cannot produce one credible result by hour eight, mark it stage-disabled and stop spending core build time on it.

Underlying model/license:

https://huggingface.co/black-forest-labs/FLUX.2-klein-4B

Pin commits and record all code/model licenses, NOTICE requirements, checksums, and asset sizes. The Apple repository license does not automatically replace the model license.

### 3. Remote mask-capable image-edit API — optional

Research current provider documentation and freeze one provider only if it supports a source image plus mask, photorealistic editing, acceptable rights/retention, and a usable hackathon response time. Implement it behind `VisualEditEngine`; never hard-code or commit a secret. Use an ignored `.xcconfig` and/or Keychain. Tests must use `URLProtocol`, never live requests.

The remote path must never be required for build, checkout, or stage success. A timeout, missing secret, 401, 429, 5xx, invalid image, or network loss retains Reviewed Preview and commerce state.

### 4. Apple Image Playground — optional user-controlled system experience

WWDC26 session:

https://developer.apple.com/videos/play/wwdc2026/375/

Framework:

https://developer.apple.com/documentation/imageplayground

Image Playground lets third-party apps present the same Apple system experience and high-quality models. In iOS 27, the high-quality model runs on Private Cloud Compute, has system-managed usage limits, and requires a system sheet or view controller where the user previews and accepts the result. It is not an offline, silent, mask-constrained function.

Use `imagePlaygroundSheet` only behind an explicit **Try Apple Image Playground** experiment. Seed it with the current image and fixed concept, disable personalization, use low creation variety, and use `.editExisting` if the installed beta SDK confirms that API. Copy the accepted temporary URL into app storage. Never insert the result automatically into the cart.

Do not use deprecated `ImageCreator`. Apple says it will stop working in iOS 27/TestFlight:

https://developer.apple.com/news/?id=dz9wvq0r

## Vision and Foundation Models boundaries

Use WWDC26 image-understanding APIs correctly:

https://developer.apple.com/videos/play/wwdc2026/237/

- `GenerateIterativeSegmentationRequest` creates/refines an object mask from touch input.
- Foundation Models can analyze images and draft structured/text output.
- Neither API generates replacement image pixels.
- Check/download required Vision assets and provide author-mask fallback.
- Compile probes against the installed Xcode SDK; beta names in transcripts may differ from beta 3 headers.

## Required engineering architecture

Follow the exact file map, interfaces, TDD sequence, kill gates, and completion definition in:

`docs/superpowers/plans/2026-07-19-end-to-end-visual-ordering.md`

Key boundaries:

```text
Restaurant       merchant catalog and menu
Customization    ingredient draft, layouts, gestures, animations, history
Instructions     Foundation Models, deterministic parser, validation, allergy UX
Cart             cart items, exact paise pricing, checkout, local demo order
Generation       reviewed/Core AI/remote/Image Playground engines and cache
Diagnostics      truth, timings, availability, fallbacks, forced failures
```

Use one `@MainActor @Observable` app coordinator with explicit routes. Keep domain values `Sendable`. Keep model/image work off the main actor. Every asynchronous visual request carries a monotonically increasing revision; discard stale results even if cancellation fails.

Expose generation settings:

```text
Automatic
On-device Core AI
Remote API
Reviewed Preview
Stage Safe
```

Automatic order:

```text
device-qualified Core AI
    → configured and reachable remote engine
    → reviewed preview
```

Stage Safe always uses Reviewed Preview. Switching engines must never change cart state.

## Visual and interaction quality

The restaurant/menu and checkout use a light food-commerce presentation with red accents. The editor moves into cinematic warm black with the food dominating. Use Liquid Glass sparingly for tray, navigation, settings, and compact order surfaces.

Avoid generic AI symbols, chat UI, neon glows, excessive gradients, dashboard density, or framework-showcase clutter.

Opening animation:

- Hold assembled dish briefly.
- Increase depth/shadow.
- Separate layers over approximately 550–750 ms with staggered springs.
- Reveal labels only after the layers are readable.
- Finish with one restrained rigid haptic.

Removal:

- Haptic and visual response under 100 ms.
- Mask edge appears.
- Ingredient lifts and leaves/dissolves.
- Catalog ID, chip, and price commit immediately.

Addition:

- Ingredient lifts from tray.
- Only approved zones highlight.
- Rigid haptic on valid-zone entry.
- Snap with a short spring and soft finishing pulse.
- Invalid drop makes no order change.

Confirmation:

- Reverse the layer animation.
- Show Reviewed Preview immediately enough to avoid a blank spinner.
- Optional genuine refinement may take 5–6 seconds under a mask-local `Preparing visual preview` animation.
- Disclose the engine in diagnostics.

Support VoiceOver completion without drag, Dynamic Type, Reduce Motion, Reduce Transparency, Button Shapes, Bold Text, and non-haptic cues.

## Research and implementation rules

- Time-box new research. Prefer Apple documentation, WWDC sessions, installed SDK interfaces, official source repositories, and provider/model primary documentation.
- Record URLs, dates, SDK signatures, pinned commits, licenses, model/input shapes, asset sizes, rejected approaches, and decisions in existing ledgers.
- Do not import code without a compatible explicit license.
- Use current SDK probes instead of remembered API signatures.
- Use TDD: failing focused test, failure confirmation, minimal implementation, focused pass, full pass, commit.
- Make small intentional commits. Preserve unrelated/user changes.
- Do not weaken Swift 6 strict concurrency.
- Do not add widgets, Live Activities, Watch, Siri, multiplayer, arbitrary photos, restaurant search, recommendations, delivery tracking, or additional dishes.
- Do not spend the hackathon trying multiple diffusion stacks after the Core AI hour-eight gate fails.

## Required validation

Run the exact build/test commands in `AGENTS.md` throughout.

Complete at least 20 physical iPhone 16 hero loops covering:

- Normal burger removal and cheddar addition.
- Different tomato tap points.
- Different addition start positions.
- Remove/add/undo/redo/reset.
- Cold launch.
- Airplane mode.
- Reduce Motion.
- App background/return.
- Forced Vision failure.
- Forced Foundation Models failure.
- Forced Core AI failure.
- Remote timeout/failure.
- Warm-device/thermal run.

Acceptance:

- 20/20 correct catalog IDs, instruction state, and price.
- Zero crashes, memory terminations, stale overwrites, or hidden triggers.
- Immediate interaction response under 100 ms.
- Reviewed Preview always succeeds without network.
- No incorrect or unsupported checkout instruction.
- Core AI stage-enabled only if its explicit device gate passes.
- No claim stronger than the recorded evidence.

## Exact demo

Opening:

> “Food customization is still a form. DishEdit turns the food itself into the form.”

Then:

1. Show Copper & Crumb and its three items.
2. Tap **Edit visually** on Burger.
3. Let the burger unwrap.
4. Tap tomato: “I touch what I don’t want.”
5. Drag cheddar: “And drag in what I do want.”
6. Reassemble and show the visual preview.
7. Enter “I have a nut allergy and don’t like onions.”
8. Show the Apple Intelligence/fallback proposal, exact catalog validation, and honest warning.
9. Confirm and show checkout already populated.
10. Briefly show diagnostics and disclose the actual path.

Closing:

> “The picture can be intelligent, but the order is always exact. Eternal already knows what a restaurant can prepare; DishEdit lets the customer touch what they mean.”

## Final deliverables

Do not declare completion until you provide:

- Working Xcode project and clean build.
- Full automated test output.
- Physical iPhone 16 results or an explicit statement that they could not be run.
- Screenshot and screen recording of each dish and full flow.
- Actual engine status for every transition.
- Core AI benchmark and enable/disable verdict.
- Remote configuration and test status with no secret committed.
- Asset, model, source, license, and checksum ledgers.
- Updated implementation status and known limitations.
- Exact two-minute demo script.
- Recovery script for every advanced-API failure.
- Clear classification of what is live, generated, prepared, experimental, disabled, or concept-only.

Begin now by reading the required files, inspecting the repo and SDK, running the baseline build/tests, and executing Task 1 from the implementation plan. Continue task-by-task until the completion definition is satisfied or a genuinely external blocker remains.

---
