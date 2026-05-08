# Bees — project memory for Claude Code

> Read this first. It captures non-obvious facts about the product and
> codebase that have already burned us once. Engineering details live
> in code; this file exists for the things you can't infer from code
> safely.

## The product in one paragraph

Bees is an iOS app where users **adopt a real beehive at a partner farm**.
Subscribers see a 24/7 live HLS feed, real-time sensor stats
(temp / humidity / weight / sound / population / takeoffs / landings /
honey production), and receive **custom-stickered honey jars** shipped
on a cadence. Custom stickers can include the user's text, font, and
color choices. There's a gift flow. iPhone-only, iOS 17+, SwiftUI.

## Business model — facts, not assumptions

**There is no free tier. The product is paid-only.** Three subscription
tiers, all paid (see `Bees/Models/Tier.swift`):

| Tier         | Price/mo | Gated capabilities                                          |
|--------------|----------|-------------------------------------------------------------|
| Pollinator   | $14.99   | Cannot: customize text, pick font, pick color, save favorites, record clips, switch cameras, send gifts |
| Forager      | $24.99   | Can do everything except send subscription gifts             |
| Queen Keeper | $49.99   | All capabilities incl. sending subscription gifts            |

The "Free trial" copy in onboarding is a **trial of a paid tier**, not
a permanent free tier. A user with no active subscription doesn't
exist as a real customer segment.

When tier-gated UI feature-gates the experience, it's between paid
tiers — not free vs paid. Use the actual tier names ("Pollinator",
"Forager") in conversation, not "free" / "paid".

## Repo geography

- `Bees/Models/` — data shapes (`HiveSnapshot`, `Tier`, `StickerDesign`,
  `StatType`, `Shipment`...). Read these before making product
  assumptions.
- `Bees/Services/` — `HiveService` (live sensor mock), `ShipmentService`,
  `StickerService`, `ServiceContainer`. `Fixtures.swift` has the demo
  data.
- `Bees/Views/Tabs/` — top-level tabs: Hive, Honey, Farm, You.
- `Bees/Views/Onboarding/` — `OnboardingFlow`, `TierComparisonView`,
  `TutorialFlow`, `HiveRevealView`.
- `Bees/Views/Honey/` — sticker customizer, gift flow.
- `Bees/Views/Components/` — reusable UI: `HiveStatCard`, `JarPreview`,
  `LoopingVideoPlayer` (incl. `SharedHiveVideoPlayer` and
  `HiveVideoCoordinator`), `BeesButton`, etc.
- `Bees/DesignSystem/` — `BeesColors` (adaptive light/dark),
  `BeesType`, `BeesSpacing`/`BeesRadius`.
- `Bees/Videos/` — bundled video assets (gitignored, copied at build
  time; folder reference, not group).
- `Bees.xcodeproj/project.pbxproj` — manually authored. New Swift
  files must be added in 4 places: PBXBuildFile, PBXFileReference,
  the Components/Tabs/etc. group, and the Sources build phase. ID
  pattern: `BEEF1xxxxx...` for file refs, `BEEF2xxxxx...` for build
  files, sharing the same suffix.

## Architecture notes that aren't obvious from a single file

- **Onboarding is an overlay, not a screen swap.** `ContentView`
  always renders `mainTabs` when authenticated; `OnboardingFlow` is a
  ZStack overlay above it with `.transition(.opacity)`. The hive
  page is already mounted underneath onboarding — the reveal "morphs
  into" the hive tab by fading out the overlay, not by navigating.
- **Hive video uses one shared `AVQueuePlayer`** via
  `HiveVideoCoordinator.shared`. Both `HiveRevealView` and
  `HiveTabView` render `SharedHiveVideoPlayer`, which means SwiftUI
  view swaps don't reload or restart the stream. `PlayerContainerView`
  uses `layerClass = AVPlayerLayer.self` so its bounds animate in
  lockstep with SwiftUI `.frame()` changes (no black bars during
  morph).
- **Adaptive color tokens.** `BeesColors` uses `UIColor` closures with
  `trait.userInterfaceStyle` so light/dark mode works. Don't hardcode
  `.white` or `.black` for surfaces — use `surfaceCard`, `surfacePage`,
  `surfaceMuted`, `surfaceWarmHighlight`.
- **Free Apple Developer signing.** Provisioning expires every 7 days.
  CLI builds will fail until the user opens Xcode at least once after
  expiry; that re-issues the profile.

## Lessons (don't repeat these)

### 2026-05: assumed a free tier existed
**What happened:** When designing the new sticker customizer, I asked
the user how to gate features for "free users." There are no free
users; the lowest-tier (Pollinator) gating I saw in views is paid →
paid feature gating.
**Root cause:** Inferred business model from view-level conditionals
without reading the model files. `Tier.swift` makes the truth obvious
in 30 lines.
**Rule going forward:** Before asking the user product/UX questions
that depend on the business model, read `Bees/Models/Tier.swift` and
any other relevant model files. Use neutral, code-grounded names
("Pollinator users", "lowest-tier users") rather than loaded labels
("free users") that encode an assumption.

## Open notes / known deferrals

- **Sticker design catalog growth.** Currently 8 base designs in
  `StickerBaseDesign.catalog`. If the catalog grows past ~20, the
  studio carousel may need virtualization (lazy rendering / tile
  reuse) to stay smooth. Revisit when adding designs.
- **Sticker color & font axes deferred.** The current studio plan has
  the design carousel and tap-on-jar text editing only. Color and
  font live in the schema (`StickerColor`, `StickerFont`) but aren't
  on the new customizer yet — add as secondary axes (chip strips or
  Watch-Studio-style bottom tabs) when needed.

## Repos

- **Main**: github.com/Rapoport21/bees-ios (private)
- **Sandbox**: github.com/Rapoport21/bees-sandbox (public, copy of main)
  at `~/Documents/Bees-sandbox/`. Used for experiments. Pushes to
  sandbox don't affect main.

## How to extend this file

When you (Claude) discover a non-obvious fact, a recurring confusion,
or an architectural decision worth pinning, append to this file in
the appropriate section. When the user corrects a mistaken
assumption, add it under "Lessons" with the date, what happened, the
root cause, and a rule going forward.
