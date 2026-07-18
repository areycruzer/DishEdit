# Validation Report

## End-to-end baseline — 19 July 2026

Tested 19 July 2026 with Xcode 27 beta 3 (27A5218g), Swift 6.4, iPhone 17 Pro iOS 27.0 simulator.

- Build: **SUCCEEDED** (Debug, unsigned, iOS Simulator arm64)
- Unit tests (DishEditTests): **21/21 passed** in 0.058 s
- UI tests (DishEditUITests): **6/6 passed** in 121 s (serial)
- Total automated: **27/27 passed, 0 failures**

This baseline covers the existing Burger/Pizza/Waffle prototype before the end-to-end Copper & Crumb evolution begins.

---

## Previous report

Tested 18 July 2026 with Xcode 27 beta 3, Swift 6.4, and the iPhone 17 Pro iOS 27.0 simulator.

## Passing evidence

- Simulator app build: passed.
- Unsigned Release build for generic iOS/arm64: passed.
- Swift Testing domain/editing suite: 21 tests passed.
- UI flow `testCompleteBurgerLoopAndSummary`: passed.
- UI flow `testDishSwitchingAndAccessibleAddition`: passed.
- UI flow `testUndoRedoAndResetKeepVisualAndOrderStateTogether`: passed.
- Native drag flow `testMagneticCheeseDragCommitsOnlyInsideApprovedFoodZone`: passed.
- Reconstruction flow `testReconstructionAppearsBeforePhotographCommits`: passed and produced an inspected in-progress screenshot.
- Core loop visually inspected from kept simulator screenshots for burger, pizza, and waffle.
- App bundle contains all 21 expected PNG resources and `mask_policies.json`.
- No network or third-party runtime package is present.

## Automated coverage

- Catalog shape and curated modifiers.
- Order state, price in paise, undo, unsupported-modifier rejection.
- Aspect-fit image coordinate conversion and letterbox rejection.
- Pixel-accurate author-mask hit testing and merchant-approved anchors.
- Mask acceptance and spill rejection.
- Model-unavailable selection of `CatalogPatchEngine`.
- Stale-revision invalidation.
- Exact reset/undo/redo restoration, transformed-coordinate inversion, resource resolution, and stable cache keys.
- Pixel equality for every pixel outside a masked composite region.
- Revision-safe 5.4-second reconstruction phases, progress clamping, complete matched-state selection, Core Haptics fallback selection, and commerce-before-visual commit.
- Launch into the burger, tomato removal, native cheese drag, accessible addition, ₹289 summary, undo/redo/reset, and all dish switches.

Total stage-critical automated tests: 26 passed, 0 failed (21 unit and 5 UI).

Machine-readable result bundles: `/tmp/DishEditFinalUnit-20260719-0020.xcresult` and `/tmp/DishEditFinalUISerial-20260719-0017.xcresult`. The five stage-critical UI flows pass when run serially on the named iPhone 17 Pro iOS 27.0 simulator.

Xcode 27 beta emits a simulator runtime warning from the system drag preview (`_UIPlatterView`) during XCUITest. A custom preview made the synthesized drop intermittent, so it was removed; the stable native default preview now completes the drop and its commerce assertions. This must still be rechecked on the physical iPhone before the stage build is frozen.

## Device gate

Not run: `devicectl` reports only simulated devices; `security find-identity -p codesigning` reports zero valid identities. Do not fill in fabricated p50/p95, thermals, haptic quality, or a 20/20 phone result.

Run `PHYSICAL_DEVICE_TEST_PLAN.md` immediately when the team connects the standard iPhone 16.
