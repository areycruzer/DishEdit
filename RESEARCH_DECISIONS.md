# DishEdit Research Decisions

Accessed 18 July 2026. Material technical claims are verified against primary sources or the installed Xcode 27 beta 3 SDK.

## Accepted

- iOS 27 `GenerateIterativeSegmentationRequest` is implemented behind `IngredientMasking` for a point-seeded visual mask; ingredient identity remains catalog-owned. It is not labeled stage-ready until a physical iPhone 16 passes the mask gate.
- SwiftUI drag/drop and Liquid Glass for direct manipulation and restrained system-native chrome.
- Core Image mask compositing with six bundled author masks for exact outside-region preservation.
- Core Motion and layered SwiftUI transforms for a reliable 2.5D food stage.
- Catalog-authored matched visual states, pixel-accurate mask hit testing, and native SwiftUI drag/drop as the guaranteed offline engine.
- A protocol boundary for optional local Core ML refinement; it is disabled until physical iPhone 16 validation.

## Installed-SDK findings

- `GenerateIterativeSegmentationRequest` requires a seed point, seed box, or seed scribble. The app uses `init(seedPoint:)`; it does not use the invalid zero-argument form found in some secondary reports.
- The async `ImageRequestHandler.perform(_:)` call returns the observation directly. The implementation type-checks against the installed iOS 27 SDK.
- SwiftUI `glassEffect`, `.glass`/`.glassProminent` button styles, `SpatialTapGesture`, `MagnifyGesture`, and custom drag gestures all compile under Swift 6.4.
- The project uses Xcode's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Pure domain types are explicitly `nonisolated`; mutable UI coordination remains `@MainActor`; image services are actors.

## Current engine verdict

- **Guaranteed presentation path:** catalog mask metadata + reviewed generated catalog visual states.
- **Compiled but unverified on hardware:** iOS 27 Vision iterative segmentation.
- **Not bundled:** the roughly 970 MB LCM candidate. No valid signing identity or physical iPhone is connected, so enabling it would violate the hour-eight gate.
- **No mock server and no hidden trigger:** all order modifiers and prices are local deterministic data.

## Rejected from the critical path

- Image Playground: its supported sheet is user-controlled and unsuitable for silent per-gesture regeneration.
- Deprecated programmatic `ImageCreator` on iOS 27.
- Foundation Models for pixels: it does not generate images.
- FLUX.2/Core AI and DreamLite: unacceptable current memory, provenance, licensing, or mask-control risk for the guaranteed phone.
- Third-party inpainting conversions without an explicit compatible license.
- Whole-image regeneration, which can drift the plate, bun, lighting, and dish identity.

## Sources

- https://developer.apple.com/documentation/vision/generateiterativesegmentationrequest
- https://developer.apple.com/documentation/coreml/
- https://github.com/apple/ml-stable-diffusion
- https://developer.apple.com/videos/play/wwdc2026/271/
- https://developer.apple.com/documentation/swiftui/glass
- https://developer.apple.com/documentation/coreimage/ciblendwithmask
- https://developer.apple.com/documentation/coremotion/cmmotionmanager
- https://developer.apple.com/news/?id=dz9wvq0r
- https://huggingface.co/Dadm-n/stable-diffusion-v1-5-lcm-inpainting-coreml
- https://about.doordash.com/en-us/news/ai-powered-pizza-experience
- https://blog.zomato.com/dish-magic-empowering-restaurant-partners-to-create-picture-perfect-menus

## Asset provenance

The food photographs are original outputs generated for this project with OpenAI's built-in image generation tool. Prompts request commercial food photography without brands, text, people, or copied restaurant imagery. Exact generated-source paths and final project filenames are recorded in `ASSET_SOURCES.md`.
