# Validation Report

Tested 18 July 2026 with Xcode 27 beta 3, Swift 6.4, and the iPhone 17 Pro iOS 27.0 simulator.

## Passing evidence

- Simulator app build: passed.
- Unsigned Release build for generic iOS/arm64: passed.
- Swift Testing domain/editing suite: 16 tests passed.
- UI flow `testCompleteBurgerLoopAndSummary`: passed.
- UI flow `testDishSwitchingAndAccessibleAddition`: passed.
- UI flow `testUndoRedoAndResetKeepVisualAndOrderStateTogether`: passed.
- Native drag flow `testMagneticCheeseDragCommitsOnlyInsideApprovedFoodZone`: passed.
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
- Launch into the burger, tomato removal, native cheese drag, accessible addition, ₹289 summary, undo/redo/reset, and all dish switches.

Total stage-critical automated tests: 20 passed, 0 failed.

Machine-readable result bundle: `/tmp/DishEditFinal-20260718-2300.xcresult`. `xcresulttool` reports 20 passed, 0 failed, 0 skipped on the iPhone 17 Pro iOS 27.0 simulator.

The result bundle contains one Xcode 27 beta simulator runtime warning from the system drag preview (`_UIPlatterView`) during XCUITest. The native cheese drop still completed and its commerce state assertions passed; this must be rechecked on the physical iPhone before the stage build is frozen.

## Device gate

Not run: `devicectl` reports only simulated devices; `security find-identity -p codesigning` reports zero valid identities. Do not fill in fabricated p50/p95, thermals, haptic quality, or a 20/20 phone result.

Run `PHYSICAL_DEVICE_TEST_PLAN.md` immediately when the team connects the standard iPhone 16.
