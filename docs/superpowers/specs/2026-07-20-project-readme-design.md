# DishEdit Project README Design

## Objective

Replace the current hackathon-oriented README with a polished project README that serves both product-facing visitors and developers. Present DishEdit as an independent iOS product, explain its core interaction quickly, demonstrate the complete journey with fresh screenshots captured from the running app, and document the architecture honestly.

## Audience

- Product visitors evaluating the problem, interaction, and user experience.
- Recruiters and engineering reviewers evaluating product judgment and technical execution.
- Developers who want to build and understand the project locally.

## Narrative direction

Use a product-first editorial structure. The first viewport should communicate the product without requiring technical context:

1. Product name and tagline: `Touch what you mean.`
2. One-sentence explanation of visual food customization.
3. A prominent clickable demo link using `https://youtube.com/shorts/_dE1RKzX3zs?feature=share`.
4. A compact row of factual technology badges.
5. A curated visual product tour.

Technical architecture, setup, testing, safety constraints, limitations, and roadmap follow the product story.

## Screenshot set

Capture fresh, full-resolution simulator screenshots from the current build using the running app rather than reusing old test attachments. Store final README assets under `docs/images/` with stable descriptive names.

Required states:

- `restaurant-menu.png`: restaurant header and the first product card.
- `burger-customization.png`: expanded Burger ingredient canvas and add-on tray.
- `sub-customization.png`: expanded Sub ingredient canvas and add-on tray.
- `taco-customization.png`: expanded Taco Wrap ingredient canvas and add-on tray.
- `preview-ready.png`: reconstructed dish preview with selected modifiers.
- `cooking-instructions.png`: structured customizations, restaurant note, and allergen confirmation.
- `checkout.png`: order summary, modifiers, charges, and order CTA.
- `order-confirmed.png`: final confirmation and preparation status.

The README should display screenshots in intentional two- or three-column HTML tables so the GitHub page remains compact. Each screenshot requires a short human-readable caption.

## README structure

1. Hero and demo link.
2. `What is DishEdit?`
3. `The interaction` with the product journey.
4. `Three dishes, one visual language` for Burger, Sub, and Taco Wrap.
5. `How it works` describing direct manipulation and deterministic modifiers.
6. `Product principles` covering merchant-approved choices, truthful previews, accessibility, and allergen handling.
7. `Architecture` with a compact text diagram and responsibility table.
8. `Built with` listing SwiftUI, Observation, Vision, Foundation Models integration boundary, Core Image, Core Motion, Core Haptics, OSLog, and Swift Testing only where present in the repository.
9. `Project structure` with the principal source folders.
10. `Run locally` with the verified Xcode 27 beta command.
11. `Testing` with factual current test coverage and links to repository reports.
12. `Current limitations` with concise honest statements.
13. `Roadmap` framed as product development rather than hackathon stretch goals.
14. Demo link, documentation links, and acknowledgements.

## Content rules

- Do not describe DishEdit as a hackathon project or submission.
- Do not claim production readiness, live restaurant integrations, exact visual fidelity, allergy safety, or unconstrained image generation.
- Explain that catalog modifier IDs and prices are authoritative; visual processing only changes the preview.
- Use concise prose, short sections, and screenshot-led storytelling.
- Avoid excessive badges, decorative emoji, generic marketing claims, or unsupported metrics.
- Preserve repository-relative links so the README renders correctly on GitHub.
- Link the YouTube Short directly; use a stable clickable preview only if the external thumbnail resolves reliably.

## Validation

- Capture each screen through the active simulator UI and visually inspect it.
- Verify all local image paths referenced by README exist with exact case.
- Verify every local Markdown link resolves to an existing file.
- Verify the YouTube demo URL appears and opens as an external link.
- Render or parse the final Markdown to check table structure, image sizing, headings, code fences, and visual rhythm.
- Confirm the README contains no hackathon positioning.
- Preserve all unrelated source and user changes in the dirty worktree.

## Acceptance criteria

- A new visitor can understand the product and reach the demo within the first screenful.
- The full menu-to-confirmation journey is visible without opening individual files.
- All eight screenshots are freshly captured and stored under `docs/images/`.
- The README is useful to both a product reviewer and an iOS developer.
- Technical claims match the current codebase and documented limitations.
- Build instructions are verified against the installed toolchain.
