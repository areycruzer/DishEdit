# Implementation Status

## What is real

| Capability | Status |
|---|---|
| Three curated dishes, 12 matched visual states, and 6 author masks | Bundled, offline, live |
| Pixel-accurate tap-to-remove commerce state | Live and UI-tested |
| Masked ingredient lift/dissolve animation | Live |
| Native drag/drop and merchant-approved magnetic anchors | Live and simulator UI-tested; physical-device feel pending |
| Accessible Add alternative | Live and UI-tested |
| Undo, redo, reset, price, modifier IDs | Live and deterministic |
| Before/after scrub, pinch, pan, double-tap reset | Live |
| Layered Core Motion depth | Foreground/body parallax implemented; hardware feel pending |
| Haptics | Live on hardware; simulator cannot validate feel |
| Liquid Glass controls | Live |
| iOS 27 iterative-segmentation service | Compiled; not stage-enabled without physical-device validation |
| Catalog mask/patch fallback | Live, pixel-local, and guaranteed |
| Local LCM refinement | Interface only; model not bundled or claimed |
| Networking, payments, order submission | Intentionally absent |

## What is prepared

The visual-state photographs and merchant masks were prepared in advance and are disclosed as reviewed catalog assets. Runtime Core Image compositing copies only masked pixels into a stable base photograph; it is not presented as live generative AI. The customer interaction, state transitions, price changes, animations, gestures, accessibility, and diagnostics are executed live.

## What is mocked

No server result, payment, delivery, restaurant availability, identity, allergy, nutrition, fraud, or safety decision is mocked. The prototype stops at an order-summary illustration because it has no Eternal internal API.
