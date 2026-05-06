# Bees iOS — Open Decisions Resolved + Wireframes Batch 3

**Version:** 1.0
**Date:** 2026-05-05
**Companion to:** `BEES_APP_PLAN.md`, `BEES_WIREFRAMES_HIVE_AND_STICKER.md`, `BEES_WIREFRAMES_REVEAL_CANCEL_GIFT.md`

This document:
1. Resolves the 6 open decisions flagged in batch 2 (with recommendations and rationale)
2. Deep-wireframes the next four high-risk targets: Demo Hive Viewer, full Onboarding Sequence, Honey Home, Stat Detail charts

---

# PART 0 — Open Decisions Resolved

## 0.1 Cancel access-loss timing

**Recommendation: Option C — server-flag toggleable, default to period-end for launch.**

| | Recommended for launch | Optional post-launch |
|---|---|---|
| Behavior | User keeps video access until paid period ends | User loses access at moment of cancel |
| App Store risk | Low (Apple-standard) | Medium (may be flagged as user-hostile) |
| Retention pressure | Lower | Higher |
| Final shipment | Does not ship either way | Does not ship either way |

**Why this approach:**
- Apple's IAP pattern is "user pays through period; cancellation prevents next charge" — fighting that pattern in v1 invites review delays
- The "no final shipment" rule is what actually protects margin (jar COGS + shipping is the expensive part, not video bandwidth)
- Server-flag implementation lets you flip to immediate-revoke later if churn data justifies it
- Disclosure copy in cancel flow §2.5 stays valid for both options with one swap of one line

**Implementation impact:**
- Backend feature flag `cancellation.accessRetentionPolicy: "periodEnd" | "immediate"`
- Disclosure copy uses `{accessLossDate}` token: renders as `today` for immediate, as `{periodEndDate}` for period-end
- Entitlement service reads flag when determining stream JWT TTL post-cancel
- Single A/B-able variable; can experiment in cohorts later

**Action:** In disclosure step (§2.5 in batch 2), replace "You'll lose video access immediately" with `"You'll lose video access on {accessLossDate}"` — works for both modes.

---

## 0.2 Subscription gift pricing

**Recommendation: Tiered discount by duration.**

| Duration | Multiplier | Forager example | Why |
|---|---|---|---|
| 3 months | × 1.00 | $74.97 | Straight monthly — short commit, premium price |
| 6 months | × 0.95 | $142.44 | Modest 5% off — encourages mid-term gifting |
| 12 months | × 0.83 | $249.00 | Matches annual self-sub discount (~17% off) |

**Why:**
- Mirrors your existing self-sub annual discount (annual is ~17% off monthly)
- Prevents arbitrage: someone buying a 12-month gift for themselves wouldn't pay more than buying an annual sub
- 3-month "premium" price reflects gift convenience — no recipient hassle, prepaid, locked tier
- Ends at clean retail prices ($74.97, $142.44, $249.00) — easy to communicate

**SKU implications:** 9 non-renewing sub products in App Store Connect (3 tiers × 3 durations). Each has its own price. Apple rounds to nearest tier — set pricing in App Store Connect with these targets, accept Apple's nearest-pricing-tier match.

---

## 0.3 Premium packaging price

**Recommendation: Tiered options instead of single $12 toggle.**

| Tier | Price | Contents |
|---|---|---|
| Standard | $0 (included) | Kraft box, paper wrap, sticker on jar |
| Gift Wrap | $6 | Standard + ribbon + handwritten-style label |
| Premium Box | $18 | Wooden box, gold seal, ribbon, mini honey wand |

**Why three tiers:**
- $6 Gift Wrap captures impulse upgraders who balk at $12+
- $18 Premium creates aspirational margin (~70% gross margin if wooden box wholesale ~$5)
- Three options reads as "thoughtful range" not "upsell"
- Default is Standard (free); no pre-checked upgrade

**For v1 simplicity, you could ship just Standard + $18 Premium and add Gift Wrap in a later release.** The 3-tier wireframe in batch 2 §3.3 can adapt.

---

## 0.4 Gift card visual styles

**Recommendation: Three brand-aligned themes.**

1. **Classic Hexagon** — geometric honeycomb pattern, warm cream + honey gold palette, serif typography. Reads as: timeless, premium, formal. Best for: anniversaries, weddings, "thinking of you" gifts to older recipients.

2. **Watercolor Garden** — hand-painted floral + bee illustrations, soft pastel washes, script accent typography. Reads as: warm, personal, organic. Best for: birthdays, mother's day, friend gifts.

3. **Modern Minimal** — clean lines, single bee glyph, generous negative space, sans-serif. Reads as: chic, contemporary, gender-neutral. Best for: corporate gifts, housewarmings, "just because" gifts to younger recipients.

**Designer brief:**
- Each card: 1200×1800px portrait at print scale, with a clear text safe-zone for the gifter's message
- Color palettes drawn from app design tokens (`bees/honey/*`, `bees/comb/*`, `bees/leaf/*`)
- All three must work in both English text rendering and recipient name overlay
- Provide print-ready PDFs + screen previews
- Recipient email rendering: 600px wide responsive

**File deliverables for engineering:** SVG masters, JPG previews, font files (or system substitutes), token mapping for color customization (if we want recipient theme variants later).

---

## 0.5 Gift message moderation

**Recommendation: Lenient pass — block harm, not personal info.**

| Category | Sticker text (public, printed) | Gift message (private, digital card) |
|---|---|---|
| Profanity, slurs | Block | Block |
| Hate speech | Block | Block |
| Sexual content | Block | Block |
| Phone numbers | Block | **Allow** |
| Email addresses | Block | **Allow** |
| URLs | Block | **Allow** |
| Physical addresses | Block | **Allow** |
| Emojis | Block (typography concern) | **Allow** |
| Length | 48 chars | 200 chars (already in spec) |

**Why:**
- Sticker text is a printed public artifact; PII or URLs there create real harm vectors
- Gift message is a 1:1 digital card delivered to a known recipient via authenticated email; same PII rules don't apply (it's literally what the medium is for — "call me when it arrives", "love, Mom")
- Emojis in gift messages are expected; in sticker print they're a typography mess
- Same harm-content blocks (profanity, hate, sexual) protect both contexts equally

**Implementation:** Two distinct moderation profiles in your moderation service config: `sticker_text_strict` and `gift_message_lenient`. Both share the harm blocklist; gift message profile turns off PII regex blocks.

---

## 0.6 Recipient collision for subscription gifts

**Recommendation: Always offer "Extend" as default with "Save for later" as alternative — recipient chooses.**

```
Existing user receives sub gift
       │
       ▼
  Email + in-app notification
       │
       ▼
  S-GIFT-10 claim screen variant for existing users:
  "Nick gifted you 6 months of Forager. You're already
   on Pollinator. Choose how to use it:"
       │
       ├── [Extend my time]  → adds 6 months at GIFTER'S TIER 
       │                       starting from current period end
       │                       (current Pollinator stays in effect 
       │                       until it would have ended;
       │                       then Forager kicks in for 6 months)
       │
       └── [Save for later]  → gift held in escrow, tier+duration 
                                preserved, claimable for up to 12 months
                                or whenever current sub lapses
```

**Tier handling logic:**
- If gift tier ≤ recipient's current tier: gift extends at gift tier (downgrade after current period); recipient sees "Your Forager continues until {date}, then Pollinator from {date} to {date}, then your normal billing resumes"
- If gift tier ≥ recipient's current tier: gift extends at gift tier; recipient sees "Your Forager continues until {date}, then your gift Queen Keeper kicks in for 6 months, then you're back to Forager"
- Either direction, no money changes hands during gift period; recipient's auto-renewal pauses through gift duration, resumes after

**Why "always show both":**
- "Extend" is delightful for engaged users
- "Save for later" handles users who plan to cancel anyway, are travelling, etc.
- No automatic decision = no surprises
- 12-month claim window is generous but bounded; after that, gift auto-refunds gifter

**Edge cases:**
- Recipient on a paused sub: extend pauses sub through gift duration too; treat the same
- Recipient in cancel-grace state (soft-deleted): claim restores account + applies gift
- Recipient tries to claim twice: server idempotent (claim token can only redeem once)

**Notification copy:**
- Gifter sees: "{Recipient} chose to extend their existing subscription. Their Bees gets {duration} of {tier} starting {date}."
- OR: "{Recipient} saved your gift for later. We'll let them know when it's a good time to use it."

---

# PART 1 — S-AUTH-03 Demo Hive Viewer

## 1.1 Purpose

Pre-signup conversion screen. The user has tapped "See a demo first" from the value carousel. Goal: prove the app's value (it's not just a video player, it's an experience) and create a "want it" moment that makes signup the obvious next step.

**Critical constraints:**
- App Store review will scrutinize this for being a deceptive paywall workaround. It must clearly be a demo, not pretend to be the real product.
- Cannot show real user data (privacy)
- Cannot pretend simulated stats are live (deception)
- Must have a clear path to signup that doesn't feel coerced

## 1.2 Variants Matrix

| Variant | Trigger | Difference |
|---|---|---|
| **Default** | Tap "See a demo first" from S-AUTH-02 | Full demo experience |
| **From locked-feature tap** | User tapped a locked stat / customize from demo | Soft signup sheet S-AUTH-06 overlays |
| **Returning demo viewer** | User came back to demo a second time | Conversion banner appears earlier (15s vs 45s) |
| **Reduce Motion** | System setting | Disables ambient bee animation, smooths counter ticks |

## 1.3 Anatomy

```
┌─────────────────────────────────────────────────┐
│ ① TOP CHROME (52pt, blurred material)          │
│   ← back · DEMO badge · Adopt now ▸             │
├─────────────────────────────────────────────────┤
│                                                 │
│ ② DEMO VIDEO ZONE (240pt)                       │
│   - Real footage, 24h-delayed, anonymized       │
│   - "DEMO" watermark always visible             │
│                                                 │
├─────────────────────────────────────────────────┤
│ ③ DEMO HIVE PILL (44pt)                         │
│   - "Demo Hive · Sample Farm · THRIVING"        │
├─────────────────────────────────────────────────┤
│ ④ STAT STRIP (96pt)                             │
│   - Same 7 tiles as real, simulated data        │
├─────────────────────────────────────────────────┤
│ ⑤ ACTIVITY COUNTER (124pt)                      │
│   - Procedural simulated counters               │
├─────────────────────────────────────────────────┤
│ ⑥ JAR PREVIEW TEASER (180pt)                    │
│   - Rotating jar with sample sticker            │
│   - "Customize one yourself →" CTA              │
├─────────────────────────────────────────────────┤
│ ⑦ FLOATING FAB (56pt, persistent)               │
│   - "Adopt your own hive" pinned bottom-right   │
├─────────────────────────────────────────────────┤
│ ⑧ FLOATING BANNER (40pt, conditional)           │
│   - Appears at 45s: "Loving it? Get your own →" │
└─────────────────────────────────────────────────┘
```

## 1.4 ASCII Wireframe

```
┌─────────────────────────────────────────────────┐
│ ←  ┌─DEMO─┐                       Adopt now ▸  │
│    └──────┘                                     │
├─────────────────────────────────────────────────┤
│                                                 │
│   ┌─DEMO─┐ This is a sample hive,               │
│   └──────┘ not live data.                       │
│                                                 │
│        ░░░░░░░ DEMO VIDEO ░░░░░░░░              │
│        ░░░░░ (24h-delayed loop) ░░░             │
│        ░░░░░░░░░░░░░░░░░░░░░░░░░░░              │
│                                                 │
├─────────────────────────────────────────────────┤
│  Demo Hive            ┌─THRIVING─┐              │
│  Sample Farm · CA     └──────────┘              │
├─────────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐  → 🔒       │
│  │88°F│ │58% │ │43lb│ │54k │ │1.1k│             │
│  │TEMP│ │HUM │ │WGT │ │BEES│ │OUT │             │
│  └────┘ └────┘ └────┘ └────┘ └────┘             │
│  Tap any tile for details → 🔒                  │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  🐝  ACTIVITY RIGHT NOW (simulated)      │  │
│  │     ↑ 1,142          ↓ 1,138              │  │
│  │     Take-offs        Landings             │  │
│  │  ▓▓▓░░░░░░░░░ Last 60 seconds             │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  ✨ DESIGN A JAR LIKE THIS                      │
│  ┌───────────────────────────────────────────┐  │
│  │     [3D jar with sample sticker]          │  │
│  │     Customize one yourself →    🔒        │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│       Loving it? Get your own hive →            │
│                                              ✕  │
└─────────────────────────────────────────────────┘
                                                  
                          ╭──────────────────────╮
                          │ ✨ Adopt your own hive│
                          ╰──────────────────────╯
```

## 1.5 Zone Specs

### ① Top chrome
- 52pt tall, blurred material background, sticky to top
- Left: ← back chevron → S-AUTH-02 value carousel
- Center: yellow "DEMO" badge (small pill, always visible)
- Right: "Adopt now ▸" text button — direct path to S-AUTH-04
- Min visual weight; not the primary CTA (FAB is)

### ② Demo video zone
- 240pt, full width, 16:9 video
- Source: pre-recorded loop from a real Bees-partner hive, 24h+ delayed, anonymized (no farmer name, hive name)
- Loop length: 5–10 minutes seamless
- "DEMO" watermark: bottom-left corner of video, always visible (not just overlay — burned into player chrome too)
- Top-left small chip: "This is a sample hive, not live data."
- No audio in demo (avoids audio reuse rights issue and signaling that this is "live audio")
- No play/pause controls — just a continuous loop with light fade between loop points
- Tap on video → S-AUTH-06 soft signup ("Sign in to watch your own live hive")

### ③ Demo hive pill
- Same component as real S-HIVE-01 hive identity pill
- Static text: "Demo Hive · Sample Farm · CA"
- Health pill always shows "THRIVING" (positive demo case)
- Tap → S-AUTH-06 soft signup

### ④ Stat strip
- Same 7 tiles as real screen
- Values: simulated, gently animated
- Each tile has small lock icon overlay
- Tap any tile → S-AUTH-06 soft signup with context "Sign in to see this hive's full stats"
- Hint label below strip: "Tap any tile for details → 🔒"

### ⑤ Activity counter
- Same component as real
- Simulation: procedural counter that ticks 0–3 per second based on a seeded random walk
- Subhead under title: "(simulated)"
- Tap → soft signup

### ⑥ Jar preview teaser
- 180pt card
- Rotating 3D jar with one of the 8 sample stickers
- Sample sticker shows "Buzzy McHive · Spring 2026" (clearly demo)
- Tap card → S-AUTH-06 with context "Sign in to design your own jar"
- Card has slight pulse animation every 5s (gently draws eye)

### ⑦ Floating FAB
- Fixed bottom-right, 16pt margins from screen edge + tab bar (no tab bar in demo)
- Shape: pill, 56pt tall, ~180pt wide
- Label: "✨ Adopt your own hive"
- Color: `bees/honey/500` background, white text
- Mild shadow, slight bounce on appear (200ms)
- Tap → S-AUTH-04 auth picker

### ⑧ Floating banner
- Appears 45s after demo loaded (or 15s for returning viewer)
- Bottom of screen above FAB, 40pt tall, full width minus 32pt
- "Loving it? Get your own hive →"
- Dismissible via ✕ on right
- Once dismissed in session, doesn't reappear
- Tap → S-AUTH-04

## 1.6 Soft Signup Trigger Logic

User can stay in the demo as long as they want, but tapping any of these triggers S-AUTH-06 sheet:

| Tap target | Sheet context copy |
|---|---|
| Stat tile | "Sign in to see live stats from your own hive." |
| Activity counter | "Sign in to watch your own bees in real time." |
| Jar preview | "Sign in to design your own honey jar." |
| Hive identity pill | "Sign in to meet your own hive." |
| Video player | "Sign in to watch your own hive 24/7." |

The sheet is the same component (S-AUTH-06) with dynamic context copy. Sheet has 3 auth methods + dismiss. Dismiss returns to demo.

## 1.7 States

| State | Behavior |
|---|---|
| Loading | Skeleton for stats + a "spinning up the demo" placeholder for video (1–2s budget) |
| Ready (default) | Full experience |
| Video failed to load | Static still image of a hive entrance with bees + "Demo unavailable. Adopt to see your own live!" CTA |
| Returning viewer | Banner appears at 15s instead of 45s |
| Reduce Motion | Counter ticks instant; jar stops rotating; banner appears as fade not slide |
| Reduce Transparency | Material backgrounds become solid |

## 1.8 Edge cases

| Scenario | Behavior |
|---|---|
| User stays in demo > 5 minutes | Pause video and show "Still here? Your real hive is waiting →" overlay (gentle, dismissible) |
| User backgrounds app and returns | Resume from where they were; reset 45s timer for floating banner |
| User taps video player area (not on a stat tile) | Treat as soft signup trigger, video pauses while sheet is up |
| User opens demo, closes immediately | Don't penalize; demo remains accessible from value carousel |
| App offline | "Demo needs internet to show you the bees" with retry |
| User has previously signed in, came back to demo while logged in | Skip demo; route to their actual Hive home |

## 1.9 Accessibility

- Whole screen accessibility label: "Bees app demo. Sample hive, not your own. Adopt your own hive button at bottom."
- Demo video: VoiceOver: "Demo video showing bees at hive entrance. This is a sample, not live."
- Locked stat tiles: VoiceOver announces "{stat name}, sample value {value}. Locked. Sign in to see live data."
- FAB: standard label "Adopt your own hive. Button."
- Reduce Motion: all animation simplified to fades

## 1.10 SwiftUI implementation notes

```swift
struct DemoHiveViewerView: View {
    @StateObject var viewModel: DemoViewerViewModel
    @State private var bannerVisible = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    DemoTopChrome()
                    DemoVideoPlayer(loop: viewModel.demoLoop)
                        .onTapGesture { viewModel.triggerSoftSignup(.video) }
                    DemoHivePill()
                    DemoStatStrip(stats: viewModel.simulatedStats)
                    DemoActivityCounter(simulated: viewModel.activitySim)
                    DemoJarTeaser()
                }
            }
            
            VStack(spacing: 12) {
                if bannerVisible {
                    DemoFloatingBanner(onDismiss: { bannerVisible = false })
                        .transition(.move(edge: .bottom))
                }
                DemoFAB { viewModel.routeToAuth() }
            }
            .padding(16)
        }
        .task {
            try? await Task.sleep(for: .seconds(viewModel.bannerDelay))
            withAnimation { bannerVisible = true }
        }
        .sheet(isPresented: $viewModel.showSoftSignup) {
            SoftSignupSheet(context: viewModel.softSignupContext)
        }
    }
}
```

**Engineering concerns:**
- Demo video should be cached locally on first launch (single 5–10 min loop, ~15–30 MB at 720p) for instant playback on return
- Simulated stats: deterministic seed per session for reproducibility in testing; procedural with bounded random walk for variability
- Track demo session telemetry server-side (without account): use anonymous device ID
- App Store review note: have a clear "DEMO" badge on every screenshot/preview

## 1.11 Telemetry

- `demo_viewer_opened` { source: carousel|deep_link, returning: bool }
- `demo_video_played` { duration_s }
- `demo_locked_feature_tapped` { feature_id }
- `demo_soft_signup_shown` { trigger }
- `demo_soft_signup_dismissed`
- `demo_fab_tapped`
- `demo_floating_banner_shown`
- `demo_floating_banner_tapped`
- `demo_floating_banner_dismissed`
- `demo_session_ended` { duration_s, converted: bool }

**Conversion KPI:** % of demo viewers who reach S-AUTH-04 and complete signup. Target: ≥ 25% in first month.

## 1.12 Acceptance criteria

- [ ] "DEMO" badge always visible (chrome + video watermark)
- [ ] No live data shown; all simulated or 24h-delayed
- [ ] Soft signup triggered by all 5 locked interaction targets
- [ ] FAB always visible without scrolling
- [ ] Floating banner appears at 45s (15s for returning viewers)
- [ ] App Store review acceptance (no paywall workaround flag)
- [ ] Demo video loops seamlessly with no awkward cuts
- [ ] Telemetry conversion funnel populated end-to-end
- [ ] Reduce Motion + VoiceOver tested
- [ ] Returning user logged-in flow correctly bypasses demo

---

# PART 2 — Onboarding Sequence (S-OBD-01 → S-OBD-13)

## 2.1 Purpose

The full critical path from "decided to sign up" to "I have a hive and a trial in flight." This is the highest-stakes funnel in the app — every drop-off here is irrecoverable revenue.

This section spec'd the full sequence end-to-end with focus on: drop-off recovery, transition timing, data persistence between steps, and the holistic experience. Individual screen layouts already detailed in main plan; this batch focuses on *flow integrity* and the previously underspec'd individual screens.

## 2.2 Sequence Map

```
S-AUTH-04 Auth picker (PRECEDES onboarding; Apple/Google/Email)
        │
        ▼
S-OBD-01 Tier comparison ──── back? → S-AUTH-04
        │
        ▼ tap tier
S-OBD-02 Tier confirmation ──── change plan? → S-OBD-01
        │
        ▼ tap "Start free trial"
S-OBD-03 Tutorial card 1 (What is a hive?) ──── skip → S-OBD-07
        │
        ▼ tap Next
S-OBD-04 Tutorial card 2 (How the cameras work) ──── skip → S-OBD-07
        │
        ▼ tap Next
S-OBD-05 Tutorial card 3 (What stats mean) ──── skip → S-OBD-07
        │
        ▼ tap Next
S-OBD-06 Tutorial card 4 (Honey & stickers) ──── skip → S-OBD-07
        │
        ▼ tap "Got it"
S-OBD-07 Hive assignment reveal (already deep-spec'd in batch 2)
        │
        ▼
S-OBD-08 Hive naming ──── skip → uses default "Hive #47"
        │
        ▼
S-OBD-09 Address entry (US states only)
        │
        ▼ if address validation suggests correction
S-OBD-10 Address verification ──── back → S-OBD-09
        │
        ▼
S-OBD-11 First sticker customization (MANDATORY — no skip)
        │
        ▼ tap "Continue"
S-OBD-12 Payment + trial start ──── back → S-OBD-11
        │
        ▼ payment succeeds
S-OBD-13 Welcome confirmation
        │
        ▼ tap "See my hive"
S-HIVE-01 Hive home (entry to main app)
```

## 2.3 Drop-off Recovery Rules

If the user backgrounds the app or force-quits during onboarding, restore at the same step on next launch with all entered data preserved:

| Last step completed | Resume at | Data preserved |
|---|---|---|
| Auth | S-OBD-01 tier comparison | Account exists, no payment yet |
| Tier selected | S-OBD-02 confirmation | Tier choice |
| Tutorial in progress | Tutorial card last viewed | Card index |
| Tutorial complete | S-OBD-07 reveal | (assignment generated) |
| Hive named | S-OBD-09 address | Hive name |
| Address entered | S-OBD-11 sticker | Address (validated) |
| Sticker designed | S-OBD-12 payment | Sticker draft |
| Payment failed | S-OBD-12 with retry sheet | All prior data |

**Implementation:** Server-side `OnboardingState` per user, updated after each step succeeds. Client reads on launch and routes to correct screen. State expires after 30 days of inactivity (account stays, just falls back to S-OBD-01 to refresh).

**Forgive-me banners:** If user resumes onboarding after >24h gap, show a brief banner "Welcome back! Picking up where you left off." Helps continuity without being condescending.

## 2.4 Per-Screen Specs (focus on previously underspec'd)

### S-OBD-01 Tier Comparison (deep)

```
┌─────────────────────────────────────────────────┐
│ ←   Choose your hive plan                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  All plans include:                             │
│  ✓ Live video of your hive                      │
│  ✓ Real-time hive stats                         │
│  ✓ Honey jars shipped to you                    │
│  ✓ 7-day free trial                             │
│  ✓ Cancel anytime                               │
│                                                 │
│ ┌──────────────┐┌──────────────┐┌──────────────┐│
│ │  POLLINATOR  ││•   FORAGER  •││ QUEEN KEEPER ││
│ │              ││MOST POPULAR ││              ││
│ │   $14.99/mo  ││   $24.99/mo  ││   $49.99/mo  ││
│ │   or $149/yr ││   or $249/yr ││   or $499/yr ││
│ │              ││              ││              ││
│ │ 1 jar/3 mo   ││ 1 jar/mo     ││ 2 jars/mo    ││
│ │ Entrance cam ││ All cameras  ││ All + extras ││
│ │ 8 designs    ││ + custom text││ + exclusive  ││
│ │              ││ + clips      ││ + gift subs  ││
│ │              ││ + favorites  ││ + sister hive││
│ │              ││              ││ + bonus jar  ││
│ │              ││              ││              ││
│ │   [ Pick ]   ││ • Selected • ││   [ Pick ]   ││
│ └──────────────┘└──────────────┘└──────────────┘│
│                                                 │
│  Compare all features →                         │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│       [ Start 7-day free trial ]                │
│              of Forager                         │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Top: included-in-all benefits (5 bullets)
- Three side-by-side tier cards, horizontal scroll on small devices, side-by-side on regular
- "Most popular" tag on Forager
- Each card: name → price → 4–6 key feature bullets → Pick / Selected button
- Below: "Compare all features →" link → modal with full comparison table
- Sticky footer: primary CTA dynamically labeled with selected tier

**Behavior:**
- Tap any tier card → selects it, footer updates
- Single-select (radio-like)
- "Compare all features" → presents full comparison modal (same matrix from main plan §0)
- Footer enabled once a tier is picked (defaults to Forager pre-selected for friction reduction; can toggle this in A/B test)

**Pricing presentation:**
- Default shows monthly price prominently, annual as secondary
- Toggle "Save 17% with annual" can be implemented as a segmented control above tier cards (Monthly | Annual)
- Annual selection persists into S-OBD-12

**Accessibility:**
- Each tier card is a single accessible element with full description: "Forager. 24 dollars 99 cents per month. Most popular. Includes 1 jar per month, all cameras, custom text, clips, favorites. Selected. Double-tap to choose."
- "Most popular" announced as part of tier description
- Compare table is fully traversable

### S-OBD-02 Tier confirmation

```
┌─────────────────────────────────────────────────┐
│ ←   You picked Forager                          │
├─────────────────────────────────────────────────┤
│                                                 │
│             [Forager illustration]              │
│                                                 │
│         Forager  ·  $24.99/month                │
│                                                 │
│  WHAT YOU GET                                   │
│  🍯  1 jar of honey every month                 │
│  📹  All 3 camera angles                        │
│  ✏️  Custom sticker text                        │
│  🎬  Save clips and screenshots                 │
│  ⭐  5 saved sticker designs                    │
│  📨  Weekly hive digest email                   │
│                                                 │
│  YOUR FREE TRIAL                                │
│  7 days from today. We'll remind you 3 days     │
│  before your trial ends. Cancel anytime in      │
│  Settings.                                      │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│      [ Start free trial ]                       │
│      [ Change plan ]                            │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Hero illustration + tier name + price
- "What you get" section with iconified bullets
- "Your free trial" disclosure section (clear, not buried)
- Sticky footer: primary "Start free trial" + secondary "Change plan" → S-OBD-01

**Note:** This screen is the legal disclosure for the subscription as required by Apple. Trial length, post-trial price, cancellation method must all be visible without scrolling.

### S-OBD-03 to S-OBD-06 Tutorial cards

Each card: same template, different content.

```
┌─────────────────────────────────────────────────┐
│                                          Skip > │
├─────────────────────────────────────────────────┤
│                                                 │
│             [hero illustration]                 │
│                                                 │
│         What is a hive?                         │
│                                                 │
│  Your hive is a real beehive on a partner       │
│  farm. It has thousands of bees, a queen,       │
│  and produces honey through the year.           │
│                                                 │
│  We assign you a hive based on availability     │
│  in your region. You can rename it, watch it,   │
│  and receive jars from it.                      │
│                                                 │
│                                                 │
│              ● ○ ○ ○                            │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Next ]                           │
└─────────────────────────────────────────────────┘
```

**4 cards content:**

1. **What is a hive?** — Real hive on partner farm, real bees, real honey.
2. **How the cameras work** — Multi-angle live cameras; entrance, internal, top-down. Streaming 24/7. (Multi-angle for Forager+, single for Pollinator.)
3. **What stats mean** — Temperature, humidity, weight = how the hive is doing. Take-offs / landings = how active they are. We compute health from all of these.
4. **Honey & stickers** — Every shipment, you customize a sticker. We print and ship. Up to 5 saved designs (Forager+).

**Layout:**
- Top right: tiny "Skip >" link → S-OBD-07
- Hero illustration (designer to provide; ~200pt tall)
- Title `display/m`
- Body 2 paragraphs
- Page indicator dots ●○○○ updating as user progresses
- Footer button: "Next" on cards 1–3, "Got it" on card 4 → S-OBD-07

**Dev toggle:** Tutorial visibility toggle in dev settings allows hiding entirely (jumps straight to S-OBD-07 after S-OBD-02).

**Accessibility:** Each card fully read by VoiceOver; "Skip" available via VoiceOver action.

### S-OBD-08 Hive Naming

```
┌─────────────────────────────────────────────────┐
│ ←                                       Skip >  │
├─────────────────────────────────────────────────┤
│                                                 │
│       Name your hive                            │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Buzzy McHive                            │    │
│  └─────────────────────────────────────────┘    │
│  Up to 24 characters · 12 / 24                  │
│                                                 │
│  STUCK? TRY ONE OF THESE                        │
│  ┌────────────────┐  ┌────────────────┐         │
│  │ Buzzy McHive   │  │ Honeycomb HQ   │         │
│  └────────────────┘  └────────────────┘         │
│  ┌────────────────┐  ┌────────────────┐         │
│  │ The Hive Mind  │  │ Bee Yoncé      │         │
│  └────────────────┘  └────────────────┘         │
│                                                 │
│  Or use the default: Hive #47                   │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Title at top
- Single line text input, 24 char max
- Char counter below
- 4 suggested name chips, tap to populate input
- Default option clearly noted
- Skip link top-right uses default

**Validation:**
- 1–24 chars
- Same allowed characters as sticker text minus the digit-only restrictions (allow numbers in names like "Hive #47" if user types it)
- No PII pattern blocks (this is private to the user)
- No profanity (it'll be displayed in their app and potentially printed if they upgrade to Queen Keeper)

**Behavior:**
- Continue enabled when valid name entered OR after Skip
- "Continue" → S-OBD-09 address
- Hive name persisted to server immediately; user can change later in Hive settings

### S-OBD-09 Address Entry (deep)

```
┌─────────────────────────────────────────────────┐
│ ←   Where should we ship?                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Full name                               │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Street address                          │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Apartment, suite, etc. (optional)       │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐     │
│  │ City             │  │ State ▾          │     │
│  └──────────────────┘  └──────────────────┘     │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ZIP code                                │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  We ship to: California, Texas (more states     │
│  coming soon)                                   │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Standard address form
- State picker dropdown filtered to ONLY supported states (CA, TX at launch)
- Footer note shows supported states

**Auto-fill:**
- Use iOS contact autofill if user grants permission
- Full name pre-populated from auth account if available

**Validation:**
- All fields required except apt
- Real-time format validation (zip = 5 digits, state = picker)
- On Continue: USPS API validates entire address
  - Match → S-OBD-11
  - Suggested correction → S-OBD-10
  - Unverifiable → friendly error "We can't find this address. Double-check or contact support."

**Out-of-state handling:**
- If user manually types an unsupported state in `City` field bypassing dropdown: API will reject; show waitlist signup
- Waitlist: simple email capture + "We'll let you know when we ship to {state}"

### S-OBD-10 Address verification

```
┌─────────────────────────────────────────────────┐
│ ←   Confirm your address                        │
├─────────────────────────────────────────────────┤
│                                                 │
│  We found a slight difference. Which is right?  │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ○  WHAT YOU ENTERED                     │    │
│  │                                         │    │
│  │   123 Maple Lane                        │    │
│  │   Apt 4                                 │    │
│  │   Sonoma, CA 95476                      │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ●  USPS SUGGESTS                        │    │
│  │                                         │    │
│  │   123 Maple Ln                          │    │
│  │   Apt 4                                 │    │
│  │   Sonoma, CA 95476-1234                 │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│           [ Use selected address ]              │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Two cards: what user entered vs USPS suggestion
- Radio select; default = USPS suggested
- Confirm proceeds with selected
- Back → S-OBD-09 to edit

### S-OBD-11 First sticker customization

Already specced in batch 1. Onboarding variant differences:
- No tab bar
- Title: "Customize your first sticker"
- Subhead: "This goes on your first jar — make it yours"
- No skip option (mandatory)
- Footer: single CTA "Continue" → S-OBD-12
- Lock-in not exposed (lock happens at standard 7-day-before-ship rule later)

**Engineering note:** Persist sticker draft on every change debounced 1s. If user backgrounds app, draft survives.

### S-OBD-12 Payment + Trial Start (deep)

```
┌─────────────────────────────────────────────────┐
│ ←   Confirm and start trial                     │
├─────────────────────────────────────────────────┤
│                                                 │
│  YOUR PLAN                                      │
│  ┌─────────────────────────────────────────┐    │
│  │ Forager                                 │    │
│  │ $24.99/month                            │    │
│  │ 7-day free trial · Cancel anytime       │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  HOW BILLING WORKS                              │
│  • Today (May 5):    Free                       │
│  • May 12:           Trial ends                 │
│  • May 12:           First charge $24.99        │
│  • Then:             $24.99 monthly             │
│                                                 │
│  Cancel anytime in Settings before May 12       │
│  to avoid being charged.                        │
│                                                 │
│  Promo code?                          [Apply]   │
│                                                 │
│  By continuing, you agree to Bees Terms of      │
│  Service and Privacy Policy.                    │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│       [ 🍎 Subscribe with Apple Pay ]           │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Plan card (recap)
- Billing timeline (4 dated bullet points)
- Cancellation reminder
- Promo code expandable
- Legal copy (TOS + Privacy linked)
- Sticky footer: Apple IAP button (StoreKit 2 native)

**Apple compliance:**
- Trial length, post-trial price, billing cadence all clearly visible above the fold (this is the App Store-required disclosure surface)
- "Cancel anytime" clear
- Legal links functional

**Behavior:**
- Tap subscribe → StoreKit purchase flow (system sheet)
- On success → S-OBD-13
- On failure → toast, retry available
- On user cancel of system sheet → stay on this screen, no penalty

**Promo codes:**
- Server-validated; types: percentage off (first month), free additional trial days, free first jar
- Apply button validates and shows discount inline
- Invalid code → friendly error

**StoreKit specifics:**
- Use `Product.purchase()` from StoreKit 2
- Pass `appAccountToken` in purchase options for server-side reconciliation
- Listen `Transaction.updates` after purchase

### S-OBD-13 Welcome confirmation

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [confetti animation]               │
│                                                 │
│         Welcome to Bees, Nick!                  │
│                                                 │
│  Your hive is ready. Buzzy McHive is at         │
│  Sunny Acre Farm in Sonoma County.              │
│                                                 │
│  WHAT'S NEXT                                    │
│  ✓ Watch your hive live                         │
│  ✓ Your first sticker is set for printing       │
│  ✓ Free trial ends May 12 — we'll remind you    │
│  ✓ First jar ships ~6 weeks (we'll track it)    │
│                                                 │
│                                                 │
│         [ See my hive ]                         │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Confetti (~1.5s)
- Personalized headline
- Body confirms hive
- "What's next" 4 bullets set expectations
- Single CTA → S-HIVE-01

**Animation:**
- Confetti rains from top, ~50 particles, ~1.5s
- Reduce Motion: replaced with simple checkmark fade-in

## 2.5 Onboarding-wide concerns

### Step indicator
Dev toggle in settings: "Show onboarding step indicators (X of Y)" — useful during testing, off in production.

### Back navigation
Each step's back button is the iOS standard chevron left in nav bar. Going back preserves entered data forward (so re-entering doesn't wipe later steps). Hard backstops:
- Cannot go back from S-OBD-12 if payment processing
- Cannot go back from S-OBD-13 (irreversible)

### Cancel mid-flow
- "✕" button NOT shown during onboarding (prevents accidental abandon)
- User can force-quit, but we restore state per §2.3
- After 30 days inactive → onboarding state expires; user lands on tier comparison fresh

### Apple Sign In specifics
- Apple Sign In hides email by default; we get a relay address
- No problem; we use account ID from Apple
- For "private email relay": save and treat as primary; subsequent emails route through it

### Family sharing
- Apple's Family Sharing: a Family Organizer can purchase, share with members
- For Bees: not supported in v1 because each hive is 1:1; would need to design hive sharing first
- App Store Connect: disable Family Sharing for our subscription products

## 2.6 SwiftUI implementation sketch

```swift
struct OnboardingFlow: View {
    @StateObject var viewModel: OnboardingViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            // Initial screen depends on resumed state
            initialDestination(for: viewModel.resumeStep)
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .tierComparison: TierComparisonView()
                    case .tierConfirmation(let tier): TierConfirmationView(tier: tier)
                    case .tutorial(let cardIndex): TutorialCardView(index: cardIndex)
                    case .reveal(let assignment): HiveAssignmentRevealView(assignment: assignment)
                    case .hiveNaming(let assignment): HiveNamingView(assignment: assignment)
                    case .addressEntry: AddressEntryView()
                    case .addressVerify(let suggestion): AddressVerifyView(suggestion: suggestion)
                    case .firstSticker: StickerCustomizerView(mode: .onboarding)
                    case .payment: PaymentView()
                    case .welcome: WelcomeView()
                    }
                }
        }
        .interactiveDismissDisabled() // can't swipe-dismiss mid-onboarding
        .onChange(of: viewModel.path) { _, newPath in
            viewModel.persistResumeState(newPath)
        }
    }
}
```

## 2.7 Telemetry

Per-step funnel events (every entry + exit + drop-off):
- `onboarding_started`
- `tier_comparison_viewed`
- `tier_selected` { tier }
- `tier_confirmation_viewed`
- `trial_started_tapped`
- `tutorial_started`
- `tutorial_skipped` { from_card }
- `tutorial_completed`
- `hive_revealed`
- `hive_named` { used_default: bool, used_suggestion: bool }
- `address_entered` { state }
- `address_validation_failed` { reason }
- `address_corrected_used`
- `first_sticker_designed` { has_text: bool }
- `payment_screen_viewed`
- `payment_started` { method }
- `payment_succeeded`
- `payment_failed` { reason }
- `payment_retried`
- `onboarding_completed` { duration_minutes, steps_visited }
- `onboarding_resumed_after_drop` { last_step, hours_since_drop }
- `onboarding_abandoned` { last_step } // computed server-side at 30d expiry

**Funnel KPI:** Onboarding completion rate (S-AUTH-04 → S-OBD-13). Target: ≥ 75%.

## 2.8 Acceptance criteria

- [ ] All 13 onboarding steps implemented and connected
- [ ] Drop-off recovery tested at every step
- [ ] State persists for 30 days; auto-resets after
- [ ] Tutorial dev toggle works
- [ ] Address validation against USPS API
- [ ] Out-of-state addresses route to waitlist
- [ ] First sticker mandatory (no skip)
- [ ] StoreKit 2 trial purchase tested with sandbox account (all 3 tiers)
- [ ] Trial → paid conversion tested via TestFlight + sandbox time-acceleration
- [ ] Promo code application tested
- [ ] Apple Sign In, Google, email auth all tested
- [ ] Apple's privacy email relay handled
- [ ] All accessibility labels in place
- [ ] Reduce Motion tested at every animated step
- [ ] Funnel telemetry fires correctly
- [ ] Onboarding completion rate measured in TestFlight

---

# PART 3 — S-HONEY-01 Honey Home

## 3.1 Purpose

Second-most-visited tab. Hub for shipment lifecycle, sticker customization, gift sending, and history. Must orient the user instantly to "what's happening with my honey right now" while making customization + history accessible.

## 3.2 Variants Matrix

### Shipment lifecycle states (most important)

| State | Trigger | Time period |
|---|---|---|
| **No active shipment** | Brand new account, between cycles for Pollinator | First 7d after signup; gap weeks for Pollinator |
| **Customizing** | A draft shipment exists, lock-in not yet | 14+ days before ship date |
| **Approaching lock** | < 7d to lock-in | 7d → lock-in |
| **Locked** | Sticker locked, not yet preparing | Until preparing kickoff |
| **Preparing** | Backend has started fulfillment | 0–3 days before ship |
| **Shipped** | Carrier has package | 0–7 days |
| **Out for delivery** | Carrier shows OFD | Day of delivery |
| **Delivered** | Carrier confirmed delivery | Persists ~14d |
| **Delayed** | Carrier reported delay | Until resolved |
| **Lost** | Carrier reports lost or 14+ days late | Until claim resolved |
| **Claim filed** | User filed damage/lost claim | Until resolved |
| **Paused** | User paused subscription | Through pause window |
| **Skipped** | User skipped one shipment | Until next cycle |

### Tier variants
- **Pollinator:** quarterly cadence (3 month gaps); jar count 1 per shipment; gift sending hidden
- **Forager:** monthly cadence; jar count 1 per shipment; gift jar enabled
- **Queen Keeper:** monthly cadence; jar count 2 per shipment; gift sub + gift jar enabled

## 3.3 Anatomy

```
┌─────────────────────────────────────────────────┐
│ ① TOP NAV — title + share button                │
├─────────────────────────────────────────────────┤
│ ② HERO SHIPMENT CARD (variable, ~240–320pt)     │
│   - 3D jar render                               │
│   - Status badge + countdown                    │
│   - Primary CTA based on state                  │
├─────────────────────────────────────────────────┤
│ ③ SHIPMENT TIMELINE (88pt)                      │
│   - Mini visual: Customize → Lock → Ship → Land │
├─────────────────────────────────────────────────┤
│ ④ SAVED STICKERS SHORTCUT (88pt) — Forager+     │
├─────────────────────────────────────────────────┤
│ ⑤ BUY EXTRA JARS CARD (88pt)                    │
├─────────────────────────────────────────────────┤
│ ⑥ SEND A GIFT CARD (88pt) — Forager+            │
├─────────────────────────────────────────────────┤
│ ⑦ HISTORY ROW (variable)                        │
│   - Last 3 shipments thumbnails + "View all"    │
├─────────────────────────────────────────────────┤
│ ⑧ MANAGE SHIPMENTS LINK (44pt)                  │
│   - Skip/pause access                           │
└─────────────────────────────────────────────────┘
[ 🐝 ]  [•🍯•]  [ 🌻 ]  [ 👤 ]
```

## 3.4 ASCII wireframe — "Customizing" state, Forager tier

```
┌─────────────────────────────────────────────────┐
│   Honey                                  📤    │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  ┌──────────────────┐                     │  │
│  │  │ [3D jar          │  CUSTOMIZING        │  │
│  │  │   rotating]      │  Locks May 11       │  │
│  │  │                  │  Ships May 18       │  │
│  │  │   Buzzy Bee      │                     │  │
│  │  │   Spring 2026    │  ┌─────────────┐    │  │
│  │  │                  │  │ Customize   │    │  │
│  │  └──────────────────┘  └─────────────┘    │  │
│  │                                           │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  Customize ●─────○────○────○ Land               │
│            Lock  Pack Ship                      │
├─────────────────────────────────────────────────┤
│  ❤️  SAVED STICKERS                  3 of 5  →  │
│  ┌────┐ ┌────┐ ┌────┐                            │
│  │ 1  │ │ 2  │ │ 3  │                            │
│  └────┘ └────┘ └────┘                            │
├─────────────────────────────────────────────────┤
│  ➕  BUY EXTRA JARS                          →  │
│  Add a jar to this shipment or send anytime     │
├─────────────────────────────────────────────────┤
│  🎁  SEND A GIFT                             →  │
│  Send honey to someone you love                 │
├─────────────────────────────────────────────────┤
│  RECENT SHIPMENTS                  View all  →  │
│  ┌────┐ ┌────┐ ┌────┐                            │
│  │Apr │ │Mar │ │Feb │                            │
│  │ 18 │ │ 18 │ │ 18 │                            │
│  └────┘ └────┘ └────┘                            │
├─────────────────────────────────────────────────┤
│  ⚙ Manage shipments (skip / pause)        →    │
└─────────────────────────────────────────────────┘
```

## 3.5 Zone Specs

### ① Top nav
- Standard NavBarLarge with title "Honey"
- Right action: Share icon → opens share sheet with shareable card "I'm raising bees with Bees! 🐝" + referral link
- Tap title (large variant) → scroll to top

### ② Hero shipment card

State-driven. The card adapts to the lifecycle state.

#### State: No active shipment (first-time / Pollinator gap)

```
┌───────────────────────────────────────────┐
│         [bee + empty jar art]             │
│                                           │
│      Your first jar is on the way!        │
│      We'll start preparing in 2 weeks.    │
│                                           │
│      You can customize the sticker        │
│      starting May 11.                     │
│                                           │
│  ┌─────────────────────────────────────┐  │
│  │  Set up sticker reminder            │  │
│  └─────────────────────────────────────┘  │
└───────────────────────────────────────────┘
```

Pollinator gap state copy: "Your next jar is in {N} weeks. We'll let you know when it's time to customize."

#### State: Customizing
- 3D jar render with current draft sticker
- Status: "CUSTOMIZING" badge
- Countdown: "Locks {date} · Ships {date}"
- Primary CTA: "Customize sticker" → S-HONEY-02

#### State: Approaching lock (< 7 days)
- Same as Customizing but badge color = amber
- Subtle pulse on Customize button
- Microcopy: "Don't forget — locks in 4 days"

#### State: Locked
- 3D jar with locked sticker
- Status: "✓ LOCKED" badge
- Countdown: "Ships {date}"
- Primary CTA: "View design" → S-HONEY-04 read-only

#### State: Preparing
- Same as Locked but status: "PREPARING"
- Countdown: "Ships {date}"

#### State: Shipped / In transit
- Status: "SHIPPED" badge
- Countdown: "Arrives {est date}"
- Primary CTA: "Track package" → S-HONEY-09 detail
- Tracking number visible inline

#### State: Out for delivery
- Status: "OUT FOR DELIVERY" badge (excited tone)
- "Arriving today" headline

#### State: Delivered
- Confetti animation (subtle, one-shot on first view)
- Status: "DELIVERED" badge
- "How is it?" CTA → S-HONEY-17 satisfaction prompt (rate experience, optional review)
- After 3 days → card collapses to next-shipment preview

#### State: Delayed / Lost
- Status: red badge
- Apology copy: "We're sorry — your jar is delayed."
- Primary CTA: "What's happening" → claim flow start
- Updated estimate visible

#### State: Paused / Skipped
- Status: gray "PAUSED" or "SKIPPED" badge
- Resume CTA available

### ③ Shipment timeline

```
Customize ●─────○────○────○ Land
          Lock  Pack Ship
```

- Mini visual progress, 4 dots representing key milestones
- Active step has filled dot; future steps hollow
- Connecting line fills as time progresses
- Tap → S-HONEY-09 full detail

### ④ Saved Stickers shortcut

- Forager+ only
- Horizontal row of saved sticker thumbnails (up to 3 visible, more accessible via "View all")
- "❤️ SAVED STICKERS · {count} of {limit}" header
- Empty state: "Saved designs show up here. Customize a sticker and tap ❤️ to save."

### ⑤ Buy extra jars card

- All tiers (always available)
- Single card row with arrow CTA → S-HONEY-12
- Subtitle: "Add a jar to this shipment or send anytime"

### ⑥ Send a gift card

- Forager+ only
- Single card row → S-GIFT-01
- Subtitle: "Send honey to someone you love"
- Pollinator users see paywall teaser instead: "Gifting comes with Forager →"

### ⑦ Recent shipments

- Horizontal scroll of last 3 shipment thumbnails
- Each: small jar render + ship date + status icon
- Tap thumbnail → S-HONEY-11 past shipment detail
- "View all →" → S-HONEY-10 full history

### ⑧ Manage shipments link

- Single row at bottom: "⚙ Manage shipments (skip / pause)" → S-HONEY-15
- Subtle visual weight (this is an exit, not a primary action)

## 3.6 Edge cases

| Scenario | Behavior |
|---|---|
| User on free trial, no first sticker designed yet | Hero card shows: "Customize your first sticker before {trial end date}." Primary CTA → S-HONEY-02 (NOT onboarding flow — they're past that). |
| User in trial but trial about to expire | Top banner: "Trial ends in 3 days. Manage plan →" |
| Subscription past-due | All cards greyed except "Update payment" CTA in hero card |
| Subscription canceled | All cards visible (can browse history) but customize / gift CTAs disabled with paywall messaging |
| Shipment locked but address invalid | Banner: "We can't ship to {address}. Update before {date}." |
| Multiple shipments in flight (Queen Keeper buying extras) | Hero card shows the next-to-ship; "+1 more shipment" chip indicates additional |
| Open damage claim active | Claim status banner replaces the bottom row briefly |

## 3.7 Animations

- Hero card 3D jar: rotates 4 RPM
- State transitions: cross-fade 300ms when status changes (e.g., Locked → Preparing)
- Confetti on Delivered state: 1.5s, one-time per delivery
- Pull-to-refresh: standard

## 3.8 Accessibility

- Hero card: full description with state, dates, and CTA. Single accessible element per card.
- Shipment timeline: dots labeled with stage names; current stage announced
- Empty states: friendly verbose labels ("No saved stickers yet. Customize a sticker to save it here.")
- Reduce Motion: jar stops rotating; confetti becomes simple fade

## 3.9 SwiftUI implementation notes

```swift
struct HoneyHomeView: View {
    @StateObject var viewModel: HoneyHomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HeroShipmentCard(state: viewModel.activeShipmentState)
                if let timeline = viewModel.timeline {
                    ShipmentTimelineRow(timeline: timeline)
                }
                if viewModel.tier.canSaveFavorites {
                    SavedStickersShortcut(stickers: viewModel.savedStickers)
                }
                BuyExtraJarsCard()
                if viewModel.tier.canSendGifts {
                    SendGiftCard()
                } else {
                    GiftPaywallTeaser()
                }
                RecentShipmentsRow(shipments: viewModel.recentShipments)
                ManageShipmentsLink()
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Honey")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareButton()
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}
```

**Engineering concerns:**
- Hero card state machine drives most of the UI; centralize state derivation in view model
- 3D jar render is expensive; only render the active shipment's jar. Use cached image previews for past shipments.
- Cache shipment data locally; refresh on app foreground + pull-to-refresh
- Listen to push notification updates for state changes (e.g., shipped → in transit)

## 3.10 Telemetry

- `honey_home_viewed` { shipment_state, tier }
- `hero_card_cta_tapped` { state, action }
- `timeline_tapped`
- `saved_stickers_viewed`
- `buy_extras_tapped`
- `send_gift_tapped`
- `recent_shipment_tapped` { shipment_id }
- `manage_shipments_tapped`
- `delivered_confetti_shown`
- `satisfaction_prompt_shown` / `_responded`

## 3.11 Acceptance criteria

- [ ] All 13 shipment lifecycle states render correctly
- [ ] Tier variants gate appropriate features
- [ ] Pollinator gap state messages clearly
- [ ] Hero card transitions between states smoothly
- [ ] Tracking link opens carrier in external browser
- [ ] Past-due banner appears and blocks customize CTA
- [ ] Cancelled state allows history browsing but blocks new customize
- [ ] Pull-to-refresh fetches latest shipment state
- [ ] Push notifications triggered state changes update UI on app open
- [ ] All accessibility labels in place
- [ ] Reduce Motion tested
- [ ] Telemetry funnels populated

---

# PART 4 — S-HIVE-04 Stat Detail (Chart Variants)

## 4.1 Purpose

Deep-dive into one sensor metric with historical chart, comparison, and educational context. There are 7 stat variants sharing a template plus a special qualitative health variant.

## 4.2 Variants Matrix

### 7 chart-based variants
1. Temperature
2. Humidity
3. Weight
4. Population (estimated)
5. Take-offs (rolling 24h)
6. Landings (rolling 24h)
7. Sound activity (qualitative continuous)

### 1 special variant
- Health (qualitative — not a chart, but a state timeline)

### Modifiers
- **Comparison toggle:** if hive comparison setting is on, charts include peer overlay
- **Sensor offline:** chart greyed out, "Last reading {time}"
- **No data yet:** explainer state for new users
- **Reduced refresh:** during winter dormancy, charts update less frequently

## 4.3 Anatomy

```
┌─────────────────────────────────────────────────┐
│ ← Temperature                            ⋯       │
├─────────────────────────────────────────────────┤
│ ① HERO VALUE BLOCK (124pt)                      │
│   - Current value (large)                       │
│   - Trend label                                 │
│   - Last updated timestamp                      │
├─────────────────────────────────────────────────┤
│ ② TIME RANGE SELECTOR (44pt)                    │
│   - 1h | 24h | 7d | 30d | Season | Lifetime    │
├─────────────────────────────────────────────────┤
│ ③ CHART (240pt)                                 │
│   - Line chart with annotation pins             │
│   - Comparison overlay (toggle on)              │
│   - Tap pin → annotation detail                 │
│   - Long-press → scrubber with values           │
├─────────────────────────────────────────────────┤
│ ④ CHART LEGEND (40pt)                           │
│   - Your hive · Farm avg · All hives            │
├─────────────────────────────────────────────────┤
│ ⑤ KEY EVENTS LIST (variable)                    │
│   - Annotations as a chronological list          │
├─────────────────────────────────────────────────┤
│ ⑥ EDUCATIONAL SECTION (expandable)              │
│   - "What is {stat}? Why does it matter?"        │
├─────────────────────────────────────────────────┤
│ ⑦ COMPARISON CALLOUT (if enabled)               │
│   - "Where you rank: {percentile}"              │
└─────────────────────────────────────────────────┘
```

## 4.4 ASCII wireframe — Temperature, 7d range, comparison on

```
┌─────────────────────────────────────────────────┐
│ ←   Temperature                           ⋯     │
├─────────────────────────────────────────────────┤
│                                                 │
│      92°F                                       │
│      ↗ Up 2° vs last hour                       │
│      Last reading: 12 seconds ago               │
│                                                 │
├─────────────────────────────────────────────────┤
│  1h  |  24h  | • 7d • |  30d  | Season| Life   │
├─────────────────────────────────────────────────┤
│                                                 │
│  100°┤        🐝                                │
│      │       ╱  ╲       ╱╲                     │
│   90°┤     ╱     ╲    ╱   ╲       ╱╲           │
│      │   ╱        ╲╱       ╲    ╱   ╲          │
│   80°┤ ╱  ……………………………………………………………………… farm avg│
│      │                                          │
│   70°┤                                          │
│      └─────────────────────────────────────     │
│       Mon Tue Wed Thu Fri Sat Sun               │
├─────────────────────────────────────────────────┤
│  ● Buzzy McHive   ┄ Sample Farm avg             │
├─────────────────────────────────────────────────┤
│  KEY EVENTS                                     │
│  🐝 Tue 9:15 AM — Heat spike (96°F)             │
│  ☔ Wed all day — Rain (cooler)                 │
│  🍯 Fri 3:00 PM — Farmer harvest                │
├─────────────────────────────────────────────────┤
│  ▾ What is hive temperature?                    │
├─────────────────────────────────────────────────┤
│  YOUR RANK                                      │
│  Top 22% in temperature stability this month    │
└─────────────────────────────────────────────────┘
```

## 4.5 Zone Specs

### ① Hero value block
- Current value in `display/xl` (40pt SF Mono Semibold)
- Unit suffix (°F, %, lb, etc.) `display/m`
- Trend label below: `body/m` with arrow + delta + comparison phrase ("Up 2° vs last hour" / "Heaviest week so far" / "Steady today")
- Bottom: timestamp "Last reading: {relative time}" — updates live
- Tap timestamp → "About this metric" sheet (alternative path to ⑥)

### ② Time range selector
- `SegmentedControl`: 1h | 24h | 7d | 30d | Season | Lifetime
- Default: 24h
- Selection persists per stat per user (e.g., user prefers 7d on temperature, 30d on weight)
- Lifetime cap: 5 years for performance

### ③ Chart

**Component:** `StatChart` using Swift Charts.

**Layout:**
- 240pt tall, full width minus 16pt margins
- Y-axis: dynamic range based on data + small headroom
- X-axis: time labels at appropriate density per range
- Line: `bees/honey/500`, 2pt thick, smooth curve interpolation
- Comparison overlay (if enabled): dashed line `bees/charcoal/300`, "farm avg" or "all hives median"
- Annotation pins: 24pt circle with emoji, positioned at relevant X timestamps
- Touch handling:
  - Tap pin → annotation detail sheet
  - Long press → scrubber with values
  - Pinch → zoom horizontally (within range bounds)

**Annotation pins:**
- Auto-generated from server-side event detection
- Examples: heat spike, rain event, harvest, inspection, swarm detected, queen lost
- Each annotation has: emoji, title, body, exact timestamp, optional photo (e.g., farmer's harvest photo)

### ④ Chart legend
- Small text key showing line styles
- "Your hive" with solid honey color swatch
- "Farm avg" with dashed gray (if comparison on)

### ⑤ Key events list
- Vertical list of annotation pins as chronological items
- Each row: emoji + title + relative time + chevron (tap → detail sheet)
- Limit: 10 most recent in current time range
- Empty state: "No key events in this range"

### ⑥ Educational section
- Expandable card: "▾ What is hive temperature?"
- Tap → expands with:
  - Plain language explanation (~150 words)
  - "How we measure" (sensor type, frequency, units)
  - "What's normal" (range expectations)
  - "What changes mean" (interpretation guide)
- Tip cards from beekeeping experts
- Tap "Learn more" → external article link (optional, post-v1)

### ⑦ Comparison callout
- Only shown if comparison setting is on
- Single sentence: "Top 22% in temperature stability this month"
- Or: "Below average — bees are working hard to regulate"
- Methodology link → small modal explaining how percentile is computed (anonymized peer set)

## 4.6 Variant-specific differences

### Temperature
- Y-axis: 60–110°F default
- Healthy range overlay: 90–95°F shaded `bees/leaf/500` 10% opacity
- Trend phrasing: "Steady" / "Warming" / "Cooling"
- Educational: "Bees regulate hive temperature precisely. Consistent 90–95°F means a healthy colony."

### Humidity
- Y-axis: 30–90%
- Healthy range: 50–70%
- Trend: "Steady" / "Drying" / "Humid"

### Weight
- Y-axis: dynamic, focused on weight gain
- Special annotations: harvest events (negative spikes)
- Trend: "Gaining" / "Stable" / "Losing"
- Footnote: "Big drops are usually harvests. We label these."

### Population (estimated)
- Y-axis: scaled by season expectations
- Trend: "Growing" / "Stable" / "Shrinking"
- Educational: "We estimate population from sensor readings — actual count varies."

### Take-offs (rolling 24h)
- Y-axis: 0–{max activity}
- Heatmap variant available toggle: shows time-of-day patterns
- Trend: "Active week" / "Quiet" / "Typical"

### Landings
- Same as take-offs, separate metric
- Often paired with take-offs in user mental model; a "compare" toggle within this screen overlays the two

### Sound
- Special: shows qualitative band rather than precise numbers
- Bands: Quiet / Calm / Active / Loud / Alarmed
- Y-axis: discrete bands
- Educational: "Sound tells us a lot about hive mood. Loud doesn't mean angry — could be excited foraging."

### Health (qualitative — special variant, no chart)

```
┌─────────────────────────────────────────────────┐
│ ←   Hive health                           ⋯     │
├─────────────────────────────────────────────────┤
│                                                 │
│      THRIVING                                   │
│      Last assessed: 5 minutes ago               │
│                                                 │
├─────────────────────────────────────────────────┤
│  HEALTH OVER TIME                               │
│                                                 │
│  May  ████████████████ Thriving                 │
│  Apr  ████████████████ Thriving                 │
│  Mar  ████░░░░░░░░░░░░ Watch (1 wk)             │
│       ████████████░░░░ Steady (3 wk)            │
│  Feb  ████████████████ Steady                   │
│  Jan  ████████████████ Steady                   │
│                                                 │
├─────────────────────────────────────────────────┤
│  WHAT WE LOOK AT                                │
│  Health combines: temperature stability,        │
│  humidity, weight gain, activity patterns,      │
│  and sound profile.                             │
└─────────────────────────────────────────────────┘
```

- Hero: current state HealthPill (large)
- Timeline: last 6 months as horizontal bars colored by state
- Each segment tappable → "Why?" detail
- Educational section explains qualitative methodology

## 4.7 States

| State | Behavior |
|---|---|
| Loading | Chart skeleton + values shimmer |
| Success | Full render |
| Sensor offline | Chart greyed; "Sensor offline since {time}. We're on it." banner |
| No data yet | "Stats will appear after your first 24 hours." friendly empty state |
| Out of range | Chart auto-zooms, shows badge "Reading outside normal range" |
| Comparison on but no peer data | "Comparison data is collecting — check back soon" (rare; only when very few users) |

## 4.8 Edge cases

| Scenario | Behavior |
|---|---|
| User taps stat detail while sensor reporting briefly stale | Shows latest cached value with "Updating..." subtle spinner |
| Range selected has no data (e.g., 30d view but only 5 days history) | Shows partial data + "More data soon" footer |
| Pinch zoom past data range | Bounces back to bounds with haptic |
| Annotation pin density > 10 in view | Cluster pins (2+ → numbered pin, tap → list) |
| User deep-links from anomaly push | Auto-scrolls chart to anomaly timestamp + opens annotation detail |
| Lifetime range with 5+ years | Shows max 5 years; "Older data archived" |

## 4.9 Accessibility

- Chart: VoiceOver describes summary ("Temperature over last 7 days. Range 78 to 96 degrees. Average 89. Trending stable. Three key events.")
- Annotation pins: each individually focusable with full description
- Long-press scrubber: VoiceOver alternative is gesture to step through data points
- Time range selector: standard segmented control accessibility
- Educational expandable: standard disclosure accessibility
- Reduce Motion: chart line draws instantly instead of animating; transitions become fades

## 4.10 SwiftUI implementation notes

```swift
struct StatDetailView: View {
    let stat: StatType
    @StateObject var viewModel: StatDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeroValueBlock(stat: stat, current: viewModel.current, trend: viewModel.trend)
                TimeRangeSelector(selected: $viewModel.range)
                
                if stat == .health {
                    HealthTimelineView(history: viewModel.healthHistory)
                } else {
                    StatChartView(
                        data: viewModel.chartData,
                        annotations: viewModel.annotations,
                        comparison: viewModel.comparisonData,
                        statConfig: stat.config
                    )
                    ChartLegend(comparisonEnabled: viewModel.comparisonEnabled)
                }
                
                KeyEventsList(annotations: viewModel.annotations)
                EducationalSection(stat: stat)
                
                if viewModel.comparisonEnabled, let rank = viewModel.rankCallout {
                    ComparisonCallout(rank: rank)
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(stat.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Compare with takeoffs/landings") { ... }
                    Button("Share this chart") { ... }
                    Button("Why this matters") { ... }
                } label: { Image(systemName: "ellipsis") }
            }
        }
    }
}
```

**Chart implementation:**
- Use Swift Charts (iOS 16+)
- Custom `ChartAnnotation` for pins with emoji + tap target
- `chartXScale(domain:)` for range selection
- `chartGesture(\.long)` for scrubber

**Performance:**
- Lifetime range with 5 years × hourly data = ~44k points; downsample to ~500 points for rendering, full data for export
- Annotations: separate query, cached per stat per range
- Comparison data: server-aggregated peer values, refreshed daily (no live)

## 4.11 Telemetry

- `stat_detail_viewed` { stat, range, comparison_on }
- `time_range_changed` { stat, from, to }
- `annotation_tapped` { stat, annotation_type }
- `educational_expanded` { stat }
- `comparison_callout_viewed` { stat, percentile }
- `chart_pinched` { stat }
- `chart_long_pressed` { stat }

## 4.12 Acceptance criteria

- [ ] All 7 chart variants render correctly with stat-specific configs
- [ ] Health timeline variant works with state segments
- [ ] Time range selector functional across all 6 ranges
- [ ] Annotation pins clickable and load detail
- [ ] Comparison overlay correctly styled and toggle-respected
- [ ] Educational section expandable with appropriate content per stat
- [ ] Sensor offline state handled gracefully
- [ ] Deep link from anomaly push scrolls to correct annotation
- [ ] Long-press scrubber works on all charts
- [ ] Pinch zoom respects data bounds
- [ ] All accessibility labels in place; chart summary spoken
- [ ] Reduce Motion tested
- [ ] Performance: 60fps on 30-day range; <500ms render on Lifetime range

---

# Cross-batch summary

| Spec'd in this batch | File location |
|---|---|
| Demo Hive Viewer (S-AUTH-03) | This file, Part 1 |
| Onboarding Sequence (S-OBD-01 → S-OBD-13) | This file, Part 2 |
| Honey Home (S-HONEY-01) | This file, Part 3 |
| Stat Detail charts (S-HIVE-04) | This file, Part 4 |

**Total deeply-spec'd screens to date:**
- S-HIVE-01 Hive Home
- S-HONEY-02 Sticker Customizer
- S-OBD-07 Hive Reveal
- S-YOU-13 Cancel Subscription
- S-GIFT-02 → S-GIFT-07 Gift Flow
- S-AUTH-03 Demo Hive Viewer
- Full S-OBD onboarding sequence (S-OBD-01 → S-OBD-13)
- S-HONEY-01 Honey Home
- S-HIVE-04 Stat Detail (all 8 variants)

**Open decisions resolved with recommendations:**
1. Cancel access-loss timing → server-flag, default period-end
2. Sub gift pricing → tiered duration discount
3. Premium packaging → three tiers ($0, $6, $18)
4. Gift card visual styles → Classic Hexagon, Watercolor Garden, Modern Minimal
5. Gift message moderation → lenient (block harm, allow PII)
6. Recipient collision → always offer Extend + Save for later

## Remaining underspec'd screens at risk

These are next-priority candidates if you want another batch:

1. **S-FARM-01 Farm Profile** — partner brand experience; needs care to feel real not generic
2. **S-YOU-04 Achievements + S-YOU-06 Achievement earned** — gamification UX, sharing card generation
3. **S-HONEY-09 Shipment status detail** — cross-state tracking with carrier integration
4. **S-HIVE-08 Time-lapse highlights player** — Forager+ daily reel; auto-generation logic + player UX
5. **S-HIVE-15/16/17 Hive emergency states** — three full-takeover layouts (already lightly spec'd; full design pass would harden them)

## What's NOT yet spec'd at all (skim of main plan)

- All Settings sub-screens (most are simple list rows, low risk)
- Help / FAQ rendering
- Legal / TOS viewers
- Most billing screens (similar Apple-managed flows)
- Most gift sender / recipient tracking screens (post-purchase tracking)
- Account deletion grace flow (briefly noted, low complexity)
- Widgets (small, medium, large, lock screen)
- Apple Watch (deferred to phase 4 per plan)

These are mostly low-risk, low-complexity. The main plan covers them at the level needed for engineering kickoff.

---

**End of batch 3.**
