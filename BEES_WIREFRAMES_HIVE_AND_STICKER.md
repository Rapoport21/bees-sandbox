# Bees iOS — Deep Wireframes
## S-HIVE-01 (Hive Home) & S-HONEY-02 (Sticker Customizer)

**Version:** 1.0
**Date:** 2026-05-05
**Companion to:** `BEES_APP_PLAN.md`
**Audience:** iOS engineering + design QA

These two screens are flagged as highest-risk because:
- **Hive Home** has 9 distinct hive states + 3 tier variants + live video performance constraints + the daily-open habit
- **Sticker Customizer** has multi-input form + 3D preview + tier gating + irreversible lock mechanic + server-side moderation in the loop

---

# PART 1 — S-HIVE-01 Hive Home

## 1.1 Purpose

The daily-engagement screen. Every push notification tap, every cold open, every "let me check on the bees" lands here. Must:
- Load fast (target: live frame in ≤ 3s on cellular)
- Feel alive (animated counter, video moving)
- Communicate hive state honestly without alarming
- Surface one delightful thing each visit (achievement, time-lapse, harvest event)
- Make customization + history easy to reach

---

## 1.2 Variants Matrix

The screen renders one of **9 hive-state variants** crossed with **3 tier variants** crossed with **2 onboarding variants** (full data vs first-launch warm-up).

### Hive states (mutually exclusive, server-driven)
1. **Live & healthy** — default
2. **Live but partial** — one or more sensors offline, video fine (or vice versa)
3. **Camera offline** — video down, sensors fine
4. **Sensors offline** — video fine, no readings
5. **All offline** — both down (very rare; treat as outage)
6. **Hive emergency** — queen lost, swarm, collapse warning (server-flagged)
7. **Winter dormancy** — November–February seasonal state, automatically applied
8. **Maintenance** — farmer-scheduled offline window (e.g., hive inspection)
9. **Sister hive override** — primary hive in long-term outage; sister activated

### Tier-driven differences (only Hive home, full list in main plan)
| Element | Pollinator | Forager | Queen Keeper |
|---|---|---|---|
| Camera angle picker | Hidden (single cam) | Visible (3 angles) | Visible (3 angles) |
| Save clip / screenshot | Locked → paywall | Available | Available |
| Time-lapse highlights card | Hidden | Visible | Visible + weekly recap row |
| Compare button | Visible (if setting on) | Visible (if setting on) | Visible (if setting on) |
| Stat tile refresh rate | 30s | 30s | 30s (priority backend lane) |

### Other modifiers
- **Achievements glance** — hidden if user has zero achievements (rare, only first 24h)
- **Trial banner** — top of screen if user is in last 3 days of trial
- **Past-due banner** — top of screen if subscription past-due
- **Anomaly callout** — inline card if recent anomaly + user has notifications opted in

---

## 1.3 Anatomy & Layout

iPhone 14 Pro spec (393×852pt). Layout uses safe areas; no fixed pixel offsets in build.

```
┌─────────────────────────────────────────────────┐  ← top safe area
│ status bar (system)                             │
├─────────────────────────────────────────────────┤
│ ① TOP BANNER ZONE (conditional, 44pt)           │  trial / past-due / anomaly
├─────────────────────────────────────────────────┤
│                                                 │
│ ② LIVE VIDEO ZONE (220pt, 16:9 letter-boxed)    │  hero
│                                                 │
├─────────────────────────────────────────────────┤
│ ③ HIVE IDENTITY PILL (56pt)                     │  name · farm · health pill
├─────────────────────────────────────────────────┤
│ ④ STAT STRIP (96pt, horizontal scroll)          │  7 stat tiles
├─────────────────────────────────────────────────┤
│ ⑤ ACTIVITY COUNTER CARD (124pt)                 │  animated takeoffs/landings
├─────────────────────────────────────────────────┤
│ ⑥ ACHIEVEMENTS GLANCE (96pt) — conditional      │
├─────────────────────────────────────────────────┤
│ ⑦ TIME-LAPSE HIGHLIGHTS (148pt) — Forager+ only │
├─────────────────────────────────────────────────┤
│ ⑧ HARVEST / FARM EVENT (variable) — situational │
├─────────────────────────────────────────────────┤
│ ⑨ QUICK ACTIONS ROW (56pt)                      │  Full stats · Compare · etc.
├─────────────────────────────────────────────────┤
│ extra padding for tab bar                       │
└─────────────────────────────────────────────────┘
[🐝 Hive] [🍯 Honey] [🌻 Farm] [👤 You]            ← tab bar (49pt)
```

### ASCII wireframe — default state (Forager tier, healthy hive)

```
┌─────────────────────────────────────────────────┐
│ 9:41                              📶 100% 🔋    │
├─────────────────────────────────────────────────┤
│                                                 │
│                                                 │
│   ┌●LIVE┐                          ┌🔇┐  ┌⛶ ┐  │
│   └─────┘                          └──┘  └──┘   │
│                                                 │
│        ░░░░░░░░░░ LIVE VIDEO ░░░░░░░░░░         │
│        ░░░░░░░░░░ entrance cam ░░░░░░░░         │
│        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░         │
│                                                 │
│   [📸] [🎬] [📤]            ┌entrance ▼┐        │
│                              └──────────┘       │
├─────────────────────────────────────────────────┤
│  Buzzy McHive             ┌─THRIVING─┐          │
│  Sunny Acre · Sonoma, CA  └──────────┘          │
├─────────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐  →  │
│  │92°F│ │64% │ │47lb│ │58k │ │1.2k│ │ 🎵 │     │
│  │TEMP│ │HUM │ │WGT │ │BEES│ │OUT │ │SND │     │
│  │ ↗  │ │ →  │ │ ↗  │ │ ↗  │ │ ↗  │ │ →  │     │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘     │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │  🐝  ACTIVITY RIGHT NOW                   │  │
│  │                                           │  │
│  │     ↑ 1,247           ↓ 1,253             │  │
│  │     Take-offs         Landings            │  │
│  │                                           │  │
│  │  ▓▓▓▓▓▓░░░░░░░░░░ Last 60 seconds         │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  🏆 ACHIEVEMENTS                  View all  →   │
│  ┌────┐ ┌────┐ ┌────┐                           │
│  │ 🥇 │ │ 🌱 │ │ 🍯 │                            │
│  │First│ │Spring│ │Sweet│                       │
│  │week │ │ wake │ │spot │                       │
│  └────┘ └────┘ └────┘                           │
├─────────────────────────────────────────────────┤
│  ✨ YESTERDAY'S HIGHLIGHTS                      │
│  ┌─────────────────────────────────────────┐    │
│  │ [thumbnail]                  ▶  0:45    │    │
│  │ Heavy traffic at 11:42 AM               │    │
│  └─────────────────────────────────────────┘    │
├─────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐             │
│  │ 📊 Full stats│  │ 🔄 Compare   │             │
│  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────┘
[•🐝•] [ 🍯 ] [ 🌻 ] [ 👤 ]
```

---

## 1.4 Zone-by-Zone Specs

### ① Top Banner Zone

Conditional — appears only when one of these is true. Z-order: anomaly > past-due > trial. Only one shown at a time.

| Banner | Color | Copy | Action |
|---|---|---|---|
| Trial 3 days left | `bees/honey/300` | "Trial ends in 3 days. Manage plan →" | Tap → S-YOU-10 |
| Trial 1 day left | `bees/amber/500` | "Trial ends tomorrow." | Tap → S-YOU-10 |
| Past-due payment | `bees/error/500` | "Payment failed. Update method to keep watching." | Tap → failed-payment recovery sheet |
| Anomaly recent | `bees/amber/500` | "Unusual activity detected. Tap to learn more." | Tap → opens stat detail with annotation pin |
| New designs | `bees/honey/100` | "New sticker designs are here. Have a look →" | Tap → S-HONEY-02 base design carousel |

**Behavior:**
- 44pt tall, edge-to-edge, system text + chevron right
- Dismissible per-session via swipe right (except past-due, persistent)
- Animates in from top with spring on first appear, fades out on dismiss

---

### ② Live Video Zone

**Component:** `VideoPlayerLive`

**Specs:**
- 220pt tall, full width, 16:9 letterboxed (black bars top/bottom if source aspect differs)
- AVPlayer wrapping HLS source URL
- Auto-plays on screen appear if app foregrounded; pauses on background
- Audio: muted by default unless user toggled in settings
- Reduce Data Usage system setting respected (drops to SD)

**Overlay controls** (auto-hide after 3s of no interaction, return on tap):

Top-left — `LIVE` indicator pill
- Red dot pulsing (1Hz, 0.6→1.0 opacity sine wave)
- "LIVE" text in 11pt SF Pro Medium uppercase
- Hidden during buffering — replaced with `BUFFERING` pill in `bees/charcoal/600`

Top-right — `Audio` and `Fullscreen` icon buttons
- Audio: speaker icon (muted state has slash). Tap toggles. Default state from setting `hive.audioDefault`.
- Fullscreen: expand-arrows icon. Tap → S-HIVE-02 (transition: `.matchedGeometryEffect` from inline frame to fullscreen, 350ms standard ease)

Bottom-left — Capture row (Forager+ only; locked icon for Pollinator)
- 📸 Screenshot — instant capture, saves to camera roll, toast "Saved to Photos" 2s
- 🎬 Record clip — opens S-HIVE-05 recorder with 30s rolling buffer pre-loaded
- 📤 Share — share sheet for current frame (screenshot inline)

Bottom-right — Camera angle picker (Forager+ only; hidden for Pollinator)
- Pill button "entrance ▼" — tap opens menu with: Entrance · Internal · Top-down
- Each option shows availability indicator (green dot = live, gray dot = offline)
- Selecting switches stream within 2s; loading shimmer over video during swap

**Interactions:**
- Single tap → toggle controls visibility
- Double tap → toggle audio mute
- Long press → pause + show frame timestamp
- Swipe down on player → minimize to floating PiP-style thumbnail (NO — confirmed no PiP in plan; remove this gesture)

**Performance budget:**
- First frame: ≤ 3s on cellular, ≤ 1.5s on Wi-Fi
- Buffer underrun rate: < 0.5% of viewing minutes

---

### ③ Hive Identity Pill

```
┌─────────────────────────────────────────────────┐
│  Buzzy McHive             ┌─THRIVING─┐          │
│  Sunny Acre · Sonoma, CA  └──────────┘          │
└─────────────────────────────────────────────────┘
```

**Layout:** 56pt tall, 16pt horizontal padding. Text stack on left, HealthPill on right.

**Text stack:**
- Hive name — `display/m` (24pt SF Serif Semibold), `bees/charcoal/900`. Truncate at 2 lines.
- Farm location — `caption/m` (13pt), `bees/charcoal/600`. Single line, truncate with ellipsis.

**HealthPill component:**
- Rounded rectangle, 24pt tall, horizontal padding 12pt
- Variants:
  - `THRIVING` — `bees/leaf/500` background, white text
  - `STEADY` — `bees/honey/500` background, charcoal text
  - `WATCH` — `bees/amber/500` background, white text
  - `ALERT` — `bees/error/500` background, white text
  - `DORMANT` — `bees/charcoal/300` background, charcoal text
  - `OFFLINE` — `bees/charcoal/300` background outline only, charcoal/600 text
- Tap → S-HIVE-04 health detail variant

**Tap behavior on the whole row:** opens hive detail / rename screen (S-OBD-08 reused for rename, accessible from settings).

---

### ④ Stat Strip

**Component:** Horizontal `ScrollView` of `StatTile` × 7.

**StatTile spec:**
- 88×88pt rounded square, `card` elevation
- Background: `bees/comb/500` (light) / dark variant
- Layout vertical:
  - Top: stat icon (16pt) + 2pt + value (mono, 17pt semibold)
  - Middle: unit label (caption/s)
  - Bottom: trend arrow (↗↘→) in `bees/leaf/500` / `bees/error/500` / `bees/charcoal/600`
- 12pt spacing between tiles
- Tap → S-HIVE-04 stat detail (stat-specific variant)

**The 7 tiles in fixed order:**
1. Temperature — `92°F`
2. Humidity — `64%`
3. Weight — `47 lb`
4. Population — `58k bees` (estimated)
5. Take-offs (rolling 24h) — `1,247`
6. Landings (rolling 24h) — `1,253`
7. Sound — qualitative tile: `Active / Calm / Quiet / Loud` (no number)

(Note: Take-offs and landings on the strip are rolling totals; the live counter card §⑤ shows real-time delta.)

**Health (qualitative)** — NOT in stat strip; lives in Hive Identity Pill as the HealthPill. Tap on pill leads to detail.

**Behavior:**
- Animates value changes with smooth tick (gentle 400ms) when new reading arrives
- Trend arrow updates every 5min based on rolling delta vs prior period
- Sensor-offline tile: value `—`, trend hidden, card greyed out, tap → "This sensor is offline" sheet with last reading timestamp

**Tier gating:** none — all tiers see all 7 tiles (refresh cadence is identical across tiers in v1; Queen Keeper's "priority lane" is a backend concern, not visible difference).

**Edge cases:**
- First-launch warm-up: tiles show skeleton shimmer for max 5s, then show first values OR "—" if backend slow
- Out-of-range value (sensor calibration drift): clamp to displayable range, show ⚠ badge on tile, tap explains
- Negative trend during dormancy: do not show ↘ alarm color; show flat → in muted gray (don't worry users about expected winter behavior)

---

### ⑤ Activity Counter Card

**Component:** `AnimatedCounter` wrapped in card.

```
┌───────────────────────────────────────────┐
│  🐝  ACTIVITY RIGHT NOW                   │
│                                           │
│     ↑ 1,247           ↓ 1,253             │
│     Take-offs         Landings            │
│                                           │
│  ▓▓▓▓▓▓░░░░░░░░░░ Last 60 seconds         │
└───────────────────────────────────────────┘
```

**Specs:**
- 124pt tall, 16pt margins, `lg(16pt)` corner radius
- Background: gradient subtle `bees/honey/100` → `bees/comb/500`
- Title: `caption/m` uppercase tracking, `bees/charcoal/600`
- Two large counters side by side, `mono/m` (15pt) with arrow glyph
- Counters: `display/l` (32pt SF Mono Semibold)
- Each counter animates tick-up smoothly when new bees observed
- Bottom: thin progress bar showing rolling 60s window fill

**Animation specs:**
- Counter tick: each integer change uses 250ms ease-out, digits flip via `.contentTransition(.numericText())`
- Arrow up/down briefly highlights `bees/leaf/500` / `bees/honey/500` on each tick (200ms flash)
- Reduce Motion: numbers update instantly, no flash

**Data source:**
- Server pushes a delta event roughly every 1–3s during active hours
- Client maintains 60s rolling window for the progress bar
- During dormancy: numbers update slowly (every minute or more); copy changes to "Quiet today — bees are resting."

**Tap behavior:** Tap card → S-HIVE-04 stat detail (combined takeoffs+landings view).

**Edge cases:**
- No activity for 5+ min during expected hours: show subtle "Hive is quiet right now" state with paused arrows
- Sensor offline: card becomes static with last known counts + "Updated {time}" footer; counters do not animate

---

### ⑥ Achievements Glance

**Conditional** — hidden if user has zero achievements.

```
┌─────────────────────────────────────────────────┐
│  🏆 ACHIEVEMENTS                  View all  →   │
│  ┌────┐ ┌────┐ ┌────┐                           │
│  │ 🥇 │ │ 🌱 │ │ 🍯 │                            │
│  │First│ │Spring│ │Sweet│                       │
│  │week │ │ wake │ │spot │                       │
│  └────┘ └────┘ └────┘                           │
└─────────────────────────────────────────────────┘
```

**Layout:**
- Section header: 96pt total, 16pt vertical padding
- Title row: `caption/m` uppercase + chevron CTA "View all"
- Badge row: 3 most recent earned badges, 80×96pt each
- AchievementBadge component with icon top, 2-line label below

**Tap badge** → S-YOU-05 detail.
**Tap "View all"** → S-YOU-04.

---

### ⑦ Time-Lapse Highlights Card

**Tier:** Forager+ only. Hidden for Pollinator.

```
┌─────────────────────────────────────────────────┐
│  ✨ YESTERDAY'S HIGHLIGHTS                      │
│  ┌─────────────────────────────────────────┐    │
│  │ [thumbnail]                  ▶  0:45    │    │
│  │ Heavy traffic at 11:42 AM               │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

**Specs:**
- Section header `caption/m` uppercase + sparkle icon
- Card: 148pt tall, full width minus 16pt margins
- Thumbnail: 16:9, dimmed 30% with play icon center
- Caption overlay bottom-left: 1-line title (e.g., "Heavy traffic at 11:42 AM")
- Duration pill bottom-right
- Tap → S-HIVE-08 time-lapse player (modal)

**States:**
- Generated: shows yesterday's reel
- Generating (early morning): "We're building today's highlights — check back at 7 AM" placeholder
- Insufficient activity: "Not much happened yesterday" friendly empty state with sleeping bee
- Queen Keeper variant: weekly recap row appears below the daily card

---

### ⑧ Harvest / Farm Event Card (situational)

**Trigger:** server-pushed event tied to user's farm. Examples:
- "Harvest day at Sunny Acre — your jar is being filled today!"
- "The farmer just ran an inspection — here's what they found."
- "Big bloom on the property — bees are loving it."

**Layout:**
- Full-width card, `bees/honey/300` accent border
- Photo / icon left, headline + body right
- Tap → S-FARM-01 with the event highlighted

**Lifecycle:**
- Surfaces for 24h then auto-hides
- Dismissible per-session via swipe

---

### ⑨ Quick Actions Row

```
┌──────────────┐  ┌──────────────┐
│ 📊 Full stats│  │ 🔄 Compare   │
└──────────────┘  └──────────────┘
```

**Layout:** 56pt tall, two equal `ButtonSecondary`. 12pt gap between.

**Buttons:**
- Full stats → S-HIVE-03
- Compare → S-HIVE-09 — only visible if `hive.comparisonEnabled` setting is on; when off, "Full stats" expands to full width

---

## 1.5 Hive State Variants — full visual specs

### Variant 1: Live & healthy (default)
Shown above. All zones populated.

### Variant 2: Live but partial — sensors offline (subset)

Only stat strip changes:
- Affected tiles: value `—`, greyed background, info icon
- Tap offline tile → bottom sheet: "This sensor is offline. Last reading: 47 lb at 8:32 AM. We're working on it." with "Email support" button

### Variant 3: Camera offline

```
┌─────────────────────────────────────────────────┐
│           ░░░░░░░░░░░░░░░░░░░░░░░░              │
│           ░░░ [comb illustration] ░░░           │
│           ░░░░░░░░░░░░░░░░░░░░░░░░              │
│                                                 │
│      We're checking on the camera               │
│      Most issues resolve within an hour.        │
│                                                 │
│   [ I need help ]    [ Email support ]          │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- Replaces Live Video Zone entirely
- Auto-polls camera status every 60s
- "I need help" → auto-creates support ticket with hive ID, camera ID, timestamp; toast "Ticket created — we'll email you"
- "Email support" → mail composer pre-filled with diagnostics
- Sensors continue to render normally below
- Top banner adds: "Camera offline — sensors still working"

### Variant 4: Sensors offline

Live video plays normally. Stat strip + activity counter both go offline visual.
Top banner: "Sensors offline — video still working"

### Variant 5: All offline

Both zones in offline state. Top of screen: prominent error banner + "Email support" CTA. Achievements + farm content still visible.

### Variant 6: Hive Emergency

**Full-takeover sheet** appears on Hive tab open until acknowledged. The Hive home itself is gated behind this sheet.

```
┌─────────────────────────────────────────────────┐
│                                                 │
│          [bee + comb illustration]              │
│                                                 │
│       Important update about your hive          │
│                                                 │
│   We've detected a serious issue with your      │
│   hive. Here's what happened: [details].        │
│                                                 │
│   We're so sorry. Choose how we make this       │
│   right:                                        │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  ✨ Get a new hive + 3 months free       │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  💸 Get a refund + a new hive            │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│           [ Maybe later ]                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- Cannot dismiss with swipe; must tap one of the three CTAs
- "Maybe later" defers; reappears in 24h
- Selecting either compensation path → S-OBD-07 hive assignment reveal flow (with new hive)
- Server-confirmed; user choice persists; no double-comp possible

### Variant 7: Winter Dormancy

```
┌─────────────────────────────────────────────────┐
│ ❄️ Winter mode                                  │
│ Your hive is in winter mode. Activity is        │
│ naturally low — bees cluster to keep the queen  │
│ warm. We'll be back to full buzz in spring.     │
│                                          [×]    │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- Card pinned just above stat strip from Nov 1 – Feb 28
- Dismissible per-session
- Activity counter still shows but with copy "Quiet today — bees are resting"
- Trend arrows neutral (gray →) regardless of direction
- Stat strip uses dampened color palette (cooler tones)

### Variant 8: Maintenance window

```
┌─────────────────────────────────────────────────┐
│           [farmer illustration]                 │
│                                                 │
│      Hive inspection happening now              │
│      Back online by 2:30 PM                     │
│                                                 │
│      Why? Farmers open hives weekly to          │
│      check the queen and look for issues.       │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- Replaces video zone
- Estimated end time pulled from farmer-scheduled window
- Sensors may also pause during this time (intentional, not error)
- Clears automatically at scheduled end time + 5 min buffer

### Variant 9: Sister Hive Override

**Trigger:** Primary hive in long-term outage; sister hive activated (Queen Keeper feature, on-demand per A.13).

```
┌─────────────────────────────────────────────────┐
│ 🐝 Watching your sister hive (Hive #92)         │
│ Your primary hive (Buzzy McHive) is being       │
│ tended to. Switch back when ready.              │
│                                                 │
│  [ Switch back to primary ]                     │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- All hive home content shows sister hive data
- Hive identity pill shows sister name + small "Sister hive" subtitle
- Achievements still belong to user (not specific to hive)
- Stat history shows sister's history during this period; primary's resumes when switched back

---

## 1.6 Scroll & Interaction Behaviors

### Scrolling
- Whole screen scrolls vertically except video zone (sticks to top while scrolling? — NO, the video scrolls with content; we don't sticky pin live video in v1)
- When scrolled past video, audio continues but visual is gone
- Scroll position preserved when switching tabs and returning

### Pull-to-refresh
- Standard iOS refresh control on scroll view
- Pulls latest readings + refreshes video stream
- Haptic feedback on commit (light)

### Tab re-tap behavior
- Tap Hive tab while already on Hive home → scroll to top + resume video if paused

### App lifecycle
- Background: video pauses, last frame stays
- Foreground after < 30s: resume from live (small jump if network okay)
- Foreground after > 30s: re-establish HLS connection from scratch
- App killed: cold start restores last viewed tab

---

## 1.7 Accessibility

| Element | Treatment |
|---|---|
| Live video | VoiceOver label: "Live video of {hive name}, {camera angle} camera." Caption with current frame description not feasible; defer to camera angle name. |
| Stat tiles | Each tile: "{stat name}, {value}, {unit}, trending {up/down/flat}." |
| Activity counter | Combined: "Activity right now: {takeoffs} take-offs, {landings} landings, last 60 seconds." |
| Health pill | "Hive health: {state}." Tap action announced. |
| Achievements glance | Each badge: "{title}, earned {date}." |
| Reduce Motion | Disables: counter tick animation (instant updates), pulsing LIVE dot (static), achievement confetti, jar rotation |
| Dynamic Type | All text labels respect system size; tiles grow vertically; layout reflows |
| Color contrast | All text ≥ 4.5:1; pills ≥ 3:1 for non-text |

---

## 1.8 SwiftUI implementation notes

```swift
// View structure (sketched)
struct HiveHomeView: View {
    @StateObject var viewModel: HiveHomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let banner = viewModel.topBanner { TopBannerView(banner) }
                LiveVideoZone(stream: viewModel.activeStream, tier: viewModel.tier)
                HiveIdentityPill(hive: viewModel.hive)
                StatStripView(stats: viewModel.stats)
                ActivityCounterCard(activity: viewModel.activity)
                if !viewModel.achievements.isEmpty {
                    AchievementsGlance(achievements: viewModel.achievements)
                }
                if viewModel.tier != .pollinator {
                    TimeLapseCard(reel: viewModel.dailyReel)
                }
                if let event = viewModel.farmEvent { FarmEventCard(event) }
                QuickActionsRow(comparisonEnabled: viewModel.comparisonEnabled)
            }
        }
        .refreshable { await viewModel.refresh() }
        .overlay {
            if let emergency = viewModel.emergency {
                HiveEmergencySheet(emergency)
                    .transition(.opacity)
            }
        }
    }
}
```

**Key considerations:**
- HLS player must be wrapped via `UIViewControllerRepresentable` since AVPlayer + SwiftUI on older iOS isn't seamless
- Animated counter uses `.contentTransition(.numericText())` (iOS 16+)
- LazyVStack — don't load achievements / time-lapse until they enter viewport
- Pull data from a single `@StateObject` view model; subscribe to a Combine pipeline of `HiveSnapshot` events from backend
- Cache last `HiveSnapshot` in SwiftData for offline open
- Banner stack uses a `BannerCoordinator` singleton with priority queue (anomaly > past-due > trial > info)

---

## 1.9 Telemetry

Events to fire (Amplitude / PostHog):
- `hive_home_viewed` { tier, hive_state, time_since_last_view_s }
- `live_video_started` { camera_angle, time_to_first_frame_ms }
- `live_video_buffer_underrun` { duration_ms }
- `stat_tile_tapped` { stat_id }
- `activity_counter_tapped`
- `camera_angle_switched` { from, to }
- `screenshot_captured`
- `clip_recorded` { duration_s }
- `paywall_triggered` { feature_id, tier }
- `health_pill_tapped` { state }
- `time_lapse_card_tapped`

---

# PART 2 — S-HONEY-02 Sticker Customizer

## 2.1 Purpose

The single most differentiated product moment. The user touches this every shipment cycle (monthly for Forager+, quarterly for Pollinator). Must:
- Feel delightful; the 3D jar render is the hero
- Make the design hierarchy obvious (base design → text → font → color)
- Validate text in real time (char count + content moderation)
- Make the lock-in mechanic clear without being scary
- Handle tier gating gracefully (Pollinator users shouldn't feel pestered with locked sections; just hide them)
- Recover gracefully from offline / submit failures

This screen also runs **during onboarding** (S-OBD-11) with slightly different chrome — that variant is documented at the end.

---

## 2.2 Variants Matrix

### Tier variants
| Element | Pollinator | Forager | Queen Keeper |
|---|---|---|---|
| Base design count | 8 | 8 | 8 + rotating exclusive |
| Custom text | ❌ | ✓ | ✓ |
| Font picker | ❌ | ✓ | ✓ |
| Color picker | ❌ | ✓ | ✓ |
| Save as favorite | ❌ | Up to 5 saved | Unlimited |
| Lock-in window | Same — 7 days before ship | Same | Same |

### Mode variants
1. **Editing** — default, all controls live
2. **Saved draft** — has saved candidate, can keep editing until lock-in date
3. **Locked (read-only)** — past lock-in date, all controls disabled, "Locked" badge shown
4. **Lock pending** — user tapped "Lock design" but server hasn't confirmed (≤2s window)
5. **Lock failed** — server moderation flagged or network failure
6. **Onboarding (mandatory)** — different chrome (no tab bar, "Continue" CTA), no skip allowed

### State variants (orthogonal to mode)
- Loading — fetching catalog + current draft
- Empty — first-ever design (no prior favorites, no current draft)
- Network offline — local edit allowed, sync deferred
- Submission error — text moderation flagged, network error, etc.

---

## 2.3 Anatomy & Layout

```
┌─────────────────────────────────────────────────┐
│ ① TOP BAR (44pt) — close · title · save · more │
├─────────────────────────────────────────────────┤
│ ② DEADLINE BANNER (40pt) — countdown            │
├─────────────────────────────────────────────────┤
│                                                 │
│ ③ 3D JAR PREVIEW (320pt)                        │
│   - rotating, pinch-to-rotate, sticker decal    │
│                                                 │
├─────────────────────────────────────────────────┤
│ ④ BASE DESIGN PICKER (140pt)                    │
│   - horizontal carousel of 8                    │
├─────────────────────────────────────────────────┤
│ ⑤ CUSTOM TEXT (variable, expandable)            │
│   - 3 line inputs, char counter                 │
│   - HIDDEN for Pollinator                       │
├─────────────────────────────────────────────────┤
│ ⑥ FONT PICKER (88pt) — Forager+                 │
├─────────────────────────────────────────────────┤
│ ⑦ COLOR PICKER (72pt) — Forager+                │
├─────────────────────────────────────────────────┤
│ ⑧ SAVE AS FAVORITE TOGGLE (56pt)                │
├─────────────────────────────────────────────────┤
│ extra padding                                   │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│ ⑨ STICKY FOOTER (88pt)                          │
│   ┌──────────────┐  ┌──────────────┐            │
│   │  Save draft  │  │ Lock design  │            │
│   └──────────────┘  └──────────────┘            │
└─────────────────────────────────────────────────┘
```

### ASCII wireframe — Forager tier, editing state

```
┌─────────────────────────────────────────────────┐
│ ✕   Customize sticker             Save     ⋯   │
├─────────────────────────────────────────────────┤
│ ⏰ Locks in 4 days · Ships May 18               │
├─────────────────────────────────────────────────┤
│                                                 │
│                ╭──────────────╮                 │
│                │ ░░░▓▓▓▓░░░░░ │                 │
│                │ ░▓▓▓▓▓▓▓▓▓░░ │                 │
│                │ ▓▓┌────────┐ │                 │
│                │ ▓▓│ Buzzy  │ │                 │
│                │ ▓▓│  Bee   │ │                 │
│                │ ▓▓│ ────── │ │                 │
│                │ ▓▓│Spring  │ │                 │
│                │ ▓▓│ 2026   │ │                 │
│                │ ▓▓└────────┘ │                 │
│                │ ░▓▓▓▓▓▓▓▓▓░░ │                 │
│                │ ░░░▓▓▓▓░░░░░ │                 │
│                ╰──────────────╯                 │
│                                                 │
│                ● ● ● ●                          │
├─────────────────────────────────────────────────┤
│  BASE DESIGN                          1 of 8    │
│                                                 │
│  ╭───╮ ╭───╮ ╭───╮ ╭───╮ ╭───╮       →        │
│  │ 1 │ │•2•│ │ 3 │ │ 4 │ │ 5 │                  │
│  ╰───╯ ╰───╯ ╰───╯ ╰───╯ ╰───╯                  │
│                                                 │
│  Floral · Selected                              │
├─────────────────────────────────────────────────┤
│  CUSTOM TEXT                                    │
│  ┌─────────────────────────────────────────┐    │
│  │ Buzzy Bee                               │    │
│  └─────────────────────────────────────────┘    │
│  Line 1 · 9/18                                  │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Spring 2026                             │    │
│  └─────────────────────────────────────────┘    │
│  Line 2 · 11/18                                 │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │                                         │    │
│  └─────────────────────────────────────────┘    │
│  Line 3 · optional                              │
├─────────────────────────────────────────────────┤
│  FONT                                           │
│  ╭──╮ ╭──╮ ╭──╮ ╭──╮ ╭──╮                      │
│  │Aa│ │•Aa•│ │Aa│ │Aa│ │Aa│                    │
│  ╰──╯ ╰──╯ ╰──╯ ╰──╯ ╰──╯                      │
│  Modern Sans · Selected                         │
├─────────────────────────────────────────────────┤
│  COLOR                                          │
│   ⚫️ ⚪️ 🟡●🟠 🌿 🌊                              │
│  Honey · Selected                               │
├─────────────────────────────────────────────────┤
│  ❤️ Save as favorite                       ◯    │
└─────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌──────────────────────┐     │
│  │  Save draft  │  │ Lock design (final)  │     │
│  └──────────────┘  └──────────────────────┘     │
└─────────────────────────────────────────────────┘
```

---

## 2.4 Zone-by-Zone Specs

### ① Top Bar

```
✕   Customize sticker             Save     ⋯
```

- 44pt tall, blurred material background (`.regularMaterial`)
- Left: ✕ close — tap dismisses with confirmation if dirty changes ("Discard changes? Your last saved draft is preserved.")
- Center title: "Customize sticker" `heading/m`
- Right: "Save" text button (saves draft, doesn't lock); enabled only when dirty. After save, briefly shows checkmark.
- Right-most: ⋯ overflow menu — options: Apply a saved favorite, Reset to last saved, Help with customization

### ② Deadline Banner

```
⏰ Locks in 4 days · Ships May 18
```

- 40pt tall, full width, `bees/honey/100` background
- Single line, `caption/m` charcoal/600, clock icon left
- Updates daily at midnight to current countdown
- Tappable: opens info sheet "What does locking mean?" with explanation:
  - "Once locked, your design is sent to print and can't be changed."
  - "If you don't lock manually, we'll lock it automatically 7 days before ship."
  - "If you don't customize at all, we'll use {fallback rule}."

**State variants:**
- 4+ days: blue/honey, friendly tone
- 3 days: amber tint, "Don't forget!"
- 1 day: red tint, "Last chance to customize"
- 0 days (today): "Locking today at 11:59 PM"
- Locked: replaced with "✓ Locked · Ships May 18"

### ③ 3D Jar Preview

**Component:** `Jar3DRender`

**Specs:**
- 320pt tall, full width
- Background: subtle radial gradient (warm cream)
- Jar model: glass jar with honey amber fill, sticker decal applied to front
- Auto-rotate at 4 RPM clockwise (subtle, hypnotic)
- User pinch-to-rotate manually; auto-rotate resumes after 4s of no interaction
- Pinch-to-zoom up to 1.5x for sticker detail
- Page indicator dots ●●●● show which face of the jar is forward (front/back/sides)

**Decal updates live:**
- Base design swap → 200ms cross-fade on decal texture
- Text edit → debounced 300ms, decal regenerates
- Font change → 200ms cross-fade
- Color change → instant tint via shader

**Tier note:**
- Pollinator: decal is just the base design (no text, no font/color)
- Forager+: decal is composed (base + text + font + color)

**Performance budget:**
- 60 fps interaction on iPhone 12+
- Decal regeneration: ≤ 100ms
- If 3D budget too tight for v1: fall back to 2D realistic mockup with sticker overlay (image composited from server-rendered preview)

**"Honey pour" animation hook (post-v1):**
- When user taps "Lock design", current pour animation: empty jar → honey pours in from above → settles → sticker appears with little sparkle. ~1.5s celebration.
- Reduce Motion: instant fade

### ④ Base Design Picker

```
BASE DESIGN                          1 of 8
╭───╮ ╭───╮ ╭───╮ ╭───╮ ╭───╮       →
│ 1 │ │•2•│ │ 3 │ │ 4 │ │ 5 │
╰───╯ ╰───╯ ╰───╯ ╰───╯ ╰───╯
Floral · Selected
```

**Layout:**
- Section header `caption/m` uppercase + page indicator "1 of 8"
- `CarouselSwipe` of 8 design thumbnails, 80×80pt each, 12pt gap, paged scroll
- Selected design has 2pt `bees/honey/500` border + bottom dot
- Below: design name + "Selected" status

**Interactions:**
- Swipe horizontally to browse
- Tap a thumbnail → selects + scrolls it to center → 3D jar updates
- Each thumbnail label is a curated name (Floral, Geometric, Vintage, Botanical, Minimalist, Hexagon, Watercolor, Letterpress) — these are placeholder; final names from designer

**Tier:**
- Queen Keeper: 9th tile shown with "Exclusive · {Month}" gold border for the current rotating exclusive design
- Pollinator: same 8 designs, but tapping outside Pollinator-included designs no-ops (currently all 8 included for all tiers — exclusive is QK extra)

### ⑤ Custom Text

**Hidden for Pollinator.** For Pollinator, the section is replaced by a small note: "Custom text and design options come with Forager. Upgrade →" leading to S-SYS-09 paywall.

**For Forager+:**

```
CUSTOM TEXT
┌─────────────────────────────────────────┐
│ Buzzy Bee                               │
└─────────────────────────────────────────┘
Line 1 · 9/18

┌─────────────────────────────────────────┐
│ Spring 2026                             │
└─────────────────────────────────────────┘
Line 2 · 11/18

┌─────────────────────────────────────────┐
│                                         │
└─────────────────────────────────────────┘
Line 3 · optional
```

**Layout:**
- 3 separate `TextFieldPrimary` inputs
- Each: 44pt tall, full width, rounded (md), comb-cream background
- Below each: char counter "{n}/18" + status label
- Status label states:
  - Default: "Line {n}" (line 1 required, lines 2–3 optional)
  - Approaching limit (15+ chars): counter turns amber
  - At limit: counter red, prevents further input
  - Validation issue: red outline + message "{reason}"

**Validation rules (real-time, client side):**
- Length: ≤ 18 chars per line, ≤ 48 total
- Allowed characters: A–Z, a–z, 0–9, space, `' . , ! & -`
- Disallowed (blocked at input): emoji, special chars, line breaks
- Pattern blocks (regex on submit, not real-time):
  - Phone numbers: `\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b`
  - Email: `[^@\s]+@[^@\s]+\.[^@\s]+`
  - URLs: `https?://`, `www\.`, `\.com\b`, etc.
  - Address-like: 5-digit zip near street suffix
- On submit / lock: server-side moderation pass (profanity, slurs, hate). If flagged, returns reason → user sees error sheet (§2.5 step 4)

**Behavior:**
- Tapping a field opens keyboard, scrolls field to center
- Smart capitalization: word-initial caps suggested
- Autocorrect: enabled but reduced (turn off aggressive corrections)
- "Done" key on keyboard advances to next line; on line 3 dismisses keyboard

**Note for Pollinator paywall message:**
Show the 3 line slots as visually visible (greyed) with a transparent overlay that blurs them; tap → S-SYS-09 paywall.

### ⑥ Font Picker

**Forager+ only. Hidden for Pollinator.**

```
FONT
╭──╮ ╭──╮ ╭──╮ ╭──╮ ╭──╮
│Aa│ │•Aa•│ │Aa│ │Aa│ │Aa│
╰──╯ ╰──╯ ╰──╯ ╰──╯ ╰──╯
Modern Sans · Selected
```

**Layout:**
- 5 fonts, 56×56pt swatches in a row
- Each shows "Aa" rendered in that font
- Selected has dot indicator + 2pt border
- Below: font name + "Selected"

**Fonts (placeholder; designer to finalize):**
1. Modern Sans
2. Classic Serif
3. Handwritten Script
4. Vintage Bold
5. Minimal Mono

**Interaction:** Tap → 3D jar updates with new font on decal in 200ms.

### ⑦ Color Picker

**Forager+ only. Hidden for Pollinator.**

```
COLOR
 ⚫️ ⚪️ 🟡●🟠 🌿 🌊
Honey · Selected
```

**Layout:**
- 6 color circles, 40pt diameter, 16pt gap
- Each is a flat fill swatch
- Selected has `bees/charcoal/900` ring outline + dot above
- Color name label below

**Colors (placeholder; designer to finalize):**
1. Charcoal (default for high contrast)
2. Cream
3. Honey (signature)
4. Burnt Orange
5. Sage
6. Ocean

**Interaction:** Tap → instant tint update on decal via shader (no regeneration needed).

### ⑧ Save as Favorite Toggle

```
❤️ Save as favorite                       ◯
```

**Layout:**
- 56pt row, full width
- Heart icon + label left, switch right
- Tap label or switch toggles

**Behavior:**
- Toggling on → expanded sub-row appears: "Name your favorite" text input (16 char max)
- Hidden for Pollinator (favorites are tier feature)
- Limit: Forager 5 saved, Queen Keeper unlimited
- If at Forager limit: toggle attempt → sheet "You've saved 5 designs. Replace one or upgrade."
- Saving as favorite happens on lock-in OR on explicit "Save" tap

### ⑨ Sticky Footer

```
┌──────────────┐  ┌──────────────────────┐
│  Save draft  │  │ Lock design (final)  │
└──────────────┘  └──────────────────────┘
```

**Layout:**
- 88pt tall, sticky to bottom safe area
- Material blur background
- Two buttons, 12pt gap, 16pt outer padding
- "Save draft" — `ButtonSecondary`, 40% width
- "Lock design (final)" — `ButtonPrimary`, 60% width

**Save draft behavior:**
- Persists current state as candidate design
- Stays editable until automatic lock-in
- Shows checkmark + "Saved" toast (2s)
- Disabled if no changes since last save

**Lock design behavior (irreversible):**
- Tap → `AlertDialog`:
  - "Lock this design?"
  - "Once locked, your design is final. We can't change it after this."
  - "Lock it in" (destructive style) / "Not yet"
- Confirm → submission state (button shows spinner) → server validation → server moderation → on success: lock confetti + transition to read-only mode + "Saved" toast
- On moderation fail: error sheet (§2.5)
- On network fail: retry option, design stays in draft

---

## 2.5 Mode & state walk-through

### Mode 1 — Editing (default)
All zones interactive. Footer shows both buttons. Save draft is enabled when state is dirty.

### Mode 2 — Saved draft
Visually identical to editing. Indicator: top bar Save button shows checkmark briefly after save. Re-edit allowed.

### Mode 3 — Locked (read-only)

```
┌─────────────────────────────────────────────────┐
│ ✕   Your locked design                       ⋯  │
├─────────────────────────────────────────────────┤
│ ✓ Locked · Ships May 18                         │
├─────────────────────────────────────────────────┤
│                                                 │
│             [3D jar — final design]             │
│                                                 │
├─────────────────────────────────────────────────┤
│  BASE DESIGN                                    │
│  Floral                                         │
├─────────────────────────────────────────────────┤
│  CUSTOM TEXT                                    │
│  Line 1: Buzzy Bee                              │
│  Line 2: Spring 2026                            │
├─────────────────────────────────────────────────┤
│  FONT                                           │
│  Modern Sans                                    │
├─────────────────────────────────────────────────┤
│  COLOR                                          │
│  Honey                                          │
├─────────────────────────────────────────────────┤
│ Save this as a favorite for next time → ❤️       │
└─────────────────────────────────────────────────┘
[ Apply this design to next shipment ]
```

- All interactive controls replaced with read-only summary
- 3D jar still rotates (or shows honey-pour animation on first view post-lock)
- Footer: single button "Apply this design to next shipment" (creates draft for next cycle pre-populated)

### Mode 4 — Lock pending
- Lock button shows spinner, disabled
- Other controls disabled
- Top bar shows "Locking..."
- 2s budget; if longer, show "Almost there..."

### Mode 5 — Lock failed (moderation flagged)

```
┌─────────────────────────────────────────────────┐
│              [warning illustration]             │
│                                                 │
│      We can't print that text                   │
│                                                 │
│      Our review found something we can't        │
│      print on a jar. Try a different word       │
│      or phrase.                                 │
│                                                 │
│      What we flagged: "{snippet}"               │
│                                                 │
│         [ Edit my text ]                        │
│         [ Email support ]                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Behavior:**
- Bottom sheet, 60% height
- Shows specific flagged content (or just a generic message if too sensitive to repeat)
- "Edit my text" → returns to editing mode with the affected line highlighted
- "Email support" → mail composer for appeal
- Design is NOT locked; user can keep editing

### Mode 6 — Lock failed (network)
- Toast: "Couldn't reach server. Try again."
- Design stays in editing mode, as draft
- Auto-retry on next lock attempt; draft persists

### Mode 7 — Onboarding variant (S-OBD-11)

Differences from default:
- No tab bar at bottom
- Top bar: title "Customize your first sticker", no ✕ close (must complete)
- Deadline banner replaced with: "Your first jar ships {date}. Make it yours."
- Custom text (Forager+) marked optional but encouraged: "Skip text or add a name"
- Sticky footer: single CTA "Continue" (saves draft, advances to S-OBD-12 payment)
- No "Lock design" button — user designs but doesn't lock during onboarding (lock-in happens at standard 7-day-before-ship rule)
- "Save as favorite" toggle hidden (no concept of favorites yet)

---

## 2.6 Edge cases

| Scenario | Behavior |
|---|---|
| User opens customizer while offline | Local edits allowed, top banner "Offline — your changes save when you're back" |
| User tries to lock while offline | Disabled with explanation tooltip |
| User backgrounds app mid-edit | State auto-persists locally; restores on return |
| User's tier downgrades mid-cycle | If draft has Forager+ features (text, font, color), warn: "Your design will print without custom text after the current cycle. Lock now to keep it for this jar." |
| User reaches Forager favorites limit | Toggle prompts "Replace one of your saved 5?" with list to swap |
| Time runs out (auto-lock) | Server applies last saved draft; user gets push: "Your sticker locked in! Here's what we're printing." |
| No draft saved at auto-lock | Apply last shipment's design; if no prior shipment, apply tier-default sticker (predefined per tier) |
| Server moderation flags but user appeals successfully | Support manually unlocks; design pushed to print |
| User wants to change after lock | Disclosure: "Locked designs can't change. Want help? Email support." Some emergencies (typo on name) → support can manually re-lock if before print queue starts |
| User tries to add prohibited text | Real-time warning + counter goes red. Submit blocks. |
| Pollinator user sees locked sections | Sections rendered greyed with transparent overlay + small "Forager unlocks this" tag; tap → S-SYS-09 paywall (single sheet, not multiple per section) |

---

## 2.7 Accessibility

| Element | Treatment |
|---|---|
| 3D jar preview | VoiceOver: "Sticker preview. Currently showing {design name}, {custom text}, in {font}, {color}. Double-tap to inspect details." Hint: "Pinch to rotate manually." |
| Design carousel | Each thumbnail: "{Design name}. {Selected/Not selected}. {n} of 8." Swipe directly between thumbnails using VoiceOver gestures. |
| Text inputs | Standard text field labels with explicit "Line 1, line 2, line 3". Char count announced as user types. |
| Font picker | Each font swatch: "{Font name}. {Selected/Not selected}." |
| Color picker | Each color: "{Color name} swatch. {Selected/Not selected}." |
| Save toggle | Standard switch role. |
| Lock button | "Lock design. Final, can't be changed after." |
| Reduce Motion | 3D jar stops auto-rotating; honey-pour animation becomes instant fade; carousel snaps without spring |
| Dynamic Type | All sections grow vertically; controls remain tap-friendly at largest sizes |
| Color contrast | Selected indicators don't rely on color alone (always include border + dot) |
| Keyboard | Hardware keyboard support: tab between fields; cmd-S saves draft |

---

## 2.8 SwiftUI implementation notes

```swift
struct StickerCustomizerView: View {
    @StateObject var viewModel: StickerCustomizerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CustomizerTopBar(
                isDirty: viewModel.isDirty,
                onClose: viewModel.handleClose,
                onSave: viewModel.saveDraft
            )
            DeadlineBanner(state: viewModel.deadlineState)
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    Jar3DPreview(design: viewModel.composedDesign)
                        .frame(height: 320)
                    
                    BaseDesignPicker(
                        designs: viewModel.designs,
                        selected: $viewModel.selectedBaseDesign
                    )
                    
                    if viewModel.tier.canCustomizeText {
                        CustomTextSection(
                            line1: $viewModel.line1,
                            line2: $viewModel.line2,
                            line3: $viewModel.line3,
                            validation: viewModel.textValidation
                        )
                    } else {
                        PaywallTeaser(feature: .customText)
                    }
                    
                    if viewModel.tier.canPickFont {
                        FontPicker(selected: $viewModel.selectedFont)
                    }
                    
                    if viewModel.tier.canPickColor {
                        ColorPicker(selected: $viewModel.selectedColor)
                    }
                    
                    if viewModel.tier.canSaveFavorites {
                        FavoriteToggle(
                            saving: $viewModel.saveAsFavorite,
                            name: $viewModel.favoriteName
                        )
                    }
                }
                .padding(16)
                .padding(.bottom, 88) // for sticky footer
            }
            
            CustomizerFooter(
                onSaveDraft: viewModel.saveDraft,
                onLock: viewModel.requestLock,
                isLocked: viewModel.mode == .locked,
                isPending: viewModel.mode == .lockPending
            )
        }
        .alert("Lock this design?", isPresented: $viewModel.showLockConfirm) {
            Button("Lock it in", role: .destructive, action: viewModel.confirmLock)
            Button("Not yet", role: .cancel) { }
        } message: {
            Text("Once locked, your design is final. We can't change it after this.")
        }
        .sheet(isPresented: $viewModel.showModerationError) {
            ModerationErrorSheet(reason: viewModel.moderationReason)
        }
    }
}

// View model handles:
// - Debounced text validation (300ms)
// - Server moderation submission
// - Lock state machine (editing → pending → locked / failed)
// - Persistence of draft to local storage + server
// - Composed design assembly for jar preview
```

**Key considerations:**
- **3D rendering:** SceneKit with a single jar geometry, sticker as image texture on a curved decal mesh. Decal updates via texture replacement. Pre-baked lighting; no live shadows in v1.
- **Decal composition:** Use Core Graphics or Metal-based image composer to generate sticker preview image from base design + text + font + color. Cache the composed image; regenerate only when inputs change.
- **Text validation pipeline:** Local synchronous (length + allowed chars) → debounced 300ms regex (PII patterns) → on lock submit, server moderation API call.
- **State persistence:** SwiftData model `StickerDraft` with all fields; auto-save on every change debounced 1s. Sync to server every 30s when online.
- **Lock state machine:** `editing → pending → locked` happy path; `editing → pending → editing` on failure (with error context). Pending is a UI lock, not a logical commit.

---

## 2.9 Telemetry

- `customizer_opened` { mode: editing|locked|onboarding, tier }
- `base_design_selected` { design_id, from, to }
- `custom_text_edited` { line, length }
- `font_selected` { font_id }
- `color_selected` { color_id }
- `favorite_saved` { name_set: bool }
- `draft_saved` { auto: bool }
- `lock_requested`
- `lock_succeeded` { time_in_customizer_s }
- `lock_failed` { reason: moderation|network|other }
- `moderation_flagged` { line, reason_category }
- `paywall_triggered_from_customizer` { feature_id }
- `customizer_dismissed` { dirty: bool, mode }

---

## 2.10 Acceptance criteria for both screens

### Hive Home
- [ ] All 9 hive state variants render correctly with appropriate copy
- [ ] All 3 tier variants gate the right features
- [ ] Live video achieves ≤3s first-frame on cellular
- [ ] Animated counter ticks at 60fps
- [ ] Stat tiles update on push within 1s of server message
- [ ] Pull-to-refresh re-establishes stream + refreshes stats
- [ ] Tab re-tap scrolls to top + resumes video
- [ ] All accessibility labels in place; VoiceOver tour completes screen
- [ ] Reduce Motion disables all animation
- [ ] Hive Emergency variant blocks dismissal until choice made
- [ ] Camera offline state offers help + auto-creates ticket
- [ ] Banner z-order respects priority

### Sticker Customizer
- [ ] All 3 tier variants render correct controls (Pollinator hides text/font/color)
- [ ] All 7 mode states render correctly
- [ ] 3D jar updates within 200ms of any input change
- [ ] Text validation blocks PII and disallowed chars in real time
- [ ] Server moderation pipeline tested with profanity, hate, addresses
- [ ] Lock confirmation prevents accidental locks
- [ ] Lock failure recovers with editable draft preserved
- [ ] Auto-lock at deadline tested (server-driven)
- [ ] Onboarding variant cannot be skipped
- [ ] Read-only mode disables all controls but allows viewing
- [ ] Favorites limit (5 for Forager) enforced with replacement flow
- [ ] Offline edits persist and sync on reconnect
- [ ] All accessibility labels in place
- [ ] Reduce Motion disables jar rotation + honey-pour
- [ ] Performance: 60fps interaction maintained on iPhone 12+

---

**End of deep wireframes.**

Next risk areas worth deep-speccing if you want them:
- **S-OBD-07 Hive Assignment Reveal** (animation-heavy emotional moment, single chance to make first impression)
- **S-YOU-13 Cancel Subscription** (legal-sensitive, retention-critical, multi-step flow)
- **S-GIFT-02 to S-GIFT-07 Gift flow end-to-end** (most complex multi-screen flow with branching)
