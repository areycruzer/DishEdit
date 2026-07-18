# DishEdit Prototype Reconstruction Design

## Outcome

Pizza and waffle edits resolve to high-fidelity matched photographs after a 5.4-second image-local reconstruction sequence. The animation should feel like on-device visual intelligence without claiming that a bundled model generated prepared catalog assets.

## Interaction

1. The catalog modifier and price commit immediately.
2. The currently displayed photograph remains stable while the editable region illuminates.
3. A masked scan, particles and progressive blur communicate four phases: understanding the selection, reconstructing texture, matching light and finalizing the preview.
4. The destination photograph crossfades in at 5.4 seconds.
5. Diagnostics continue to report `CATALOG MASK` and `CATALOG PATCH`; the visible status says `ON-DEVICE PREVIEW`, not `LIVE AI`.

Reduce Motion replaces scanning and particles with a restrained progress treatment. Stage-critical UI tests exercise the same 5.4-second timing used by the presentation build.

## Architecture

- `ReconstructionTimeline` owns deterministic duration, phase and progress calculations.
- `DishEditCoordinator` owns the displayed visual state separately from commerce state, schedules revision-bound completion and cancels stale work on undo, redo, reset or dish changes.
- `DishStage` renders the old state during processing, overlays a mask-local visual treatment, and crossfades to the committed state only after the coordinator accepts the matching revision.
- Prepared photographic states remain an explicit catalog fallback. New pizza and waffle states are precise edits derived from each base image.

## Failure handling

- A stale completion can never overwrite newer state.
- Reset and dish switching cancel reconstruction immediately.
- Missing masks fall back to a full-stage restrained scan without blocking the commerce state.
- VoiceOver announces processing and completion; controls remain deterministic.

## Verification

- Swift tests cover phase boundaries, progress clamping, revision rejection and cancellation.
- UI tests verify that commerce state changes before the image finishes and that the reconstruction indicator disappears after completion.
- Final screenshots are visually inspected for plate, crop, lighting and geometry continuity.
