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
| Haptics | Immediate impacts plus a Core Haptics reconstruction pulse; simulator cannot validate feel |
| Liquid Glass controls | Live |
| iOS 27 iterative-segmentation service | Compiled; not stage-enabled without physical-device validation |
| Matched catalog-state fallback | Live, full-frame, offline, and guaranteed |
| Local LCM refinement | Interface only; model not bundled or claimed |
| Networking, payments, order submission | Intentionally absent |

## What is prepared

The visual-state photographs and merchant masks were prepared in advance and are disclosed as reviewed catalog assets. Runtime uses the mask to resolve the ingredient and localize a 5.4-second on-device reconstruction presentation, then reveals the complete matched destination photograph. This avoids partial-composite seams and is not presented in diagnostics as live generative AI. The interaction, timing, state transitions, price changes, animations, haptics, gestures, accessibility, and diagnostics execute live.

## What is mocked

No server result, payment, delivery, restaurant availability, identity, allergy, nutrition, fraud, or safety decision is mocked. The prototype stops at an order-summary illustration because it has no Eternal internal API.
