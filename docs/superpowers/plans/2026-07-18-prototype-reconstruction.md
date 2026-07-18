# Prototype Reconstruction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver matched pizza and waffle edit states plus a disclosed 5.4-second on-device reconstruction simulation.

**Architecture:** A pure timeline describes progress and phases. The coordinator separates committed commerce state from displayed visual state and accepts only revision-matching completions. SwiftUI renders a mask-local processing overlay and final crossfade.

**Tech Stack:** Swift 6.4, SwiftUI, Observation, Core Image, Core Haptics, Swift Testing, XCUITest, built-in image generation.

## Global Constraints

- Minimum deployment target is iOS 27.
- No network or model download at runtime.
- Prepared catalog states must remain disclosed in Diagnostics.
- Production duration is 5.4 seconds; UI tests may use an explicit fast-animation launch argument.
- Commerce modifier IDs and prices must never depend on the visual pipeline.

---

### Task 1: Reconstruction timeline

**Files:**
- Create: `DishEdit/Experience/ReconstructionTimeline.swift`
- Modify: `DishEditTests/DishEditTests.swift`

**Interfaces:**
- Produces: `ReconstructionTimeline`, `ReconstructionPhase`

- [ ] Write tests for phase boundaries and clamped progress.
- [ ] Run the focused suite and verify the new tests fail because the types do not exist.
- [ ] Implement the timeline values.
- [ ] Run the focused suite and verify it passes.

### Task 2: Revision-bound presentation state

**Files:**
- Modify: `DishEdit/Experience/DishEditCoordinator.swift`
- Modify: `DishEditTests/DishEditTests.swift`

**Interfaces:**
- Produces: `displayedVisualStateKey`, `reconstruction`, `completeReconstruction(revision:)`

- [ ] Write tests proving commerce commits immediately and stale completion is rejected.
- [ ] Run the focused suite and verify red.
- [ ] Implement cancellable, revision-bound presentation state.
- [ ] Run the focused suite and verify green.

### Task 3: Mask-local reconstruction treatment

**Files:**
- Modify: `DishEdit/ContentView.swift`
- Modify: `DishEditUITests/DishEditUITests.swift`

**Interfaces:**
- Consumes: coordinator reconstruction state and author-mask assets.
- Produces: five-second on-device processing overlay and final crossfade.

- [ ] Add an XCUITest assertion for the reconstruction indicator.
- [ ] Run it and verify red.
- [ ] Implement scan, particle, phase-label and Reduce Motion presentations.
- [ ] Run it and verify green.

### Task 4: Core Haptics progression

**Files:**
- Create: `DishEdit/Experience/ReconstructionHaptics.swift`
- Modify: `DishEdit/Experience/DishEditCoordinator.swift`

**Interfaces:**
- Produces: start, phase and completion haptics with UIKit fallback.

- [ ] Add unit-testable capability-selection tests.
- [ ] Verify red.
- [ ] Implement the Core Haptics engine and fallback.
- [ ] Verify green.

### Task 5: Matched visual assets and masks

**Files:**
- Replace: `DishEdit/Resources/pizza_no_olives.png`
- Replace: `DishEdit/Resources/pizza_jalapeno.png`
- Replace: `DishEdit/Resources/pizza_no_olives_jalapeno.png`
- Replace: `DishEdit/Resources/waffle_no_strawberries.png`
- Replace: `DishEdit/Resources/waffle_icecream.png`
- Replace: `DishEdit/Resources/waffle_no_strawberries_icecream.png`
- Modify: `ASSET_SOURCES.md`, `ASSET_CHECKSUMS.md`

**Interfaces:**
- Produces: stable 1536×1536 destination photographs and updated edit masks.

- [ ] Generate precise edits from each base image.
- [ ] Inspect geometry, lighting, plate and crop continuity.
- [ ] Regenerate author masks from accepted states.
- [ ] Update provenance and checksums.

### Task 6: End-to-end verification

**Files:**
- Modify: `TEST_REPORT.md`, `IMPLEMENTATION_STATUS.md`, `DEMO_SCRIPT.md`

- [ ] Run clean Simulator and unsigned arm64 device builds.
- [ ] Run all unit and stage-critical UI tests without parallel testing.
- [ ] Extract and inspect final screenshots.
- [ ] Record exact live, prepared and simulated behavior.

