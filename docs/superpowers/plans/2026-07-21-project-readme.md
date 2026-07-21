# DishEdit Project README Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current hackathon-oriented README with a product-first GitHub README backed by eight fresh screenshots captured from the running iOS app.

**Architecture:** Keep documentation assets isolated under `docs/images/` and reference them with repository-relative paths. Capture the real menu-to-confirmation journey from the current simulator build, then present the product story before technical architecture, setup, testing, limitations, and roadmap.

**Tech Stack:** Markdown, GitHub HTML tables, Xcode 27 beta 3, iOS 27 Simulator, Computer Use, `simctl`, SwiftUI.

## Global Constraints

- Treat DishEdit as an independent project; do not call it a hackathon project or submission.
- Preserve every unrelated source-code and user change already present in the dirty worktree.
- Use only fresh captures from the running app for the final README gallery.
- Store final captures under `docs/images/` using lowercase kebab-case filenames.
- Do not claim live restaurant integration, allergy safety, production readiness, exact preview fidelity, or unconstrained image generation.
- Catalog modifier IDs and prices remain authoritative; visual processing changes only the preview.
- Include the supplied demo URL exactly: `https://youtube.com/shorts/_dE1RKzX3zs?feature=share`.
- Use the installed toolchain at `/Applications/Xcode-27.0.0-Beta.3.app` with the `DishEdit` scheme and an iPhone 17 Pro iOS 27 simulator.

---

### Task 1: Prepare and verify the screenshot build

**Files:**
- Read: `README.md`
- Read: `DishEdit/App/AppRootView.swift`
- Read: `DishEditUITests/EndToEndOrderUITests.swift`
- Create: `docs/images/`

**Interfaces:**
- Consumes: the current `DishEdit.xcodeproj`, `DishEdit` scheme, and existing app navigation.
- Produces: a simulator-installed build that can be navigated through the full ordering flow.

- [ ] **Step 1: Confirm the simulator and installed toolchain**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcrun simctl list devices available | rg 'iPhone 17 Pro|Booted'
```

Expected: at least one available iPhone 17 Pro simulator running iOS 27.

- [ ] **Step 2: Build the current app**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcodebuild build \
  -project DishEdit.xcodeproj \
  -scheme DishEdit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Create the final documentation asset directory**

Run:

```bash
mkdir -p docs/images
```

Expected: `docs/images/` exists and contains no stale README screenshots from an earlier capture session.

### Task 2: Capture the complete product journey

**Files:**
- Create: `docs/images/restaurant-menu.png`
- Create: `docs/images/burger-customization.png`
- Create: `docs/images/sub-customization.png`
- Create: `docs/images/taco-customization.png`
- Create: `docs/images/preview-ready.png`
- Create: `docs/images/cooking-instructions.png`
- Create: `docs/images/checkout.png`
- Create: `docs/images/order-confirmed.png`

**Interfaces:**
- Consumes: the simulator-installed build from Task 1 and accessibility labels already exercised by `EndToEndOrderUITests`.
- Produces: eight portrait PNGs with stable repository-relative paths for Task 3.

- [ ] **Step 1: Launch and inspect the menu with Computer Use**

Use the Computer Use runtime to open Simulator, retrieve its current accessibility tree and screenshot, and confirm that `Copper & Crumb`, `Recommended for you`, and `Customise visually` are visible. Navigate using accessibility elements rather than hard-coded coordinates when possible.

- [ ] **Step 2: Save the menu capture**

Run the simulator screenshot command against the currently booted device:

```bash
DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.3.app/Contents/Developer \
  xcrun simctl io booted screenshot docs/images/restaurant-menu.png
```

Expected: a portrait PNG showing the restaurant and first product card without Simulator chrome.

- [ ] **Step 3: Capture all three expanded customization canvases**

Navigate with Computer Use through Burger, Sub, and Taco Wrap. For each dish, open `Customise visually`, expand the ingredient canvas, confirm the dish-specific title and ingredient labels, and capture the device display as:

```bash
xcrun simctl io booted screenshot docs/images/burger-customization.png
xcrun simctl io booted screenshot docs/images/sub-customization.png
xcrun simctl io booted screenshot docs/images/taco-customization.png
```

Expected: each image shows the correct dish name, floating ingredients, add-on tray, and `Review changes` action.

- [ ] **Step 4: Capture the edited preview**

On Burger, remove Tomato, add Cheddar cheese, select `Review changes`, wait for `Your preview is ready`, and capture:

```bash
xcrun simctl io booted screenshot docs/images/preview-ready.png
```

Expected: the preview shows `No Tomato`, `Add Cheddar cheese`, total price, and a usable `Continue` button.

- [ ] **Step 5: Capture instructions, checkout, and confirmation**

Continue through the real UI. Capture the cooking-instructions screen after adding a short restaurant note and acknowledging the allergen statement, then capture checkout and final order confirmation:

```bash
xcrun simctl io booted screenshot docs/images/cooking-instructions.png
xcrun simctl io booted screenshot docs/images/checkout.png
xcrun simctl io booted screenshot docs/images/order-confirmed.png
```

Expected: all screens use the current white commerce theme and contain no keyboard, debug overlay, dark modal, clipped control, or Simulator chrome.

- [ ] **Step 6: Visually inspect every capture**

Open all eight images and reject any capture with obscured content, animation mid-state, inconsistent status bar, keyboard overlap, clipped CTA, or incorrect dish state. Recapture only the affected state.

### Task 3: Author the product-first README

**Files:**
- Modify: `README.md`
- Read: `IMPLEMENTATION_STATUS.md`
- Read: `KNOWN_LIMITATIONS.md`
- Read: `TEST_REPORT.md`
- Read: `PERFORMANCE_RESULTS.md`
- Read: `ASSET_SOURCES.md`

**Interfaces:**
- Consumes: the eight screenshots from Task 2, the supplied YouTube URL, and factual repository documentation.
- Produces: a self-contained GitHub project page for product visitors and developers.

- [ ] **Step 1: Replace the README hero and product story**

Use this opening structure:

```markdown
<div align="center">

# DishEdit

### Touch what you mean.

DishEdit turns food customization into direct manipulation: remove what you do not want, add restaurant-approved ingredients, and carry those choices into an unambiguous order.

[Watch the product demo](https://youtube.com/shorts/_dE1RKzX3zs?feature=share)

</div>
```

Add compact factual badges for Swift, SwiftUI, iOS 27, and offline deterministic previews. Do not use unsupported status badges.

- [ ] **Step 2: Add the screenshot-led product journey**

Use GitHub-compatible HTML tables with repository-relative `<img>` paths and concise captions. Present:

1. Menu and Burger customization.
2. Sub and Taco Wrap customization.
3. Preview and cooking instructions.
4. Checkout and confirmation.

Each image should use `width="280"` or an equivalent consistent width so two phone screens fit comfortably on desktop GitHub while remaining readable on mobile.

- [ ] **Step 3: Add product and technical sections**

Write concise sections in this order:

```text
What is DishEdit?
The interaction
Three dishes, one visual language
How order truth stays deterministic
Product principles
Architecture
Built with
Project structure
Run locally
Testing
Current limitations
Roadmap
Documentation
```

The architecture section must explain that the catalog changes first, preview rendering is asynchronous, stale visual results are rejected by revision, and visual engines cannot invent modifier identity or price.

- [ ] **Step 4: Add verified local run instructions**

Include the Xcode GUI instructions and the exact build command from Task 1. State that the project has no third-party runtime dependencies.

- [ ] **Step 5: Add honest limitations and roadmap**

Limitations must state that the restaurant, order submission, and imagery are demonstrative; visuals may differ from prepared food; and live generation availability depends on the selected engine and supported device configuration. The roadmap may include merchant onboarding, scalable visual asset preparation, category expansion, and production order integration without claiming these exist today.

### Task 4: Validate and commit the documentation

**Files:**
- Verify: `README.md`
- Verify: `docs/images/*.png`
- Modify only if validation finds a defect: `README.md`

**Interfaces:**
- Consumes: final README and screenshot assets from Tasks 2–3.
- Produces: a verified, committed documentation update without staging unrelated worktree changes.

- [ ] **Step 1: Verify required image and document links**

Run:

```bash
for file in \
  docs/images/restaurant-menu.png \
  docs/images/burger-customization.png \
  docs/images/sub-customization.png \
  docs/images/taco-customization.png \
  docs/images/preview-ready.png \
  docs/images/cooking-instructions.png \
  docs/images/checkout.png \
  docs/images/order-confirmed.png \
  IMPLEMENTATION_STATUS.md KNOWN_LIMITATIONS.md TEST_REPORT.md PERFORMANCE_RESULTS.md; do
  test -f "$file" || exit 1
done
```

Expected: exit code `0`.

- [ ] **Step 2: Verify positioning and demo URL**

Run:

```bash
rg -n 'youtube\.com/shorts/_dE1RKzX3zs|Touch what you mean|How order truth stays deterministic' README.md
if rg -ni 'hackathon|winning submission|guaranteed allergy-safe|production-ready' README.md; then exit 1; fi
```

Expected: the required phrases are present and forbidden positioning is absent.

- [ ] **Step 3: Verify Markdown hygiene and worktree scope**

Run:

```bash
git diff --check -- README.md docs/images
git status --short
```

Expected: no whitespace errors; only `README.md` and the intended `docs/images/*.png` are selected for this documentation commit.

- [ ] **Step 4: Re-run the build command**

Run the Task 1 build command again.

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit only the README deliverables**

Run:

```bash
git add README.md docs/images/*.png
git commit -m "docs: showcase DishEdit product journey"
```

Expected: the commit contains the README and eight screenshots only; unrelated source changes remain unstaged.
