# Bees iOS — Deep Wireframes (Batch 2)
## S-OBD-07 Hive Assignment Reveal · S-YOU-13 Cancel Subscription · S-GIFT-02→07 Gift Flow

**Version:** 1.0
**Date:** 2026-05-05
**Companion to:** `BEES_APP_PLAN.md` and `BEES_WIREFRAMES_HIVE_AND_STICKER.md`
**Audience:** iOS engineering + design QA + legal review (cancel flow)

---

# PART 1 — S-OBD-07 Hive Assignment Reveal

## 1.1 Purpose

The single emotional pivot of onboarding. The user has paid (or started trial), and now they meet their hive. This is the moment that converts "I'm trying an app" into "I have a hive." Must:
- Feel intentional and warm, not gimmicky
- Be fast enough not to annoy (≤ 6 seconds total)
- Handle backend latency gracefully (hive assignment may take 1–3s server-side)
- Respect Reduce Motion and Reduce Transparency
- Survive being shown only ONCE in this exact context (re-runs only via dev replay tutorial)

## 1.2 Variants Matrix

### Trigger contexts
1. **First-time onboarding** — full sequence, mandatory
2. **Re-subscribe after long lapse** — abbreviated sequence (skips intro line)
3. **Hive collapse → new hive** — different copy ("Meet your new hive"), shows after compensation choice
4. **Sister hive activation** — alternate path; sister hive feels different, smaller reveal
5. **Tutorial replay** — sample/demo data, watermarked "Tutorial replay"

### State variants
- **Loading** — server hasn't returned assignment yet; show preloader + delay sequence start
- **Assigned** — full reveal animation
- **No hive available** — rare; fallback to waitlist screen with email confirmation
- **Network error** — retry sheet

## 1.3 Anatomy & Timing

The reveal is a single full-screen animated sequence. Total duration target: **5.5 seconds**, broken into 6 phases.

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                                                 │
│                                                 │
│        (warm cream gradient backdrop)           │
│                                                 │
│              [animated bees]                    │
│                                                 │
│                                                 │
│                                                 │
│              (text reveals here)                │
│                                                 │
│                                                 │
│                                                 │
│                  [skip]                         │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Phase timing

| Phase | Duration | Visual | Audio | Haptic |
|---|---|---|---|---|
| 1. Hush | 0.4s | Black fade-in to cream gradient. Silence. | Soft ambient hum fades in (–24dB) | – |
| 2. Bees enter | 1.2s | 8–12 small bee glyphs fly in from screen edges, scattered paths, converging toward center | Wings flutter (subtle, layered) | – |
| 3. Swarm coalesce | 1.0s | Bees swirl together, forming a tight cluster | Hum builds | – |
| 4. Hive crystallize | 0.8s | Cluster transforms into hexagonal hive silhouette, soft glow expands | Single soft "click" / chord | Light tap |
| 5. Name reveal | 1.5s | Hive image settles. Text fades in line by line: "Meet your hive." → "Hive #47 at Sunny Acre Farm" → "Sonoma County, California" | Hum settles | Medium tap on first line |
| 6. CTA appear | 0.6s | "Continue" button fades in at bottom; tap target | Hum fades to silence | – |

**Total: ~5.5s before user can tap Continue.**

### Skip behavior
- Tiny "Skip" link top-right, fades in at phase 2
- Tap → jump straight to phase 6 (text + CTA snap into place)
- After first tap of skip, all subsequent OBD reveals (re-subscribe, new hive) skip-default

### Tap-to-advance
- After phase 4, any tap advances directly to phase 6
- Allows users who want it fast to skip ahead without missing the hive image

---

## 1.4 ASCII wireframe — Phase 5 (text revealed)

```
┌─────────────────────────────────────────────────┐
│                                          Skip > │
│                                                 │
│                                                 │
│                                                 │
│                                                 │
│                  ╭─────╮                        │
│                  │ ⬡⬡⬡ │                        │
│                  │⬡⬡⬡⬡⬡│   ← hexagonal hive    │
│                  │⬡⬡⬡⬡⬡│      with soft glow   │
│                  │ ⬡⬡⬡ │                        │
│                  ╰─────╯                        │
│                                                 │
│                                                 │
│              Meet your hive.                    │
│                                                 │
│         Hive #47 at Sunny Acre Farm             │
│         Sonoma County, California               │
│                                                 │
│                                                 │
│                                                 │
│                                                 │
│            ┌──────────────────┐                 │
│            │     Continue     │                 │
│            └──────────────────┘                 │
└─────────────────────────────────────────────────┘
```

---

## 1.5 Component specs

### `BeeSwarmAnimation`
- **Implementation:** SpriteKit overlay or SwiftUI `Canvas` with TimelineView
- **Bee glyph:** small (16×16pt) custom illustration, semi-transparent at edges, 4-frame wing flutter loop
- **Path:** each bee follows a Bezier path with slight randomness (jitter ±15%)
- **Convergence point:** screen center, y = 35% from top
- **Cluster behavior:** in phase 3, bees decelerate as they near cluster center, then orbit briefly

### `HiveCrystallize`
- **Implementation:** Lottie animation OR custom SwiftUI shape morph
- **Frames:** swarm cluster → hexagon outline → filled hexagon with depth
- **Glow:** radial gradient `bees/honey/300` → transparent, scale 1.0 → 1.4 → 1.0 over 800ms
- **Final state:** hive image, slight breathing scale (±2%) infinite loop

### `RevealText`
- Three-line stack, vertical
- Line 1 ("Meet your hive."): `display/xl` (40pt SF Serif Bold), `bees/charcoal/900`
- Line 2 (hive identifier): `heading/m` (20pt), `bees/charcoal/900`
- Line 3 (location): `body/m` (15pt), `bees/charcoal/600`
- Each line: opacity 0 → 1, y offset 8pt → 0pt, spring(response: 0.5, damping: 0.8)
- Stagger: 200ms between lines

### Audio
- File: `hive_reveal_ambient.m4a` — 5.5s ambient pad, layered with subtle wing flutter and a soft chord at phase 4
- Volume: peaks at –12dB, mixes with phone media
- Mute respect: silent if device on Silent switch
- Skip respect: stops on skip

### Haptics
- Phase 4: `UIImpactFeedbackGenerator(style: .light)`
- Phase 5 line 1: `UIImpactFeedbackGenerator(style: .medium)`
- Reduce Motion respected (haptics still fire, considered separate accessibility setting; could gate on Reduce Motion as well based on user feedback)

---

## 1.6 State variants

### State A — Loading (server hasn't returned assignment)
- Phases 1–4 play normally (visual only — bees can swarm without knowing the assignment)
- If by phase 4 server hasn't responded: hive crystallize animation completes, but text reveal waits with subtle pulsing dots ("..." spinner under hive image, max 3s wait)
- If server returns within wait window: text reveals normally
- If server fails after 5s wait: phase 5 swaps to error variant

### State B — Hive assigned (default)
Full sequence as specified.

### State C — No hive available (waitlist)
- Phase 4 hive crystallize completes, but transforms hexagon to a friendly mailbox icon
- Text reveals: "We're growing fast." → "{User name}, your state has a waitlist." → "We'll email you within 7 days."
- CTA: "Got it" → exits onboarding to a holding state, refund processed
- This is rare (engineering should hard-prevent signup without availability) but must exist as a graceful failure

### State D — Network error
- Phase 4 transforms hexagon to retry icon
- Text: "Hmm, something's off." → "We can't reach our hives right now." → CTA: "Try again" (retries) / "Email support"
- Retains paid state; user can come back later and complete assignment without re-paying

### State E — Reduce Motion
- All animation phases collapse to instant fades (300ms each, sequential)
- Bees do not fly; hive appears with simple opacity transition
- Text reveals with simple fades instead of spring + offset
- Total reduced duration: ~2s
- Audio still plays (separate setting)

### State F — Reduce Transparency
- Backdrop becomes solid `bees/honey/100` instead of gradient
- Glow effects use solid color flashes instead of gradients

### State G — Tutorial replay
- Watermark badge top-left: "Tutorial replay · sample"
- Hive number shown: "Hive #00 (Sample)"
- Continue button copy changes: "Back to settings"

---

## 1.7 Edge cases

| Scenario | Behavior |
|---|---|
| User backgrounds app mid-reveal | Animation pauses; resumes from current phase on foreground; if >30s background, restarts from phase 1 |
| Phone call interrupts | Audio ducks, animation continues silent |
| User gets push notification during reveal | Banner appears as normal; reveal continues underneath |
| User force-quits app during reveal | On relaunch, app remembers assignment was shown (server records `revealShownAt`); jumps to S-OBD-08 naming |
| Server returns assignment but later detects conflict (rare race condition) | Naming screen handles the swap silently |
| Accessibility: VoiceOver active | Skip animation entirely; speak: "Welcome to your hive. Hive number 47, at Sunny Acre Farm, Sonoma County, California. Continue button." Then Continue button is focused. |

---

## 1.8 Accessibility

| Element | Treatment |
|---|---|
| Whole screen | VoiceOver focus on appearance: "Welcome to your hive. {Hive identifier}. {Location}. Continue button." Skips all animation phases. |
| Continue button | Standard label "Continue. Button. Goes to hive naming." |
| Skip link | Visible only briefly (phase 2+); VoiceOver users get it as third element |
| Reduce Motion | All animation collapsed to fades, see State E |
| Reduce Transparency | See State F |
| Audio | Standalone setting; defaults follow phone Silent switch |

---

## 1.9 SwiftUI implementation sketch

```swift
struct HiveAssignmentRevealView: View {
    @StateObject var viewModel: HiveRevealViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            BackgroundGradient()
            
            if !reduceMotion {
                BeeSwarmAnimation(phase: viewModel.phase)
                    .accessibilityHidden(true)
            }
            
            HiveCrystallize(phase: viewModel.phase, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Spacer()
                if viewModel.phase >= .nameReveal {
                    RevealText(assignment: viewModel.assignment)
                }
                Spacer()
                if viewModel.phase >= .ctaAppear {
                    Button("Continue") { viewModel.advance() }
                        .buttonStyle(.bees(.primary))
                        .padding(.bottom, 32)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    if viewModel.phase >= .beesEnter && !viewModel.skipped {
                        Button("Skip") { viewModel.skip() }
                            .buttonStyle(.bees(.ghost))
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.fullAccessibilityDescription)
        .task {
            await viewModel.loadAssignmentAndAnimate()
        }
        .onAppear { viewModel.playAudio() }
        .onDisappear { viewModel.stopAudio() }
    }
}
```

**View model concerns:**
- Phase enum: `.hush, .beesEnter, .swarmCoalesce, .hiveCrystallize, .nameReveal, .ctaAppear`
- Async load assignment in parallel with animation; gate phase 5 on data availability
- Persist `revealShownAt` to server on phase 5 success
- Audio via AVAudioPlayer; respect AVAudioSession ambient category to mix with other media

---

## 1.10 Telemetry

- `hive_reveal_started` { context: signup|resub|collapse|sister|tutorial }
- `hive_reveal_skipped` { phase }
- `hive_reveal_completed` { duration_ms, skipped: bool }
- `hive_reveal_error` { reason }
- `hive_reveal_no_availability` (waitlist path)

---

## 1.11 Acceptance criteria

- [ ] Total duration ≤ 6s when not skipped, ≤ 2s with Reduce Motion
- [ ] Animation runs at 60fps on iPhone 12+
- [ ] Skip works at any phase ≥ 2
- [ ] All 7 state variants render correctly
- [ ] VoiceOver reads complete description on appear, skipping animation
- [ ] Audio mixes with other media; respects Silent switch
- [ ] Haptics fire at phase 4 + phase 5 line 1
- [ ] Server assignment latency up to 3s gracefully absorbed without breaking pacing
- [ ] Tutorial replay shows watermark and sample data
- [ ] Network error path retries without losing payment state

---

# PART 2 — S-YOU-13 Cancel Subscription Flow

## 2.1 Purpose & Constraints

This is a 7-step retention flow that must:
- Be honest about what the user loses (immediate video access, no final shipment)
- Not be deceptive or use dark patterns (App Store + FTC compliance)
- Offer fair retention alternatives without burying the cancel CTA
- Hand off cleanly to Apple's subscription management for the actual cancellation
- Update local app state correctly post-cancel

### Apple compliance critical note

**Apple In-App Purchase subscriptions can ONLY be canceled through the App Store.** As an app developer, you cannot programmatically cancel a sub. You can:
- Show your own retention UX before the cancel
- Use `Task { try await AppStore.showManageSubscriptions(in: scene) }` (StoreKit 2) to deep-link to the system sheet
- Listen for `Transaction.updates` to detect when cancellation actually completes

**The "lose access immediately" rule is OUR app rule.** We can revoke entitlements server-side as soon as we detect cancellation intent — but Apple's policy is that the user is paying for their period regardless. We must:
- Be very clear in the disclosure that they will lose video access immediately even though they've paid through the period end
- OR (recommended fallback) keep access through period end and just not ship the final jar

**My recommendation:** make this server-driven (feature flag). Default to "lose access at period end" for App Store review (more typical, less likely to be flagged); offer "lose access immediately" as the brand promise via server config. We'll hard-spec the immediate-loss path as user requested but design it so it can be toggled to period-end without UI rework. **This is a flagged decision — see §2.13.**

### App Store review flags
- Make the cancel CTA visible without scrolling on subscription screen
- Don't pre-select "stay" buttons or use confusing button colors
- Disclose price + cadence + cancel mechanic in onboarding (already done in plan §0)
- Show the cancel destination clearly before deep-linking to App Store

---

## 2.2 Flow Map

```
S-YOU-10 Subscription home
       │
       │ tap [Cancel subscription]
       ▼
[Step 0] Confirmation alert: "Cancel your hive?"  ← prevents accidental tap
       │
       │ tap "Continue cancellation"
       ▼
[Step 1] Reason picker (6 options + "Other")
       │
       │ tap reason → tap [Continue]
       ▼
[Step 2] Retention 1 — Discount
       │              ├── Accept → applied → exit to S-YOU-10
       ▼              │
[Step 3] Retention 2 — Pause
       │              ├── Accept → paused → exit to S-YOU-10
       ▼              │
[Step 4] Retention 3 — Downgrade
       │              ├── Accept → tier change → exit to S-YOU-10
       ▼              │
[Step 5] Disclosure — what you lose
       │
       │ tap [Continue to cancel]
       ▼
[Step 6] Final confirm — type "CANCEL" or hold-to-cancel
       │
       │ confirmed
       ▼
[Step 7a] Apple sub management deep-link
       │
       │ user confirms in Apple's UI
       ▼
[Step 7b] Result screen — back in our app, listening for Transaction.updates
       │
       │ tap [Done]
       ▼
S-YOU-10 (now in canceled state)
```

---

## 2.3 Step-by-step specs

### Step 0 — Confirmation alert (gentle gate)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│            Cancel your hive?                    │
│                                                 │
│  Buzzy McHive is doing well. Are you sure you   │
│  want to leave?                                 │
│                                                 │
│         [ Continue cancellation ]               │
│         [ Keep my hive ]                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Layout:** native iOS `Alert`. Two buttons.
- "Continue cancellation" — destructive style (red text)
- "Keep my hive" — default style (bold, blue)
- No pre-select; tapping outside dismisses (= keep)

**Note:** This is a single screen, not a multi-step modal. It's just an interrupt to prevent thumb-fat-fingering.

### Step 1 — Reason picker

```
┌─────────────────────────────────────────────────┐
│ ✕                                Step 1 of 5    │
├─────────────────────────────────────────────────┤
│                                                 │
│  Why are you leaving?                           │
│  This helps us improve.                         │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Too expensive                         │    │
│  └─────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Not using it enough                   │    │
│  └─────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Issues with my hive                   │    │
│  └─────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Moving / address change               │    │
│  └─────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Life change                           │    │
│  └─────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────┐    │
│  │ ○ Other (tell us)                       │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  [optional text field appears if "Other"]       │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│       [ Continue ]      [ Keep my hive ]        │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Top bar: ✕ close + step indicator "Step 1 of 5" right-aligned
- Title `display/m`, subhead `body/m`
- Six radio options, single-select, 56pt rows, comb-cream background
- "Other" reveals a `TextFieldMultiline` (200 chars) below it
- Sticky footer: "Continue" primary (disabled until selection) + "Keep my hive" secondary

**Step indicator:** displays "Step 1 of 5" because retention offers (steps 2–4) are dynamic based on reasons. Pause + downgrade are skipped if reason was "issues with my hive" (those don't fix the problem). This adapts the visible step count.

**Reason → retention path matrix:**

| Reason | Show discount? | Show pause? | Show downgrade? |
|---|---|---|---|
| Too expensive | ✓ | – | ✓ |
| Not using enough | ✓ | ✓ | ✓ |
| Issues with hive | – | – | – |
| Moving | – | ✓ | – |
| Life change | – | ✓ | – |
| Other | ✓ | ✓ | ✓ |

If reason = "Issues with my hive", flow skips steps 2–4 and routes to a special path: hive replacement / refund offer (S-HIVE-17 emergency variant). This is critical: we don't try to retain a user whose hive is broken. We fix the hive.

### Step 2 — Retention 1: Discount

```
┌─────────────────────────────────────────────────┐
│ ✕                                Step 2 of 5    │
├─────────────────────────────────────────────────┤
│                                                 │
│            [bee with discount tag art]          │
│                                                 │
│                                                 │
│         How about 50% off?                      │
│                                                 │
│  Stay for 2 months at half price.               │
│  Your next bill: $7.50/mo for 2 months,         │
│  then back to $14.99/mo.                        │
│                                                 │
│  Cancel anytime.                                │
│                                                 │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│   [ Take the deal ]    [ No thanks, continue ]  │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Hero illustration top
- Headline + body
- "Cancel anytime" reassurance
- Sticky footer: Accept (primary) + Decline (ghost text button — NOT secondary, smaller weight)

**Acceptance behavior:**
- "Take the deal" → server applies discount (server-side IAP price modification or credit) → success toast → exit to S-YOU-10
- Discount eligibility: only offered to users who have had ≥1 paid month and have not received this specific offer in past 6 months. Backend enforces.

**Decline behavior:**
- "No thanks, continue" → step 3 (or skip to step 5 if reason precludes pause/downgrade)

### Step 3 — Retention 2: Pause

```
┌─────────────────────────────────────────────────┐
│ ✕                                Step 3 of 5    │
├─────────────────────────────────────────────────┤
│                                                 │
│            [paused bee art]                     │
│                                                 │
│                                                 │
│         Take a break instead?                   │
│                                                 │
│  Pause your hive for up to 3 months.            │
│  No charges. We'll keep your hive number        │
│  reserved.                                      │
│                                                 │
│  How long?                                      │
│  ┌────┐ ┌────┐ ┌────┐                            │
│  │ 1m │ │•2m•│ │ 3m │                            │
│  └────┘ └────┘ └────┘                            │
│                                                 │
│  Resumes: July 5, 2026                          │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│   [ Pause my hive ]    [ No, continue ]         │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Hero
- Headline + body
- Duration selector: 3 segmented options 1m / 2m / 3m
- Resume date computed live
- Sticky footer

**Acceptance:**
- Server pauses subscription via Apple's pause API (iOS 13+) for tiers that support it; or applies internal pause flag + user is charged $0 during pause window
- Toast: "Paused until July 5"
- Exit to S-YOU-10 in paused state

**Constraints:**
- Max 3 months in any 12-month period
- Cannot pause during free trial
- During pause: user loses video access (matches our cancel rule), no shipments
- Can manually resume early from S-YOU-10

### Step 4 — Retention 3: Downgrade

```
┌─────────────────────────────────────────────────┐
│ ✕                                Step 4 of 5    │
├─────────────────────────────────────────────────┤
│                                                 │
│         Try a smaller plan?                     │
│                                                 │
│  Pollinator at $14.99/mo gives you:             │
│   ✓ Live video                                  │
│   ✓ Honey jar every 3 months                    │
│   ✓ All hive stats                              │
│                                                 │
│  You'd lose:                                    │
│   – Multi-camera angles                         │
│   – Custom sticker text                         │
│   – Time-lapse highlights                       │
│   – Save sticker favorites                      │
│   – Clip recording                              │
│                                                 │
│  Effective: next billing cycle (June 12)        │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│   [ Switch to Pollinator ]   [ No, continue ]   │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Pre-set headline based on current tier (this example: Forager → Pollinator)
- "What you keep" check list (green)
- "What you lose" minus list (charcoal)
- Effective date callout
- Sticky footer

**Tier downgrade matrix:**
- Forager → offer Pollinator
- Queen Keeper → offer Forager (don't skip two tiers; jarring)
- Pollinator → step skipped (no lower tier)

**Acceptance:**
- Server schedules tier change for next billing cycle (uses StoreKit 2 `Product.purchase` with the new tier as a different sub group entry, OR for downgrades, schedules via the server-side transaction)
- Current tier features remain through current cycle
- Toast: "Switched to Pollinator from June 12"

### Step 5 — Disclosure

```
┌─────────────────────────────────────────────────┐
│ ✕                                Step 5 of 5    │
├─────────────────────────────────────────────────┤
│                                                 │
│         Before you cancel, you should know:     │
│                                                 │
│   ⚠ You'll lose video access immediately        │
│   You won't be able to watch your hive after    │
│   you cancel — even though you've paid          │
│   through {date}.                               │
│                                                 │
│   ⚠ Your final jar won't ship                   │
│   Any shipment scheduled after today is         │
│   canceled. No refund for the cycle.            │
│                                                 │
│   ✓ You'll keep                                 │
│   – Your shipment history                       │
│   – Your achievements                           │
│   – Your saved sticker favorites                │
│                                                 │
│   You can re-subscribe anytime. We may not be   │
│   able to give back the same hive number.       │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│   [ Continue to cancel ]   [ Keep my hive ]     │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Three sections: red ⚠ losses, then green ✓ keeps, then re-subscribe note
- Continue button uses destructive red color
- "Keep my hive" intentionally NOT a smaller button — same visual weight, fair choice

**Critical copy rules (legal):**
- Be exact about what's lost
- Don't hide the "no refund" disclosure in fine print
- Re-subscribe consequences (might not get same hive) disclosed truthfully

**If pause/downgrade was skipped earlier**, step indicator adjusts ("Step 3 of 3"). User must always see this disclosure before confirm.

### Step 6 — Final confirm (hold-to-cancel)

```
┌─────────────────────────────────────────────────┐
│ ✕                                Final step     │
├─────────────────────────────────────────────────┤
│                                                 │
│                                                 │
│         One last thing.                         │
│                                                 │
│  Press and hold the button below for 2          │
│  seconds to confirm cancellation.               │
│                                                 │
│  We'll send you to the App Store to             │
│  finalize. Your subscription stays active       │
│  until you complete cancellation there.         │
│                                                 │
│                                                 │
│         ┌─────────────────────────────┐         │
│         │  ░░░░░░░░░░░░░░░░░░░░░░░░  │         │
│         │  Hold to cancel             │         │
│         └─────────────────────────────┘         │
│                                                 │
│                                                 │
│         [ Keep my hive ]                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Centered explanation
- Hold-to-cancel button: 56pt tall, full-width-minus-32pt, fills with red as held
- Releasing before 2s resets fill
- After 2s: completes, haptic success, advances to step 7
- Below: "Keep my hive" exit (text button)

**Why hold instead of type "CANCEL":**
- Lower friction than typing
- Still intentional (no accidental tap)
- iOS-native pattern for destructive (matches Settings → Erase Phone)

**Behavior:**
- On hold complete → triggers `AppStore.showManageSubscriptions` deep-link
- This opens Apple's subscription management sheet
- User must tap "Cancel Subscription" inside Apple's sheet to actually cancel

### Step 7a — Apple deep-link transition

When user completes hold-to-cancel:
1. Show brief loading spinner (1s)
2. Open `AppStore.showManageSubscriptions(in: windowScene)`
3. App backgrounds; Apple's UI presents
4. User taps Apple's "Cancel Subscription" → confirms in Apple's flow
5. App returns; we receive `Transaction.updates` event with cancellation
6. Advance to step 7b

**If user abandons in Apple's UI:**
- We never see cancellation
- On return to app, show step 7b with friendly state: "It looks like you didn't finish. You can try again or keep your hive."

### Step 7b — Result screen

**State A: cancellation confirmed**
```
┌─────────────────────────────────────────────────┐
│                                                 │
│                  [waving bee]                   │
│                                                 │
│         You're all set                          │
│                                                 │
│  Your hive subscription ends today.             │
│  We'll keep your shipment history and           │
│  achievements safe.                             │
│                                                 │
│  Come back anytime —                            │
│  we'd love to have you.                         │
│                                                 │
│                                                 │
│                                                 │
│         [ Done ]                                │
│         [ Tell us why one last time ]           │
│                                                 │
└─────────────────────────────────────────────────┘
```

- Single CTA "Done" → S-YOU-10 (now showing canceled state)
- Optional secondary: "Tell us why one last time" → opens an exit survey form (one open text field), submits to support

**State B: cancellation incomplete**
```
┌─────────────────────────────────────────────────┐
│                                                 │
│         It looks like you didn't finish         │
│                                                 │
│  No problem. You can try again or keep          │
│  your hive.                                     │
│                                                 │
│         [ Try cancellation again ]              │
│         [ Keep my hive ]                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

- "Try again" → re-opens Apple's manage sheet
- "Keep my hive" → S-YOU-10 (still active)

---

## 2.4 Edge cases

| Scenario | Behavior |
|---|---|
| User in free trial cancels | Same flow but disclosure copy adapts: "You'll lose access at end of trial. No charge." Skip pause offer (can't pause trial). |
| User has active gift jars in flight | Disclosure adds: "Your gift to {recipient} will still ship as scheduled." Gift jars are one-off Stripe charges, unaffected by sub cancel. |
| User has scheduled future jar (pre-locked sticker) | Disclosure adds: "Your locked sticker for the {month} jar won't ship." User can re-lock if they re-subscribe before the lock window expires. |
| User has Queen Keeper sister hive active | Both hives become inaccessible immediately; sister hive concept is wrapped in same subscription. |
| User has a paused subscription | Cancel flow skips pause retention offer (can't pause while paused). Direct to discount or downgrade. |
| User has shipments with active claims | Disclosure adds: "Your open claim for the April shipment continues — we'll resolve it via email." |
| App Store cancel detection delay (Apple may take seconds) | Show "Confirming with Apple..." state on step 7b, max 10s wait, then show optimistic confirmed state with note "We'll update if needed." |
| User re-subscribes within 30 days | Skip account deletion grace; offer same hive if available |
| Apple refund request initiated separately | Server listens for Apple refund webhooks; updates billing history; does not auto-trigger app cancel flow |
| User cancels but is mid-shipment (already shipped, not delivered) | Shipment continues; notification: "Your last jar is already on its way." |
| User on Family Sharing | Same flow; cancel removes their access; family organizer keeps the underlying purchase per Apple rules |

---

## 2.5 Accessibility

| Element | Treatment |
|---|---|
| Step indicator | "Step {n} of {total}" announced on screen change |
| Reason picker | Standard radio group; VoiceOver announces selection |
| Retention CTAs | Accept and decline buttons clearly labeled with their action |
| Hold-to-cancel | VoiceOver alternate: replaces hold gesture with "Confirm cancellation" button + "Press and hold" gesture is announced as "Triple-tap to confirm" |
| Disclosure section | Sectioned with headings; each warning gets its own readable block |
| Reduce Motion | Hold button fill animation simplified to instant fill on hold start; all transitions become fades |

---

## 2.6 SwiftUI implementation notes

```swift
struct CancelSubscriptionFlow: View {
    @StateObject var viewModel: CancelFlowViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            CancelStep0View()
                .navigationDestination(for: CancelStep.self) { step in
                    switch step {
                    case .reasonPicker: ReasonPickerView(...)
                    case .discount: DiscountRetentionView(...)
                    case .pause: PauseRetentionView(...)
                    case .downgrade: DowngradeRetentionView(...)
                    case .disclosure: DisclosureView(...)
                    case .holdToConfirm: HoldToConfirmView(onConfirm: viewModel.openAppleManagement)
                    case .result(let state): ResultView(state: state)
                    }
                }
        }
        .task {
            for await update in Transaction.updates {
                await viewModel.handleTransactionUpdate(update)
            }
        }
    }
}

// View model
class CancelFlowViewModel: ObservableObject {
    @Published var path: [CancelStep] = []
    @Published var reason: CancelReason?
    
    func openAppleManagement() async {
        guard let scene = UIApplication.shared.activeScene else { return }
        do {
            try await AppStore.showManageSubscriptions(in: scene)
            // Wait briefly for Transaction.updates to fire
            // If no update within 8s, show "incomplete" state
        } catch {
            path.append(.result(.error))
        }
    }
    
    func handleTransactionUpdate(_ update: VerificationResult<Transaction>) async {
        if case .verified(let tx) = update, tx.revocationDate != nil {
            // Subscription revoked
            await revokeServerEntitlements()
            path.append(.result(.success))
        }
    }
    
    func revokeServerEntitlements() async {
        // Server-side: flip user's `subscriptionActive` flag, revoke video stream tokens, cancel pending shipments
    }
}
```

**Key engineering concerns:**
- Use **StoreKit 2** (`Transaction.updates`, `AppStore.showManageSubscriptions`) — far cleaner than the legacy SKPaymentQueue approach
- **Server-side revocation** must be near-instant once Apple confirms cancellation; the client should not be the source of truth on entitlement state
- **Entitlement revocation propagation:** HLS stream tokens are signed JWTs with short TTL (e.g., 5 min); after revocation, refresh fails; client routes to "subscription required" state. This means the actual loss of access has up to 5min latency, which is acceptable.
- **Retention offer eligibility** is server-side per user, never trust client. Server returns "this user is eligible for these offers" before flow begins.
- **Idempotency:** if user retries cancellation, don't double-apply pauses or downgrades.

---

## 2.7 Telemetry

- `cancel_flow_started`
- `cancel_step0_continued`
- `cancel_reason_selected` { reason }
- `cancel_discount_offered` / `_accepted` / `_declined`
- `cancel_pause_offered` / `_accepted` / `_declined` { duration_months }
- `cancel_downgrade_offered` / `_accepted` / `_declined` { from_tier, to_tier }
- `cancel_disclosure_viewed`
- `cancel_hold_started` / `_completed` / `_abandoned`
- `cancel_apple_management_opened`
- `cancel_completed` { total_steps_seen, accepted_at_step? }
- `cancel_abandoned` { last_step }
- `cancel_exit_survey_submitted` { text_length }

These telemetry events are critical: this flow's effectiveness (retention rate per step) directly drives revenue.

---

## 2.8 Acceptance criteria

- [ ] All 7 steps render correctly with proper step indicator
- [ ] Reason → retention path matrix correctly skips offers
- [ ] Issues-with-hive reason routes to hive replacement (not retention)
- [ ] Each retention offer can be accepted; server applies change correctly
- [ ] Discount offer eligibility enforced server-side (no double-dipping)
- [ ] Pause limited to 3 months / 12-month period
- [ ] Downgrade scheduled for next billing cycle, current cycle preserved
- [ ] Disclosure copy reviewed and approved by legal
- [ ] Hold-to-cancel requires 2s; releases reset; haptic on completion
- [ ] StoreKit 2 deep-link to manage subscriptions works on iOS 16+
- [ ] Server entitlements revoked within 5min of Apple confirmation
- [ ] Edge cases tested: trial cancel, paused cancel, mid-shipment cancel, family sharing
- [ ] Telemetry fires for every step transition
- [ ] VoiceOver flow tested end-to-end
- [ ] App Store review: subscription disclosure visible without scrolling on S-YOU-10 cancel CTA

---

## 2.9 Flagged decision (legal + product)

**Question:** Do users actually lose video access at the moment of cancellation, or at the period end?

| Option | Pros | Cons | Recommendation |
|---|---|---|---|
| A. Lose immediately (your stated rule) | Stronger retention pressure; clear "use it or lose it" framing | Apple may flag as user-hostile in review; FTC could challenge ("they paid for the period") | Higher risk |
| B. Lose at period end (Apple-aligned) | Standard, low review risk; user-friendly | Less retention pressure; less urgency | Lower risk |
| C. Server-flag toggleable | Ship Option B for App Store launch; toggle to A post-launch if metrics support it | Slight engineering overhead | **My recommendation** |

I've spec'd the immediate-loss path per your direction, with a note in §2.6 to make it server-flag-driven so you can switch without UI changes. **Confirm or adjust this before legal/App Store review.**

---

# PART 3 — S-GIFT-02 → S-GIFT-07 Gift Flow

## 3.1 Purpose & Scope

Gift flow has two product variants and the most branching of any flow in the app. Must handle:
- **Jar gift** (Forager+ entitlement) — one-off Stripe charge, ships to recipient, no account required for recipient
- **Subscription gift** (Queen Keeper entitlement) — multi-month commit, recipient creates account to claim, billing belongs to gifter
- Recipient **claim deep-link flow** for subscription gifts
- Failed payment, invalid addresses, recipient-already-has-Bees collisions
- Optional digital card + packaging upgrade

This spec covers screens S-GIFT-02 through S-GIFT-07 plus S-GIFT-10 recipient claim. S-GIFT-01 (gift launchpad) and S-GIFT-08, S-GIFT-09 (gifter's tracking + history) are routine list screens already covered in main plan.

## 3.2 Flow Map

```
S-GIFT-01 Gift launchpad
       │
       ├── tap [Send a jar]            (Forager+)
       │                                │
       │                                ▼
       │                         S-GIFT-02 Recipient
       │                                │
       │                                ▼
       │                         S-GIFT-03A Sticker (jar)
       │                                │
       │                                ▼
       │                         S-GIFT-04 Message + card
       │                                │
       │                                ▼
       │                         S-GIFT-05 Packaging (optional)
       │                                │
       │                                ▼
       │                         S-GIFT-06 Review + pay (Stripe)
       │                                │
       │                                ▼
       │                         S-GIFT-07 Confirmation
       │
       └── tap [Gift a subscription]   (Queen Keeper only)
                                        │
                                        ▼
                                 S-GIFT-02 Recipient
                                        │
                                        ▼
                                 (tier picker for the gift sub)
                                        │
                                        ▼
                                 S-GIFT-03B Sticker (first jar)
                                        │
                                        ▼
                                 S-GIFT-04 Message + card
                                        │
                                        ▼
                                 S-GIFT-05 Packaging (optional)
                                        │
                                        ▼
                                 S-GIFT-06 Review + pay (Apple IAP for sub commitment)
                                        │
                                        ▼
                                 S-GIFT-07 Confirmation
                                        │
                                        ▼
                                 [recipient gets email →]
                                        │
                                        ▼
                                 S-GIFT-10 Recipient claim (deep link)
```

---

## 3.3 Step-by-step specs

### S-GIFT-02 — Recipient info

```
┌─────────────────────────────────────────────────┐
│ ←   Who's it for?                  Step 1 of 5  │
├─────────────────────────────────────────────────┤
│                                                 │
│  RECIPIENT                                      │
│  ┌─────────────────────────────────────────┐    │
│  │ Name (so we can address the package)    │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Their email                             │    │
│  └─────────────────────────────────────────┘    │
│  We'll email them a card on the day it ships.   │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Their shipping address                  │    │
│  │ Street, apt, city, state, zip           │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ✉ Use a different email for the card    │    │
│  └─────────────────────────────────────────┘    │
│  (advanced — separate notification email)        │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Top: back chevron + title + step indicator
- Three required fields, one optional advanced
- Address validation runs on continue (USPS API)
- For sub gift: address can be updated by recipient on claim; we still require gifter to enter as default
- For jar gift: address final

**Validation:**
- Name: 2–50 chars, letters + spaces + hyphens + apostrophes
- Email: standard regex
- Address: must validate to a US shipping address in supported states (subset of launch states)
- Continue disabled until all required pass

**Edge cases:**
- Address out of supported states: error sheet "{State} isn't supported yet. Want to give a digital gift card instead?" → upcoming feature; for v1, blocks gift completion
- Gifter accidentally enters their own email: warning ("This is your account email — are you sure?")
- Bulk-suspicious patterns (sending multiple gifts to disposable emails): server-side anti-fraud; blocks past a threshold

### S-GIFT-02b — Tier picker (subscription gift only)

Inserted between S-GIFT-02 and S-GIFT-03 for sub gifts.

```
┌─────────────────────────────────────────────────┐
│ ←   Pick a plan for them          Step 2 of 6   │
├─────────────────────────────────────────────────┤
│                                                 │
│  How long?                                      │
│  ┌────────┐ ┌────────┐ ┌────────┐                │
│  │ 3 mos  │ │•6 mos •│ │ 12 mos │                │
│  │ $44.97 │ │ $89.94 │ │ $179.88│                │
│  └────────┘ └────────┘ └────────┘                │
│  (Forager pricing)                              │
│                                                 │
│  Which plan?                                    │
│  ┌────────┐ ┌────────┐ ┌────────┐                │
│  │Pollin. │ │•Forager│ │  Queen │                │
│  │ $14.99 │ │ $24.99 │ │ $49.99 │                │
│  └────────┘ └────────┘ └────────┘                │
│                                                 │
│  Total today: $89.94 (one-time, prepaid)        │
│  After it ends, they can re-subscribe at        │
│  their own cost.                                │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Note:** Subscription gifts are **prepaid one-time charges** for a fixed duration. Not auto-renewing. This avoids billing-belongs-to-gifter complexity. After the gift period ends, recipient can re-subscribe with their own payment.

**Tier options:** Pollinator / Forager / Queen Keeper. Duration: 3 / 6 / 12 months.

**Pricing:** straight multiplication. No annual discount on sub gifts — they're pre-paid, recipient gets stable price.

**Apple IAP:** sub gifts are configured as Apple's "non-consumable" or "non-renewing subscription" SKUs. This means each duration × tier combo is a separate SKU (3×3 = 9 SKUs). Engineering to set up product catalog accordingly.

### S-GIFT-03A — Sticker customization (jar gift)

Identical to S-HONEY-02 sticker customizer except:
- Header changes: "Customize their sticker"
- Available designs scoped to "gift" category (could include Birthday, Thank You, Just Because themes mixed with regular designs)
- Custom text encouraged: placeholder hint "Their name, an inside joke, a date..."
- "Save as favorite" option hidden (gift designs aren't reusable for own shipments)
- Footer button is "Continue" not "Lock design" — gift sticker locks immediately on payment

### S-GIFT-03B — First-jar sticker (subscription gift)

Same as S-GIFT-03A but copy explains: "This will go on their first jar. They can customize the rest."

### S-GIFT-04 — Message + digital card

```
┌─────────────────────────────────────────────────┐
│ ←   Add a card                    Step 3 of 5   │
├─────────────────────────────────────────────────┤
│                                                 │
│  CARD STYLE                                     │
│  ╭────╮ ╭────╮ ╭────╮                           │
│  │ 1  │ │•2• │ │ 3  │                            │
│  │card│ │card│ │card│                            │
│  ╰────╯ ╰────╯ ╰────╯                           │
│  Hexagon · Selected                             │
│                                                 │
│  YOUR MESSAGE                                   │
│  ┌─────────────────────────────────────────┐    │
│  │                                         │    │
│  │ Happy birthday Mom!                     │    │
│  │ I know how much you love our garden     │    │
│  │ — now you have your own bees too.       │    │
│  │                                         │    │
│  │ Love,                                   │    │
│  │ Nick                                    │    │
│  │                                         │    │
│  └─────────────────────────────────────────┘    │
│  142 / 200 characters                           │
│                                                 │
│  PREVIEW                                        │
│  ┌──────────────────────────────────────────┐   │
│  │  [Card style 2 with message preview]     │   │
│  │  [Live updating]                          │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  Sender name (signs the card)                   │
│  ┌─────────────────────────────────────────┐    │
│  │ Nick                                    │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Layout sections:**
1. **Card style picker** — 3 visual styles (designer to finalize)
2. **Message text area** — `TextFieldMultiline`, 200 char max, live counter
3. **Live preview** — rendered card with selected style + message + sender name
4. **Sender name** — defaults to gifter's first name from account

**Validation:**
- Same content moderation as sticker text (server-side check on submit)
- Max 200 chars
- Min 0 chars (message optional)

**Card delivery:**
- Email sent to recipient on shipment ship date (jar gift) or immediately upon payment (sub gift, since recipient must claim)
- Email contains: rendered card image, message, "open your gift" link (sub gifts only)

**Edge cases:**
- Empty message + skip → still sends a default card "Someone got you something sweet."
- Profanity in message → blocked at submit, error sheet with line highlighted

### S-GIFT-05 — Packaging upgrade (optional)

```
┌─────────────────────────────────────────────────┐
│ ←   Make it special?              Step 4 of 5   │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │     [Standard packaging photo]          │    │
│  │  STANDARD                          $0   │    │
│  │  Kraft box, jar wrap, sticker.          │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │     [Premium gift box photo]            │    │
│  │  PREMIUM GIFT BOX                  $12  │    │
│  │  Wooden box, ribbon, gold seal,         │    │
│  │  honey wand included.                   │    │
│  │                              ●          │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│              [ Continue ]                       │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Two large cards, photo-driven
- Single-select; default is Standard ($0)
- Premium upgrade adds line item to total

**Behavior:**
- Continue available immediately (default Standard works)
- Premium price is engineering-confirmable, $12 placeholder

### S-GIFT-06 — Review + pay

```
┌─────────────────────────────────────────────────┐
│ ←   Review your gift              Step 5 of 5   │
├─────────────────────────────────────────────────┤
│                                                 │
│  TO                                             │
│  Mom (Sarah Smith)                              │
│  sarah.smith@example.com                        │
│  123 Maple Lane, Sonoma CA 95476                [Edit]
│                                                 │
│  GIFT                                           │
│  ┌──────────────┐                               │
│  │ [3D jar]     │  Jar of honey                 │
│  │              │  Floral · "Happy birthday Mom"│
│  └──────────────┘                               │
│                                              [Edit]
│                                                 │
│  CARD                                           │
│  Hexagon style                                  │
│  "Happy birthday Mom! I know how much..."       │
│                                              [Edit]
│                                                 │
│  PACKAGING                                      │
│  Premium Gift Box                            +$12
│                                              [Edit]
│                                                 │
│  ─────────────────────────────────              │
│  Jar gift                              $25.00   │
│  Premium packaging                      $12.00   │
│  Tax                                    $2.96   │
│  ─────────────────────────────────              │
│  TOTAL                                 $39.96   │
│                                                 │
│  Promo code?                          [Apply]   │
│                                                 │
│                                                 │
│  By continuing, you agree to send this gift     │
│  on {ship date}. We can cancel and refund up    │
│  to 24 hours before that date.                  │
│                                                 │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│       [ Pay with Apple Pay ]                    │
│       [ Use a card ]                            │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Sectioned recap with Edit links per section
- Itemized total
- Promo code inline expandable
- Cancellation policy disclosure
- Sticky footer: Apple Pay primary + card secondary

**Payment routing:**
- **Jar gift:** Stripe payment intent. One-off charge. (NOT Apple IAP — physical good.)
- **Subscription gift:** Apple IAP non-renewing subscription SKU (since it's prepaid digital subscription access). Uses StoreKit 2 product purchase.

**Error handling:**
- Payment failure: stay on screen, show error toast, retry available
- Address validation re-runs on submit (in case it changed)
- Sticker text re-moderates on submit (in case it changed)
- Promo code: validates against server, shows applied discount inline

### S-GIFT-07 — Confirmation

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [confetti animation]               │
│                                                 │
│         Sweet — gift sent.                      │
│                                                 │
│  Mom (Sarah Smith) will get an email when       │
│  her honey ships on May 18.                     │
│                                                 │
│  Order #BEE-2026-04812                          │
│                                                 │
│                                                 │
│  We'll let you know when it's delivered.        │
│                                                 │
│                                                 │
│         [ Send another ]                        │
│         [ Track this gift ]                     │
│         [ Done ]                                │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Sub gift confirmation variant copy:**
"Mom (Sarah Smith) will get an email today with a link to claim her hive. We'll let you know when she activates it."

**Behavior:**
- Confetti animation, ~1.5s
- Three CTAs:
  - "Send another" → S-GIFT-01 (loops back to launchpad)
  - "Track this gift" → S-GIFT-08 (status tracker)
  - "Done" → returns to Honey tab

### S-GIFT-10 — Recipient claim (deep link)

**Trigger:** Recipient receives email with deep link `bees://gift/claim/{token}`. Tapping in email opens app (or App Store if not installed).

```
┌─────────────────────────────────────────────────┐
│                                                 │
│          [animated card opening]                │
│                                                 │
│         Nick sent you a hive.                   │
│                                                 │
│              ╭─────────────╮                    │
│              │ [card art]  │                    │
│              │             │                    │
│              │  "Happy     │                    │
│              │   birthday  │                    │
│              │   Mom..."   │                    │
│              │             │                    │
│              ╰─────────────╯                    │
│                                                 │
│         [ Claim my hive ]                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Sequence:**

1. **Card reveal** — animated card opens, message shown, gifter named
2. **Tap "Claim my hive"** → if no app account: abbreviated S-AUTH-04 (Apple/Google/Email signup); if existing account: S-GIFT-10b account-already-exists collision handling
3. **Skip tier comparison** (gift defined the tier)
4. **Skip address entry** if jar gift (gifter entered) OR show address confirm if sub gift (recipient can update)
5. **Skip first-sticker customization** (gifter customized for jar gift) OR proceed to first-sticker for sub gift
6. **Skip payment** (gifter paid)
7. **Drop into Hive tab** with hive assignment reveal (S-OBD-07) before drop

### S-GIFT-10b — Recipient account collision

If recipient email matches an existing Bees user:

**Jar gift:**
- Show: "Your honey is on its way. We'll send tracking to {their email}."
- No account interaction needed; they don't even need to download the app
- Sticker design + message already locked in by gifter

**Subscription gift:**
- Show: "{Gifter} sent you a hive subscription. You already have a Bees account — would you like to extend your subscription?"
- Two options:
  - "Extend my subscription" → adds gift duration to their existing sub end date; gifter sees extension
  - "Save it for later" → gift held in escrow until existing sub ends or 12 months pass, whichever first; gifter notified
- If recipient is currently an active subscriber at a higher tier than gift: show "You're already on Queen Keeper — would you like {gifter} to gift {tier upgrade equivalent} instead?" — for v1, simplest behavior: hold the gift in escrow until their existing sub lapses

**Edge cases:**
- Recipient on a paused sub: gift waits until they resume
- Recipient previously canceled and account in soft-deleted state: gift unlocks and restores account if claimed within 30-day grace
- Recipient never claims (sub gift): hold for 90 days, then refund gifter automatically with notification

---

## 3.4 Edge cases (full table)

| Scenario | Behavior |
|---|---|
| Gifter cancels gift before ship | Allowed up to 24h before ship date for jar gift; for sub gift, allowed before recipient claims; full refund both cases |
| Gifter's payment fails after submission (stripe webhook) | Order is voided; gifter notified via push + email; can retry |
| Recipient address invalid after gift placed | Email recipient: "We couldn't ship to this address. Update it here." If no update in 7 days, gifter is notified to update |
| Recipient declines (sub gift) | Allowed before claim; gifter refunded; recipient gets a polite "received" notice |
| Multiple gifts to same recipient stack | Allowed; multiple jars accumulate; multiple sub gifts extend duration sequentially |
| Gifter is on free trial | Can send jar gifts (one-off, not gated by trial); cannot send sub gifts (Queen Keeper feature requires paid tier) |
| Gifter's tier changes after gift sent | Gift unaffected — already paid for |
| Promo code valid for self only | Server validation rejects with friendly message |
| Recipient already gifted by same gifter recently | No restriction; spam-control via rate-limiting (e.g., max 5 gifts to same recipient per month) |

---

## 3.5 Accessibility

| Element | Treatment |
|---|---|
| Multi-step navigation | Step indicator announced ("Step 1 of 5") on each transition |
| Address form | Standard label/hint pattern; autocomplete announced |
| Card style picker | "Card style 2 of 3, hexagon. Selected." |
| Message text area | Char counter announced as user types |
| Card preview | "Card preview, {style}. {Message}. From {sender name}." |
| Packaging cards | "Standard packaging, free, selected." / "Premium gift box, plus 12 dollars." |
| Review screen | Sectioned with headings; total clearly announced |
| Confirmation | "Sweet — gift sent." then content, then CTAs |
| Recipient claim | Card opening animation hidden from VoiceOver; full content read in order |
| Reduce Motion | Confetti becomes simple overlay; card opening becomes instant fade |

---

## 3.6 SwiftUI implementation notes

```swift
struct GiftFlow: View {
    @StateObject var viewModel: GiftFlowViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            GiftLaunchpadView()
                .navigationDestination(for: GiftStep.self) { step in
                    switch step {
                    case .recipientInfo: RecipientInfoView(...)
                    case .tierPicker: TierPickerView(...)
                    case .stickerCustomization: StickerCustomizerView(mode: .gift)
                    case .messageCard: MessageCardView(...)
                    case .packaging: PackagingView(...)
                    case .reviewPay: ReviewPayView(...)
                    case .confirmation(let order): ConfirmationView(order: order)
                    }
                }
        }
    }
}

class GiftFlowViewModel: ObservableObject {
    @Published var giftType: GiftType = .jar
    @Published var recipient: RecipientInfo = .empty
    @Published var tier: Tier = .forager
    @Published var duration: Months = .six
    @Published var stickerDesign: StickerDesign?
    @Published var card: GiftCard = .empty
    @Published var packaging: PackagingTier = .standard
    
    func processPayment() async throws -> Order {
        switch giftType {
        case .jar:
            return try await stripeService.charge(amount: total, ...)
        case .subscription:
            return try await iapService.purchaseGiftSub(duration, tier)
        }
    }
}
```

**Engineering concerns:**
- Two payment providers (Stripe + Apple IAP) require different SDK integrations and webhook handling
- Subscription gift SKUs in App Store Connect: 3 tiers × 3 durations = 9 non-renewing subscription products
- Gift token system: signed JWT with payload (gifter ID, recipient email, tier, duration, claim deadline) — verifiable by server without DB lookup
- Anti-fraud: rate-limit gift creation per gifter, validate recipient email reputation
- Email service: transactional template per stage (gift sent, tracking, delivered, recipient invite, claimed, never-claimed-90d)

---

## 3.7 Telemetry

- `gift_launchpad_viewed`
- `gift_type_selected` { type: jar|subscription }
- `gift_recipient_entered`
- `gift_address_validation_failed` { reason }
- `gift_tier_picked` { tier, duration }
- `gift_sticker_customized` { design_id, has_text }
- `gift_message_written` { length, card_style }
- `gift_packaging_selected` { tier }
- `gift_review_viewed` { total }
- `gift_promo_applied` { code, discount }
- `gift_payment_started` { method }
- `gift_payment_succeeded` { method, total }
- `gift_payment_failed` { reason }
- `gift_confirmed` { order_id, type }
- `gift_recipient_email_sent` { type }
- `gift_recipient_claim_opened` { token }
- `gift_recipient_claimed` { order_id, time_to_claim_h }
- `gift_recipient_collision_handled` { resolution }
- `gift_unclaimed_refunded` (90-day)

---

## 3.8 Acceptance criteria

- [ ] Both gift types (jar + subscription) flow end-to-end
- [ ] Stripe payment for jar gifts (one-off) tested incl. failures
- [ ] Apple IAP for subscription gifts (non-renewing) tested for all 9 SKUs
- [ ] Address validation blocks unsupported states
- [ ] Sticker text and message both pass through content moderation
- [ ] Card style + message live-preview updates correctly
- [ ] Packaging upgrade adds correctly to total
- [ ] Promo codes apply server-side
- [ ] Confirmation includes order ID + ship date
- [ ] Recipient email sent on correct schedule (jar: at ship; sub: immediately on payment)
- [ ] Recipient claim deep-link works from email
- [ ] Recipient account collision handled correctly for both gift types
- [ ] Existing-user receiving sub gift gets extension or escrow option
- [ ] 90-day unclaimed sub gift auto-refunds gifter
- [ ] Gifter can track gift status from S-GIFT-08
- [ ] Gifter can cancel jar gift up to 24h before ship date
- [ ] All 5 step indicators correct across gift type variations
- [ ] VoiceOver flow tested
- [ ] Edge cases: trial gifter, paused subscription gifter, multi-gift to same recipient, address change after submission

---

# Cross-batch summary

This batch covers three of the most complex flows in the app:

| Flow | Risk | Highlights |
|---|---|---|
| **S-OBD-07 Reveal** | Low complexity, high emotional stakes | 6-phase animation, 7 state variants, ≤6s budget, Reduce Motion fallback |
| **S-YOU-13 Cancel** | High legal complexity | 7 steps with reason-driven branching, hold-to-confirm, Apple IAP deep-link, server entitlement revocation, flagged decision on access-loss timing |
| **S-GIFT-02→07** | High product complexity | 5–6 step flow with two payment paths, recipient claim deep-link, account collision handling, two-channel notifications |

## Implementation priority

If MVP is the goal, sequence:
1. **Reveal** — Phase 1 must-have; relatively self-contained
2. **Cancel** — Phase 1 must-have for App Store compliance
3. **Gift flow** — Phase 3 (growth phase per main plan)

## Decisions still needed

1. **Cancel access-loss timing** — confirm immediate vs period-end (§2.9)
2. **Sub gift SKU pricing** — confirm whether sub gifts get any discount vs straight monthly multiplied
3. **Gift packaging premium price** — $12 placeholder
4. **Gift card visual styles** — designer to provide 3 styles
5. **Gift message moderation strictness** — same level as sticker text? More lenient (private message)?
6. **Recipient collision policy** — for sub gifts to existing subscribers, default to extend or escrow?

---

**End of batch 2 wireframes.**

Recommended next deep-spec targets, in priority order:
- **S-HONEY-01 Honey Home** (state-rich; current shipment timeline + history + quick actions)
- **S-HIVE-04 Stat Detail (chart variants)** (complex chart UX, comparison mode, annotation pins)
- **S-OBD onboarding sequence end-to-end** (assemble all S-OBD screens into single critical-path spec)
- **S-AUTH-03 Demo Hive Viewer** (conversion-critical, soft signup wall)
