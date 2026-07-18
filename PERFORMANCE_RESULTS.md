# Performance Results

Measured 18 July 2026 with Xcode 27 beta 3 and the iPhone 17 Pro iOS 27.0 simulator unless stated otherwise.

| Metric | Result | Status |
|---|---:|---|
| Stage-critical automated tests | 26/26 passed | 21 unit + 5 UI, verified on simulator |
| Catalog app network dependency | None | Verified by architecture and airplane-safe resources |
| Pixels outside composite mask | 100% unchanged in the 8×8 exhaustive fixture | Verified on simulator |
| Immediate haptic latency | Not measurable in Simulator | Requires iPhone 16 |
| Deterministic preview p50/p95 | Not recorded | Requires 20-run iPhone 16 gate |
| Reset p50/p95 | Not recorded | Requires 20-run iPhone 16 gate |
| Core Motion response | Not measurable in Simulator | Requires iPhone 16 |
| Vision mask acceptance | Not measured | Requires hero-image device gate |
| LCM p50/p95 and memory | Not applicable | Model intentionally not bundled |

OSLog signposts are implemented for the immediate commerce update and matched-catalog-photograph lookup. The production reconstruction presentation is fixed at 5.4 seconds; that timing is intentional interaction design, not a measured neural-generation latency. No live-generation signpost or latency is claimed because live generation is disabled. The presentation must not quote thermal, memory, or model-latency numbers until `PHYSICAL_DEVICE_TEST_PLAN.md` is completed on the actual standard iPhone 16.
