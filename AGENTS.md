# DishEdit Project Rules

## Toolchain

- Xcode: `/Applications/Xcode-27.0.0-Beta.3.app` (27A5218g)
- Swift: 6.4, Swift 6 language mode, complete strict concurrency
- Project: `DishEdit.xcodeproj`
- Scheme: `DishEdit`
- Bundle identifier: `com.swiftdidload.DishEdit`
- Deployment target: iOS 27.0, iPhone portrait only
- Simulator: `platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0`

## Commands

```bash
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcodebuild build -project DishEdit.xcodeproj -scheme DishEdit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO

DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcodebuild test -project DishEdit.xcodeproj -scheme DishEdit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0' \
  -configuration Debug -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

## Architecture

- SwiftUI first, with `@Observable` state isolated to `@MainActor`.
- Domain values are `Sendable`; image processing and model execution use actors.
- Modifier identity and pricing come from deterministic catalog metadata only.
- Vision may shape visual masks but may never determine order semantics.
- Every async edit carries a revision; stale results are discarded.
- No persistence, network, private APIs, external service, or runtime model download.

## Development workflow

- Write a focused Swift Testing test and confirm the expected failure before behavior code.
- Run focused tests after each domain change, then the complete scheme tests.
- Use `#Preview`, Dynamic Type, VoiceOver labels/actions, and Reduce Motion behavior.
- Do not weaken Swift 6 or strict concurrency to hide failures.
- Preserve the deterministic catalog-patch path even when experimental generation is present.

## Style and beta rules

- No semicolons; prefer trailing closures.
- Group file-local constants in private `Constants` enums.
- Use current iOS 27 SDK signatures verified locally.
- Avoid the deprecated single-argument `onChange(of:perform:)` overload.
- Do not preemptively erase simulators or DerivedData.
