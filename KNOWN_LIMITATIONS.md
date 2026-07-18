# Known Limitations and Kill-Gate Outcome

- No physical iPhone is connected and this Mac has no valid Apple code-signing identity or provisioning profile. Device deployment, haptic feel, Core Motion tuning, thermals, and the required 20-run phone gate remain pending.
- iOS 27 Vision compiles, but its asset preparation and mask quality have not been validated on the hero burger. The presentation correctly reports `CATALOG MASK`.
- The LCM model is not bundled. It must not be described as live generation in this build.
- SwiftUI native drag/drop and the approved burger anchor pass XCUITest. Physical finger feel and haptic timing still require the iPhone 16 gate.
- Xcode 27 beta emits a simulator-only `_UIPlatterView` hierarchy warning while XCUITest synthesizes the native drag. It did not break the drop or state assertions, but the team must confirm the drag on hardware.
- Matched catalog photographs are reviewed source states, then composited only through bundled author masks. Pixels outside the mask stay stable; geometry inside the reviewed integration region can still differ.
- The 2.5D treatment is layered foreground/body parallax and restrained perspective, not a reconstructable USDZ object or unrestricted 360-degree model.
- The app uses curated inputs only. It intentionally rejects arbitrary food photos and free-text prompts.
