# DishEdit

DishEdit is a native iOS 27 hackathon prototype that replaces a food-modifier form with direct manipulation of the food photograph:

> Tap the tomato and it leaves the burger. Drag cheese onto the dish and the order changes with the picture.

## Run

```bash
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcodebuild -project DishEdit.xcodeproj -scheme DishEdit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

Open `DishEdit.xcodeproj`, choose the DishEdit scheme, and run on iOS 27. The project uses no package manager, server, paid API, runtime download, or private entitlement.

## Architecture

- `Domain`: immutable catalog values, deterministic order state, history, and coordinate mapping.
- `Editing`: bundled author masks, matched destination photographs, Core Image utilities, Vision abstraction, mask policy, revision gate, catalog fallback, and optional LCM boundary.
- `Experience`: `@MainActor @Observable` coordination, a revision-safe 5.4-second reconstruction timeline, Core Motion, Core Haptics, diagnostics, and the SwiftUI stage.
- `Resources`: original food states, transparent add-ons, and local mask policies.

Commerce truth and visual intelligence are intentionally separated. A catalog modifier ID changes the order immediately; visual reconstruction can only change the preview. The guaranteed stage path uses native SwiftUI drag/drop, merchant-authored touch masks, and complete matched destination photographs. Diagnostics explicitly identify the preview as bundled and offline.

## Honest status

The complete offline catalog experience is implemented and tested in the simulator. iOS 27 iterative segmentation compiles but is not labeled device-ready. No live generative model is bundled because no physical iPhone 16 was available for the memory and latency gate. See `IMPLEMENTATION_STATUS.md`, `KNOWN_LIMITATIONS.md`, `TEST_REPORT.md`, and `PERFORMANCE_RESULTS.md` before presenting.
