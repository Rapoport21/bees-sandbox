# Bees iOS — Master Plan & Wireframe Specification

**Version:** 1.0
**Date:** 2026-05-05
**Owner:** Nick Rapoport
**Status:** Ready for design + iOS engineering kickoff

---

## 0. Locked Decisions Recap

### Product
- iOS only at launch (push Apple Watch to later phase)
- US only at launch — start with **California + Texas**, expand to OR/WA/NY/NC/FL
- Hive auto-assigned (map view exists as dev toggle for future feature)
- Multiple farms; user cannot pick yet (toggle exists for later)

### Subscription
| | **Pollinator** | **Forager** | **Queen Keeper** |
|---|---|---|---|
| Price | $14.99/mo • $149/yr | $24.99/mo • $249/yr | $49.99/mo • $499/yr |
| Jars | 1 / 3 months | 1 / month | 2 / month |
| Cameras | Entrance only | All 3 angles | All 3 + early access |
| Sticker | 8 designs, no text | + Custom text + font + color | + Exclusive seasonal designs |
| Saved sticker favorites | – | 5 | Unlimited |
| Time-lapse highlights | – | Daily | Daily + weekly recap |
| Clips & screenshots | – | ✓ | ✓ |
| Hive comparison | ✓ | ✓ | ✓ |
| Gift jar | – | ✓ | ✓ |
| Gift subscription | – | – | ✓ |
| Painted hive name | – | – | Opt-in (free, can decline) |
| Sister hive failover | – | – | On-demand (seasonal/issues) |
| Annual bonus harvest jar | – | – | ✓ |
| Priority support | – | – | ✓ |
| Weekly digest email | – | ✓ | ✓ |

- **Trial:** 7 days free, all tiers. If canceled inside trial, no jar ships AND user loses video access immediately at trial end (not on cancel — they keep access through day 7).
- **Cancel anytime.** Cancel = lose video access immediately. Final shipment does NOT ship. Disclosed clearly during retention flow.
- **Hive collapse compensation:** offer BOTH options — 3 months free service OR refund equivalent — user picks.
- **Buy extra jars:** fixed unit price (e.g., $15/jar) regardless of tier.
- **Referral reward:** 1 free month for each side (referrer + referee).

### UX
- 4-tab bottom nav: **Hive · Honey · Farm · You**
- Soft-wall demo before signup (real anonymized 24h-delayed hive feed)
- Onboarding tutorial with dev toggle for show/hide during development
- First sticker customization is **mandatory** during onboarding (no skip, no fallback during signup)
- 3D jar render for sticker preview
- Note for later: empty-jar → animated honey-pour when design is finalized
- Custom font + color invested in v1 sticker customizer
- Personal achievements + gamification, no social feed
- Subtle social sharing (achievements, clips)
- Granular notifications, anomaly alerts default-off

### Tech
- Apple In-App Purchase for subscriptions (Apple Pay preferred), Stripe for one-off physical purchases (extra jars, gift orders to non-subscribers)
- Live video: HLS via on-farm camera
- Sensor refresh: stats every 30s, derived metrics every 60s, qualitative health every 5min
- All-time historical sensor data stored per user

---

## 1. Information Architecture

```
App Root
├── Auth Stack (modal full-screen, no tabs visible)
│   ├── Splash
│   ├── Value carousel
│   ├── Demo hive viewer
│   ├── Soft signup sheet
│   ├── Auth picker → Apple / Google / Email flows
│   └── Onboarding stack (post-auth)
│       ├── Tier comparison
│       ├── Tutorial (4 cards, dev-toggleable)
│       ├── Hive assignment reveal
│       ├── Hive naming
│       ├── Address collection
│       ├── First sticker customization (mandatory)
│       ├── Payment + trial start
│       └── Welcome → drop into Hive tab
│
└── Main App (tab bar always visible)
    ├── Hive tab
    │   ├── Hive home (default)
    │   ├── Live video fullscreen (modal)
    │   ├── Stats dashboard (push)
    │   ├── Stat detail (push, 7 variants)
    │   ├── Historical chart (push)
    │   ├── Time-lapse highlights (modal)
    │   ├── Saved clips library (push)
    │   ├── Hive comparison (push, gated by setting)
    │   └── Sister hive intro (modal, situational)
    │
    ├── Honey tab
    │   ├── Honey home
    │   ├── Sticker customizer (modal full-screen)
    │   ├── Saved stickers (push)
    │   ├── Shipment detail (push)
    │   ├── Shipment history (push)
    │   ├── Past shipment detail (push)
    │   ├── Buy extra jars (modal)
    │   ├── Skip / pause shipment (sheet)
    │   ├── Damage / lost claim (modal)
    │   └── Gift flow (modal full-screen)
    │       ├── Gift type
    │       ├── Recipient info
    │       ├── Sticker customization
    │       ├── Message / digital card
    │       ├── Packaging
    │       ├── Review & pay
    │       └── Confirmation
    │
    ├── Farm tab
    │   ├── Farm profile home
    │   ├── Photo gallery (modal)
    │   ├── Farmer bio (push)
    │   └── Farm map (push, single pin v1)
    │
    └── You tab
        ├── Profile home
        ├── Achievements overview (push)
        ├── Achievement detail (modal)
        ├── Hive history (push)
        ├── Subscription (push)
        ├── Switch tier (modal)
        ├── Cancel subscription (modal full-screen)
        ├── Billing history (push)
        ├── Payment methods (push)
        ├── Promo / referral (push)
        └── Settings (push, hierarchical)
            ├── Notifications
            ├── Display
            ├── Hive settings
            ├── Tutorial
            ├── Addresses
            ├── Account
            ├── Help & Support
            ├── Legal
            └── About
```

### Modal Hierarchy Rules
- Tab bar visible: all tab content + push navigation
- Tab bar hidden: fullscreen video, sticker customizer, gift flow, cancel flow, onboarding
- Sheet (50% / 90%): retention offers, share sheets, paywalls, system permission asks
- Banner: trial countdown, failed payment, anomaly alerts (top of any tab)

### Deep Linking (v1)
- `bees://hive` → Hive tab
- `bees://hive/stat/{statId}` → stat detail
- `bees://honey/customize` → sticker customizer for current shipment
- `bees://honey/shipment/{id}` → shipment detail
- `bees://gift/claim/{token}` → gift recipient claim flow
- `bees://farm` → farm profile
- `bees://settings/{path}` → specific setting
- `bees://referral/{code}` → signup with referral

---

## 2. Navigation Spec

### Stack Behavior
- **Tab switches** preserve nested stack state (return to where you were)
- **Push** within tab uses default iOS animation
- **Modal** dismisses with swipe-down (non-blocking) or X button (blocking)
- **Fullscreen modal** for irreversible flows (sticker lock, payment, cancel)
- **Back gesture** disabled during: payment processing, sticker lock-in submission, video upload of clip

### Critical Tab Behavior
- Tap Hive tab while already on Hive home → scroll to top, resume live video if paused
- Tap Honey tab while already on Honey → if customizer is open, do nothing; else scroll to top
- Tap any tab during onboarding → no-op (tabs not shown until welcome complete)

### Required System Sheets
- Push notification permission — deferred to **after first stat tile tap**, not on first launch
- Camera roll permission — only when first saving clip/screenshot
- Apple Pay sheet — system, not custom

### App-State Triggers (banners over tabs)
- Trial ending (3 days left): blue banner above tab content, dismissible per session
- Failed payment: red banner above tab content, persistent until resolved
- Hive emergency: red full-takeover sheet on Hive tab open
- New badge earned: confetti overlay (animated, dismisses to Achievements)
- New sticker designs available: yellow banner on Honey tab only
- Network offline: gray banner top of screen, auto-dismiss when back online

---

## 3. Design System Foundations

### Color Tokens
| Token | Hex (placeholder) | Usage |
|---|---|---|
| `bees/honey/500` | `#F5A623` | Primary action, CTA |
| `bees/honey/300` | `#FFD089` | Highlights, badges |
| `bees/honey/100` | `#FFF4DC` | Backgrounds (light) |
| `bees/charcoal/900` | `#1A1614` | Primary text |
| `bees/charcoal/600` | `#5C5550` | Secondary text |
| `bees/charcoal/300` | `#B8B0A8` | Tertiary, disabled |
| `bees/comb/500` | `#E8E0D0` | Card backgrounds |
| `bees/leaf/500` | `#5C8A3C` | Success, thriving health |
| `bees/amber/500` | `#D97706` | Watch state, attention |
| `bees/error/500` | `#C0392B` | Error, hive emergency |

Dark mode mirrors with adjusted luminance. Honey-yellow stays warm in both modes.

### Typography
| Token | Font | Weight | Size | Use |
|---|---|---|---|---|
| `display/xl` | New York / SF Serif | Bold | 40 | Hero (hive name, jar reveal) |
| `display/l` | New York | Semibold | 32 | Screen titles |
| `heading/l` | SF Pro | Semibold | 24 | Section headers |
| `heading/m` | SF Pro | Semibold | 20 | Card titles |
| `body/l` | SF Pro | Regular | 17 | Default body |
| `body/m` | SF Pro | Regular | 15 | Secondary |
| `caption/m` | SF Pro | Regular | 13 | Labels |
| `caption/s` | SF Pro | Medium | 11 | Tiny labels (timestamps, badges) |
| `mono/m` | SF Mono | Regular | 15 | Stat values |

Use serif for emotional moments (hive name, achievement titles). Use SF Pro for everything else. Stat values in monospace so digits don't jitter.

### Spacing
4pt grid. Tokens: `xxs(4) · xs(8) · s(12) · m(16) · l(24) · xl(32) · xxl(48)`.

### Corner Radius
`sm(8) · md(12) · lg(16) · xl(24) · pill(999)`.

### Elevation
Soft shadows, very subtle. `card(0 1 2 rgba(0,0,0,0.04))`, `floating(0 4 12 rgba(0,0,0,0.08))`. No heavy shadows.

### Motion
- `quick(150ms ease-out)` — taps, toggles
- `standard(250ms ease-in-out)` — push, sheets
- `gentle(400ms ease-in-out)` — animated counters, jar previews
- `celebration(800ms spring)` — achievements, jar reveal
- Reduce Motion respected: counters become static, celebrations become fades

---

## 4. Shared Component Library

These are referenced by screen specs below. Each is built once.

### Cards
- **`StatTile`** — icon, label, value (animated), trend arrow. Used across Hive home, widgets.
- **`ShipmentCard`** — thumbnail of jar render, status badge, ship date / delivery date, CTA.
- **`AchievementBadge`** — icon, title, earned date, locked state.
- **`HiveSummaryCard`** — hive name, farm name, hero image, qualitative health pill.
- **`FarmCard`** — farm image, name, distance label.
- **`AlertCard`** — icon, headline, body, dismiss / action buttons. Used for anomaly, emergency.

### Inputs
- **`TextFieldPrimary`** — single-line input with floating label, error state.
- **`TextFieldMultiline`** — multi-line with character counter (used in sticker text).
- **`AddressInput`** — full address form with autocomplete and verification.
- **`CarouselSwipe`** — horizontal pageable, used for sticker designs, value props, photo galleries.
- **`ColorSwatchRow`** — horizontal row of color circles with selected state.
- **`FontPicker`** — horizontal row of font samples ("Aa") with selected state.
- **`SegmentedControl`** — iOS-native, used for time ranges on charts.

### Buttons
- **`ButtonPrimary`** — honey-filled, white text, full-width on key screens.
- **`ButtonSecondary`** — bordered, charcoal text.
- **`ButtonGhost`** — text-only with optional icon.
- **`ButtonDestructive`** — red, used for cancel/delete confirms.
- **`IconButton`** — tap target ≥44pt, icon only.
- **`FAB`** — floating action button, used for "Adopt your hive" on demo viewer.

### Headers / Bars
- **`NavBarStandard`** — title, optional left back, optional right action.
- **`NavBarLarge`** — large title that collapses on scroll (used on tab home screens).
- **`NavBarTransparent`** — used over hero imagery (Hive home, Farm profile).
- **`TabBar`** — 4 tabs, badge dot capability per tab.
- **`Banner`** — top-anchored, color variants (info, warning, error, success).

### Sheets / Modals
- **`BottomSheet`** — 50% or auto-height, drag-to-dismiss.
- **`FullScreenModal`** — used for customizer, gift, cancel flows.
- **`AlertDialog`** — system-style confirm.
- **`PaywallSheet`** — used when user taps locked feature.

### Media
- **`VideoPlayerLive`** — HLS player with audio toggle, quality selector, fullscreen, AirPlay.
- **`VideoPlayerClip`** — for saved clips and time-lapses.
- **`Jar3DRender`** — 3D jar with sticker decal, rotatable. Stub in v1 if budget; use 2D realistic mockup as fallback.
- **`SkeletonLoader`** — shimmer placeholder for any data-loaded screen.

### Charts
- **`StatChart`** — line chart with annotations (events), time-range selector, tooltip on tap. Used for all 7 stats.
- **`ComparisonChart`** — your hive vs anonymized peers, used in comparison view.

### Specials
- **`AnimatedCounter`** — for takeoffs/landings, smooth tick-up animation.
- **`HealthPill`** — qualitative state pill with color (Thriving / Steady / Watch / Alert).
- **`HiveAvatar`** — circular hive identity with name overlay, used in profile + Watch.
- **`Confetti`** — for achievement moments.

---

## 5. Data Model (sketch for engineering)

```
User
  id, email, name, authProvider, createdAt
  tier: enum (Pollinator, Forager, QueenKeeper)
  trialEndsAt, subscriptionStatus, nextBillingDate
  primaryAddress: Address
  savedAddresses: [Address]
  hiveId
  notificationPrefs: NotificationPreferences
  displayPrefs: DisplayPreferences
  hiveSettings: HiveSettings (comparison, audio default, etc.)
  achievements: [AchievementProgress]
  referralCode, referrals: [Referral]

Hive
  id, farmId, hiveNumber, hiveName (user-set, optional)
  paintedNameStatus: enum (notRequested, pending, painted, declined)
  cameras: [Camera]  // entrance, internal, top-down
  sensors: [Sensor]  // temp, humidity, weight, sound
  derivedMetrics: { population, takeoffs, landings, healthQualitative }
  status: enum (active, dormant, emergency, collapsed, maintenance)
  lifetimeStats: { weightGained, daysActive, harvestsObserved, ... }

Farm
  id, name, location, story, farmer: { name, bio, photo }
  photos: [Photo]
  hives: [Hive]

Camera
  id, hiveId, angle: enum, hlsUrl, audioAvailable, status

Sensor
  id, hiveId, type: enum, currentValue, history: [Reading]

Shipment
  id, userId, type: enum (regular, gift, extraJars, bonus)
  jarCount, status: enum (pending, locked, preparing, shipped, delivered, lost, claimed)
  scheduledShipDate, lockInDate, shippedAt, deliveredAt
  trackingCarrier, trackingNumber
  sticker: StickerDesign
  address: Address
  giftDetails?: GiftDetails

StickerDesign
  id, baseDesignId
  customText: { line1, line2, line3 }
  font: enum, color: enum
  preview3DUrl

GiftDetails
  recipientName, recipientEmail, recipientAddress
  message, packagingTier
  giftType: enum (jar, subscription)
  redemptionToken, redeemedAt

Achievement
  id, type: enum, title, description, icon, criteria
  rarity: enum (common, rare, epic, legendary)

AchievementProgress
  achievementId, userId, progress, earnedAt

Notification (server-pushed log)
  id, userId, type, sentAt, readAt, payload
```

---

## 6. Screen Specifications

Each screen has a stable ID. Format: `S-{section}-{number}`. Sections: `AUTH`, `OBD` (onboarding), `HIVE`, `HONEY`, `GIFT`, `FARM`, `YOU`, `SET` (settings), `SYS` (system / cross-cutting).

### 6.1 Pre-auth & onboarding

#### S-AUTH-01 Splash
- **Purpose:** Brand impression on cold start.
- **Layout:** Full screen logo, animated bee fade-in.
- **Components:** Logo, single-line tagline ("Your hive. Your honey.").
- **States:** loading (always); auto-advances after 1.2s or when bootstrap complete.
- **Transitions:** Fade to S-AUTH-02 on first launch, or to last tab if returning user.

#### S-AUTH-02 Value Carousel
- **Purpose:** 30-second pitch.
- **Layout:** 3-card horizontal `CarouselSwipe`, page indicator dots, persistent bottom CTA.
- **Cards:**
  1. **Live video** — looped 5s of bees, headline "Watch your hive 24/7."
  2. **Real stats** — animated stat tiles, headline "See exactly how it's doing."
  3. **Your honey jar** — 3D jar render, headline "Your custom honey, shipped to your door."
- **CTAs:** `ButtonPrimary` "Adopt your hive" → S-AUTH-04. `ButtonGhost` "See a demo first" → S-AUTH-03. Skip link "Already a member? Sign in" → S-AUTH-04.
- **States:** static.

#### S-AUTH-03 Demo Hive Viewer
- **Purpose:** Prove value before signup. Convert.
- **Layout:** Full-bleed VideoPlayerLive (top 60%) with curated 24h-delayed simulated stream. Bottom 40%: stat tiles (simulated). Persistent FAB "Adopt your own hive" bottom-right. Soft floating banner after 45s: "Loving it? Get your own hive →"
- **Components:** VideoPlayerLive, StatTile × 4, FAB, dismissible bottom banner.
- **Interactions:**
  - Tap any locked feature (stat detail, customize, share) → S-AUTH-06 (soft signup sheet)
  - Tap FAB → S-AUTH-04
  - Swipe down / X → back to S-AUTH-02
- **States:** playing, paused, simulated content always available.

#### S-AUTH-04 Auth Method Picker
- **Purpose:** Sign up or sign in.
- **Layout:** Centered logo top, three buttons stacked: Sign in with Apple (primary), Continue with Google, Continue with Email. Bottom: small "Already have an account? Sign in" toggle (if in signup mode it switches copy; same flows under the hood).
- **Components:** ButtonPrimary, ButtonSecondary × 2, ButtonGhost.
- **Interactions:**
  - Apple → system Apple sign-in sheet → on success → S-OBD-01 (first time) or last tab (returning)
  - Google → Google sign-in flow → same routing
  - Email → S-AUTH-05
  - Forgot password → S-AUTH-07
- **States:** idle, loading (auth in progress), error (auth failed → toast).

#### S-AUTH-05 Email Signup / Signin
- **Purpose:** Email + password auth.
- **Layout:** Email field, password field, primary button, "Forgot password?" link, switch to Sign In / Sign Up toggle.
- **Components:** TextFieldPrimary × 2, ButtonPrimary, ButtonGhost.
- **Validation:** Email format, password ≥ 8 chars + 1 number, real-time inline errors.
- **Interactions:**
  - Submit signup → backend → email verification sent → S-AUTH-06b (verification waiting)
  - Submit signin → S-OBD-01 if new account else last tab
- **States:** idle, validating, submitting, error.

#### S-AUTH-06 Soft Signup Sheet
- **Purpose:** Convert demo viewers.
- **Layout:** Bottom sheet 60% height. Headline "Sign in to unlock", subhead "It only takes 30 seconds." Same 3 auth methods as S-AUTH-04. Dismissible.
- **Behavior:** Triggered from S-AUTH-03 when locked feature tapped.

#### S-AUTH-06b Email Verification Waiting
- **Purpose:** Tell user to check email.
- **Layout:** Big mail icon, headline "Check your email", body "We sent a verification link to {email}", Resend link (rate-limited), Change email link → back to S-AUTH-05.
- **Behavior:** Polls for verification every 5s; auto-advances to S-OBD-01 on success.

#### S-AUTH-07 Forgot Password
- **Purpose:** Reset flow start.
- **Layout:** Email field, ButtonPrimary "Send reset link", confirmation toast on submit.

#### S-AUTH-08 Password Reset (deep link)
- **Purpose:** Set new password from email link.
- **Layout:** New password field, confirm field, ButtonPrimary.

#### S-OBD-01 Tier Comparison
- **Purpose:** Pick tier.
- **Layout:** Top: title "Choose your hive plan". Three vertical cards (or horizontal scroll), each showing tier name + price + key features. "Most popular" tag on Forager. Bottom CTA disabled until selected. Footnote: "7-day free trial included."
- **Components:** Tier card × 3, ButtonPrimary, fine-print legal.
- **Interactions:** Tap card → selects + scrolls feature list → CTA enables → tap CTA → S-OBD-02.
- **States:** none-selected, one-selected, loading.

#### S-OBD-02 Tier Confirmation
- **Purpose:** One-screen recap of choice.
- **Layout:** Big tier icon, "You picked Forager", price, key benefits as bullets, "Start free trial" button, "Change plan" link → S-OBD-01.
- **Interactions:** CTA → S-OBD-03.

#### S-OBD-03 to S-OBD-06 Tutorial cards (skippable, dev toggle)
- **Cards:** What is a hive · How the cameras work · What the stats mean · Your honey & stickers
- **Layout:** Each: hero illustration, headline, 2-3 bullet body, "Next" button, "Skip tutorial" link top-right.
- **Behavior:** Skippable to S-OBD-07. Dev toggle in settings replays this anytime.

#### S-OBD-07 Hive Assignment Reveal
- **Purpose:** Emotional moment — meet your hive.
- **Layout:** Animated bee swarm coalesces into hive image. Title "Meet your hive." Subhead "Hive #47 at Sunny Acre Farm, Sonoma CA." Tap-to-continue → S-OBD-08. Gentle ambient sound (skippable / mutable).
- **Animation:** ~2s, must respect Reduce Motion.

#### S-OBD-08 Hive Naming
- **Purpose:** Personalize.
- **Layout:** Hive image as backdrop, large input "Name your hive", char limit 24, suggested names below ("Buzzy", "The Queen's Court", "Hive 47"), "Skip" link uses default ("Hive #47"), CTA "Continue".

#### S-OBD-09 Address Entry
- **Purpose:** Capture shipping address.
- **Layout:** Form with name (autofill from auth), street, apt, city, state (dropdown — only supported states), zip. Auto-suggest as user types. CTA "Continue" → address validation API → S-OBD-10 if uncertain, else S-OBD-11.
- **Edge case:** State not in supported list → block with friendly message + waitlist email capture, allow "Choose a different address."

#### S-OBD-10 Address Verification
- **Purpose:** Confirm corrected address.
- **Layout:** Two cards: "What you entered" vs "Suggested correction (USPS)". Radio, CTA "Use this address".

#### S-OBD-11 First Sticker Customization
- **Purpose:** Mandatory first design. Sets habit.
- **Layout:** Same as S-HONEY-02 (sticker customizer) but with onboarding chrome and "This will go on your first jar" subhead. Cannot skip. Lock-in defers until 7 days before first ship date.
- **Behavior:** Must select base design + (Forager+) text/font/color → CTA "Continue" → S-OBD-12.

#### S-OBD-12 Payment + Trial Start
- **Purpose:** Capture payment, start 7-day trial.
- **Layout:** Recap: tier, trial dates, first charge date. Apple Pay button (primary), card option. Tax + total disclosure. Promo code expandable input. Legal copy.
- **Interactions:** Apple Pay → system sheet → success → S-OBD-13. Card → form. Promo → validate → recalc total.

#### S-OBD-13 Welcome Confirmation
- **Purpose:** Celebrate. Set expectations.
- **Layout:** Confetti animation. Headline "Welcome, {name}!" Body "Your hive is ready. Your trial ends {date}. Your first jar ships {date}." Single CTA "See my hive" → S-HIVE-01.

---

### 6.2 Hive Tab

#### S-HIVE-01 Hive Home
- **Purpose:** Default screen. Hub.
- **Layout:**
  - **Top 50%:** VideoPlayerLive (entrance cam by default, or only available cam for Pollinator). Tap → fullscreen S-HIVE-02. Camera angle picker pill (Forager+).
  - **Sticky pill bar** below video: hive name + farm + qualitative HealthPill.
  - **Stat strip:** horizontal scroll of StatTile × 7 (temp, humidity, weight, population, takeoffs, landings, sound). Tap → S-HIVE-04 stat detail.
  - **AnimatedCounter** card: live takeoffs/landings counter ticking up. Tappable → opens detail.
  - **Achievements glance** card: latest 1–3 badges + "View all" → S-YOU-04.
  - **Time-lapse highlight card** (Forager+): yesterday's recap, tap → S-HIVE-08.
  - **Quick actions row:** Save clip · Screenshot · Share · Compare (if enabled).
- **States:**
  - Live (default): video playing, all stats fresh
  - Paused (user pause): freeze frame
  - Camera offline: VideoPlayerLive shows S-HIVE-15 placeholder
  - Sensors partial: affected tiles show "—" with tap → "sensor offline" sheet
  - Sensors all offline: full S-HIVE-16
  - Hive emergency: full takeover S-HIVE-17
  - Winter dormancy: explainer card pinned at top S-HIVE-18
  - First load: skeleton
  - No internet: cached snapshot + offline banner
- **Tier gating:**
  - Camera angle picker hidden for Pollinator
  - Save clip / screenshot disabled for Pollinator (paywall S-SYS-09 on tap)
  - Comparison hidden if setting off

#### S-HIVE-02 Live Video Fullscreen
- **Purpose:** Distraction-free viewing.
- **Layout:** Edge-to-edge video. Floating overlay (auto-hides after 3s, returns on tap):
  - Top: X close, audio toggle, AirPlay, share
  - Bottom: camera angle picker (gated), quality selector (gated), record clip button, screenshot button
- **Interactions:**
  - X / swipe down → S-HIVE-01
  - Audio toggle → mute/unmute (default off)
  - Record → S-HIVE-05
  - Screenshot → captures + saves to camera roll → toast confirmation
  - Camera angle pill → switches stream
- **States:** playing, paused, buffering, offline, AirPlaying.

#### S-HIVE-03 Stats Dashboard (full)
- **Purpose:** All stats in one scrollable view.
- **Layout:** Hive header pill (name + health), then 7 expanded stat cards each showing current value + sparkline (last 24h) + trend label. Tap any card → S-HIVE-04.
- **Components:** StatTile (large variant), sparkline mini-chart.
- **States:** loading, success, partial offline.

#### S-HIVE-04 Stat Detail (template, 7 variants)
- **Purpose:** Deep-dive into one stat.
- **Layout:**
  - Hero: stat name, current value (large), trend label
  - SegmentedControl: 1h / 24h / 7d / 30d / Season / Lifetime
  - StatChart with annotation pins (events)
  - Tap pin → S-HIVE-06 annotation detail
  - Educational section: "What is {metric}? How is it measured?" expandable
  - Comparison toggle (if setting on): overlay anonymized peer hive line
- **Variants:** Temperature · Humidity · Weight · Population · Takeoffs · Landings · Sound activity · Health (qualitative — different layout: shows current pill + history of state changes as timeline rather than chart)
- **States:** loading, success, sensor offline (chart greyed + "Last reading {time}"), no data yet (pre-onboarding state, very brief).

#### S-HIVE-05 Clip Recorder
- **Purpose:** Save a short live clip.
- **Layout:** Large red record button bottom center, timer top, max 60s clip length. Auto-saves 30s before tap (rolling buffer) so user catches what they just saw. Stop button → preview.
- **Tier:** Forager+. Pollinator gets paywall.

#### S-HIVE-05b Clip Preview
- **Purpose:** Confirm and save / share.
- **Layout:** VideoPlayerClip, save button, share button (sheet), discard button.

#### S-HIVE-07 Saved Clips Library
- **Purpose:** Browse past saved clips.
- **Layout:** Grid of thumbnails with timestamp + duration. Tap → S-HIVE-07b detail. Empty state: "No clips yet. Catch a moment from your hive!"
- **Bulk actions:** select to delete, share multiple.

#### S-HIVE-07b Clip Detail
- **Layout:** VideoPlayerClip top, metadata (recorded date, length, camera angle), share, delete.

#### S-HIVE-08 Time-Lapse Highlights
- **Purpose:** Auto-curated daily recap.
- **Layout:** VideoPlayerClip with auto-generated 30-60s reel. Caption strip at bottom with timestamps of "what happened" (e.g., "Heaviest activity 11:42 AM"). Share button. Calendar selector for previous days.
- **Tier:** Forager+.

#### S-HIVE-09 Hive Comparison
- **Purpose:** See how your hive ranks (anonymized).
- **Layout:** Toggle off by default in settings. When on:
  - Header: "Your hive vs the farm"
  - ComparisonChart: your line + farm avg line + (optional) all-platform median line
  - Stat selector: which metric to compare
  - "Where you rank": percentile callout ("Top 22% in honey weight gained")
- **Privacy note:** all peer data anonymized. Disclosed in a footer.
- **Behavior:** Hidden if setting off.

#### S-HIVE-10 Sister Hive Intro (situational)
- **Purpose:** Onboard user to a sister hive (Queen Keeper feature, or post-collapse).
- **Trigger:** Server-side activation. Shows on Hive tab open.
- **Layout:** Calm explainer card. Headline "Meet your sister hive." Body explains why (seasonal, primary in maintenance, etc.). CTA "View sister hive" → switches active hive context. "Keep watching primary" returns to S-HIVE-01.

#### S-HIVE-15 Camera Offline State
- **Purpose:** Communicate problem, offer help.
- **Layout:** Static placeholder image of comb, headline "We're checking on the camera", body "We've alerted the team. Most issues resolve within an hour." Two buttons: "I need help" → auto-creates support ticket with hive ID + camera ID. "Email support" → opens mail composer pre-filled.
- **Behavior:** Auto-refreshes every 60s. Banner clears when stream returns.

#### S-HIVE-16 Sensors Offline State
- **Purpose:** Same as camera, for sensors.
- **Layout:** Stat tiles greyed out with "—" values + "Last reading: {time}". Banner top: "Some sensors are offline. We're on it."

#### S-HIVE-17 Hive Emergency
- **Purpose:** Communicate serious event (queen loss, swarm, collapse).
- **Layout:** Full takeover. Headline "Important update about your hive." Body explains event in plain language. Two buttons: "Get a new hive (3 months free)" or "Get a refund and a new hive." Decline button → "Maybe later" defers (re-prompts in 24h). Email confirmation sent.
- **Per A.13:** Always offer both options.

#### S-HIVE-18 Winter Dormancy Explainer
- **Purpose:** Reassure user during low activity months.
- **Layout:** Card pinned to top of S-HIVE-01. "Your hive is in winter mode. Activity is naturally low. Bees cluster to keep the queen warm." Dismissible per session.

---

### 6.3 Honey Tab

#### S-HONEY-01 Honey Home
- **Purpose:** Status of jars + entry to customizer.
- **Layout:**
  - **Hero:** Current shipment card. Big jar render (S-HONEY-04 preview) + status badge (Customize / Locked / Preparing / Shipped / Delivered) + countdown ("Locks in 4 days" / "Ships in 12 days" / "Arrives in 3 days").
  - Primary CTA depends on state:
    - Pre-lock: "Customize sticker" → S-HONEY-02
    - Locked: "View design" (read-only)
    - Shipped: "Track" → S-HONEY-09
  - **Secondary cards:**
    - Saved stickers shortcut → S-HONEY-07
    - Buy extra jars → S-HONEY-12
    - Send a gift → S-GIFT-01
    - Shipment history shortcut → S-HONEY-10
  - Skip / pause shipment row → S-HONEY-15
- **States:** pre-lock, locked, preparing, shipped, delivered, paused, no-active-shipment (between cycles).
- **Tier gating:** Send a gift hidden for Pollinator → paywall.

#### S-HONEY-02 Sticker Customizer (full-screen modal)
- **Purpose:** Design the sticker.
- **Layout (single screen, scrollable):**
  - **3D jar preview** top, rotates slowly (auto), pinch to rotate manually. Updates live as user changes design.
  - **Section 1: Base design** — `CarouselSwipe` of 8 designs. Pollinator: tap to select, no further customization. Forager+: continues to section 2.
  - **Section 2: Custom text** (Forager+) — TextFieldMultiline, 3 lines × 18 chars, live counter. Validation: blocks PII patterns.
  - **Section 3: Font** (Forager+) — `FontPicker` row of 5 fonts.
  - **Section 4: Color** (Forager+) — `ColorSwatchRow` of 6 colors.
  - **Section 5: Save as favorite** — toggle. If on, prompts for nickname.
  - **Sticky bottom bar:** "Lock-in deadline: {date}", primary CTA "Save design" (saves draft, doesn't lock yet) and secondary "Lock in design" (commits early, can't change).
- **Save vs Lock distinction:**
  - **Save**: persists design as the candidate, can keep editing until automatic lock-in deadline.
  - **Lock**: commits immediately and finalizes (can't edit). User can lock early if they're confident.
- **Note for later:** when locked, trigger the "honey pour" animation (empty jar fills with honey) on next view.
- **States:** editing, validating text, saving, locked (read-only mode shows same screen with all inputs disabled and "Locked" badge).

#### S-HONEY-03 Sticker Customizer — Onboarding Variant
- Same as S-HONEY-02 but with onboarding chrome (no tabs, "Continue" CTA, no skip).

#### S-HONEY-04 Sticker Locked (read-only viewer)
- Read-only S-HONEY-02 with disabled controls and timeline showing "Locks {date}", "Ships {date}", "Delivers {est date}".

#### S-HONEY-07 Saved Stickers / Favorites
- **Purpose:** Browse and reuse past designs.
- **Layout:** Grid of jar thumbnails (saved favorites + past shipment designs). Tap → S-HONEY-08 apply or view.
- **Tier:** Forager (5 max), Queen Keeper (unlimited). Pollinator: hidden.

#### S-HONEY-08 Apply Favorite
- **Purpose:** Reuse a saved design for current shipment.
- **Layout:** Sheet with design preview, "Apply to next shipment" button, "Delete favorite", "Edit a copy" → opens S-HONEY-02 pre-filled.

#### S-HONEY-09 Shipment Status Detail
- **Purpose:** Track in-flight shipment.
- **Layout:**
  - Big jar preview at top
  - Status timeline (Preparing → Shipped → In transit → Out for delivery → Delivered) with current state highlighted
  - Tracking number + carrier + "Open in {Carrier}" link → external
  - Address recap
  - Edit address button (allowed until lock-in date)
  - "Something wrong?" → S-HONEY-17 claim flow
- **States:** preparing, shipped, out for delivery, delivered, delayed, lost.

#### S-HONEY-10 Shipment History List
- **Purpose:** Past shipments.
- **Layout:** Vertical list. Each row: jar thumbnail, ship date, sticker title, status badge. Tap → S-HONEY-11.

#### S-HONEY-11 Past Shipment Detail
- **Purpose:** Nostalgia + reorder.
- **Layout:** Big jar render, shipment metadata, sticker design recap, "Reorder this design" CTA → opens S-HONEY-12 (buy extra jars) pre-filled with this sticker.

#### S-HONEY-12 Buy Extra Jars
- **Purpose:** One-off purchase.
- **Layout:** Quantity stepper (1–6), per-jar price ($15 fixed), running total, sticker assign section ("Use my last design" / "Pick a saved" / "Customize new"), shipping address (default + change), Apple Pay / card.
- **Backend:** Stripe (not IAP — physical good).
- **States:** building, payment, processing, success.

#### S-HONEY-15 Skip / Pause Shipment
- **Purpose:** Vacation skip.
- **Layout:** Sheet. Two options: Skip next (one shipment) · Pause for X months (1, 2, 3). Disclosure: jars not shipped during pause are forfeited (or pushed depending on tier — engineering decision, recommend forfeited for simplicity). Confirm button.
- **Limits:** Skip max 2x per year, pause max 3 months per year. Enforced server-side.

#### S-HONEY-17 Damage / Lost Claim
- **Purpose:** File a claim.
- **Layout (multi-step):**
  - Step 1: Issue type (damaged / lost / wrong sticker / other)
  - Step 2: Description (TextFieldMultiline)
  - Step 3: Photos (up to 4, optional)
  - Step 4: Resolution preference (replacement / refund)
  - Step 5: Submit
- **Confirmation screen** with claim ID, expected resolution time (3 business days), "Track claim" link → S-HONEY-18.

#### S-HONEY-18 Claim Status
- **Layout:** Status timeline (Submitted → Reviewing → Resolved), notes from support, replacement shipment link if applicable.

---

### 6.4 Gift Flow (entry from Honey)

#### S-GIFT-01 Gift Launchpad
- **Purpose:** Pick gift type.
- **Layout:** Two big cards: "Send a jar of honey" (Forager+) · "Gift a subscription" (Queen Keeper only — paywall otherwise). Each card shows what's included.

#### S-GIFT-02 Recipient Info
- **Layout:** Form: recipient name, email (for digital card delivery), shipping address. Validation. CTA "Continue".

#### S-GIFT-03 Gift Sticker Customization
- **Layout:** Same as S-HONEY-02 but designs scoped to "Gift" category (could include "Happy Birthday", "Thank you" themes). Custom text encouraged.

#### S-GIFT-04 Gift Message / Digital Card
- **Layout:** Card style picker (3 styles), message TextFieldMultiline (200 chars), preview card render. CTA "Continue".

#### S-GIFT-05 Packaging Upgrade
- **Layout:** Standard ($0) vs Premium gift box ($X). Image + description for each. Skippable.

#### S-GIFT-06 Review & Pay
- **Layout:** Recap: recipient, sticker preview, message preview, packaging, total. Apple Pay primary, card option.

#### S-GIFT-07 Gift Confirmation
- **Layout:** Confetti. "{Recipient name} will get an email when their honey ships." Buttons: "Send another" · "Done".

#### S-GIFT-08 Gift Status Tracking
- **Layout:** Same as shipment detail but for gift. Shows recipient claim status (if subscription gift): "Recipient hasn't claimed account yet" → reminder button.

#### S-GIFT-09 Gift History (sent gifts)
- **Layout:** List in You tab → "Gifts sent". Tap → S-GIFT-08.

#### S-GIFT-10 Gift Recipient Claim Flow (deep link)
- **Trigger:** Recipient receives email with link, opens app via deep link.
- **Layout:** "{Gifter name} sent you {a jar / a subscription}!" → animated card reveal → CTA "Claim your gift" → goes through abbreviated S-AUTH-04 → S-OBD-07 (skips tier comparison if pre-paid, skips first sticker if gifter customized) → drops into Hive tab.

---

### 6.5 Farm Tab

#### S-FARM-01 Farm Profile Home
- **Purpose:** Connect user to farm.
- **Layout:**
  - Cover photo (full-bleed, parallax)
  - Farm name + location pill
  - Farmer card: photo + name + bio preview + "Read more" → S-FARM-03
  - Story section: paragraphs about the farm, beekeeping practices
  - Photo gallery preview row → S-FARM-02
  - Map preview → S-FARM-04
  - Note for later: content feed placeholder, visit form placeholder
- **States:** loading, success, no-content (empty placeholder).

#### S-FARM-02 Photo Gallery
- **Layout:** Grid of farm photos. Tap → fullscreen viewer with swipe.

#### S-FARM-03 Farmer Bio Detail
- **Layout:** Full bio, photo, years beekeeping, philosophy.

#### S-FARM-04 Farm Map
- **Layout:** MapKit map with single farm pin. Tap pin → callout with farm name, address, "Get directions" link (external Maps).
- **Future:** multi-hive cluster, user's hive highlighted.

---

### 6.6 You Tab

#### S-YOU-01 Profile Home
- **Purpose:** Hub for account, achievements, settings.
- **Layout:**
  - Header: avatar (initials, no photo for v1), name, hive name, tier badge
  - Achievements glance: 3 latest badges + "View all" → S-YOU-04
  - Streaks card: current streak count (e.g., "12 days")
  - Menu list:
    - Subscription → S-YOU-10
    - Achievements → S-YOU-04
    - Hive history → S-YOU-08
    - Gifts sent → S-GIFT-09
    - Referral program → S-YOU-15
    - Settings → S-SET-01
    - Help & Support → S-SET-22
- **States:** static.

#### S-YOU-02 Edit Profile
- **Layout:** Name field. Save button. Email shown but edit elsewhere (S-SET-19).

#### S-YOU-04 Achievements Overview
- **Purpose:** Show progress.
- **Layout:**
  - Tabs/segments: All · Earned · Locked
  - Grid of AchievementBadge components (locked ones greyed)
  - Tap → S-YOU-05 detail
- **States:** loading, success.

#### S-YOU-05 Achievement Detail
- **Purpose:** Celebrate or motivate.
- **Layout:** Big icon, title, description, "How to earn" criteria, earned date (if earned), share button (generates social card).

#### S-YOU-06 Achievement Earned Animation
- **Trigger:** Background event detection.
- **Layout:** Full-screen overlay: confetti, badge icon zooms in, title + body. Buttons: "Share" (generates card) · "Continue". Auto-dismisses after 8s if untouched.

#### S-YOU-08 Hive History
- **Purpose:** Cumulative stats and milestones.
- **Layout:** Big number cards: Days as adopter · Total weight gained · Total bees observed · Seasons survived · Honey jars received. Below: timeline of major events (joined, first jar, anomalies, harvests).

#### S-YOU-10 Subscription Home
- **Layout:**
  - Current tier badge
  - Status: Trial / Active / Past due / Paused / Canceled
  - Next bill date + amount
  - Switch tier button → S-YOU-11
  - Pause subscription button → S-HONEY-15 variant (full-cycle pause)
  - Cancel subscription button → S-YOU-13

#### S-YOU-11 Switch Tier
- **Layout:** Same as S-OBD-01 with current tier highlighted. Show proration delta clearly. CTA "Confirm" → S-YOU-12.

#### S-YOU-12 Switch Tier Confirmation
- **Layout:**
  - Upgrade: confirmation + immediate access
  - Downgrade: discloses what's lost + effective date (next cycle)

#### S-YOU-13 Cancel Subscription Flow (full-screen modal)
- **Step 1: Reason picker** — 6 options (too expensive, not using, hive issues, moving, life change, other).
- **Step 2: Retention 1 — Discount** — "Stay 50% off for 2 months?" Accept → applied → exits flow. Decline → step 3.
- **Step 3: Retention 2 — Pause** — "Pause for 1–3 months instead?" Accept → pause. Decline → step 4.
- **Step 4: Retention 3 — Downgrade** — "Try Pollinator at $14.99 instead?" Accept → downgrade. Decline → step 5.
- **Step 5: Disclosure** — clear list:
  - "You'll lose live video access immediately."
  - "Your final shipment will not ship."
  - "You'll keep your achievements and shipment history."
  - "You can re-subscribe anytime."
- **Step 6: Final confirm** — type "CANCEL" or tap-and-hold confirm.
- **Step 7: Confirmation** — "Subscription canceled. We'll miss you." Re-subscribe link.

#### S-YOU-14 Reactivate / Re-subscribe
- **Trigger:** Canceled user opens app.
- **Layout:** "Welcome back." Last tier pre-selected. Show last hive availability ("We saved {hive name} for 30 days — still available!" or "{hive name} has a new adopter, but here's a similar one"). CTA "Reactivate".

#### S-YOU-15 Referral Program
- **Layout:**
  - Hero: "Give a free month, get a free month."
  - Your referral code (tap to copy)
  - Share button → share sheet with deep link
  - Stats: invites sent, accepted, free months earned
  - Terms (collapsible)

#### S-YOU-16 Billing History
- **Layout:** List of charges, each: date, amount, status, "View receipt" → S-YOU-17.

#### S-YOU-17 Billing Receipt
- **Layout:** Itemized receipt, download/email PDF option.

#### S-YOU-18 Payment Methods
- **Layout:** List (Apple Pay default, cards). Add / remove. For IAP subscriptions, points to App Store settings.

---

### 6.7 Settings

Settings is hierarchical. Most rows are simple toggles or pickers. Listed compactly.

#### S-SET-01 Settings Home
- Notifications · Display · Hive · Tutorial · Addresses · Account · Help & Support · Legal · About
- Sign out at bottom (destructive style)

#### S-SET-02 Notifications
Toggles per category (defaults from §0):
- Sticker reminders
- Shipment events
- Trial events
- Failed payment
- Hive anomaly (off)
- Weekly hive digest
- New sticker designs (off)
- Achievements (off)
- Harvest day at your farm
- Marketing (off)

Master "Push notifications" toggle that opens iOS Settings app to manage system-level.

#### S-SET-03 Display
- Theme: System / Light / Dark
- Temperature: Auto / °F / °C
- Weight: Auto / lb / kg

#### S-SET-04 Hive Settings
- Hive comparison: off / on
- Show map of available hives (dev): off / on
- Multi-hive (dev): off / on
- Audio default on stream: off / on
- Default video quality: Auto / SD / HD
- Live Activity for hive activity: off / on

#### S-SET-05 Tutorial
- Replay tutorial (S-OBD-03 to S-OBD-06)
- Show tutorial on launch (dev): off / on

#### S-SET-06 Addresses
- Primary shipping (edit)
- Saved addresses (add / remove / set default)

#### S-SET-19 Account
- Name (edit)
- Email (change → re-verification flow)
- Password (change → re-auth required)
- Connected logins (Apple/Google/Email — link / unlink)
- Privacy & data
  - Download my data → email export
  - Marketing opt-in toggle
- Delete account → S-SET-20

#### S-SET-20 Delete Account
- **Step 1:** Disclosure: 30-day grace period explained, what's deleted vs retained (financial records).
- **Step 2:** If subscription active → must complete S-YOU-13 cancel flow first.
- **Step 3:** Type "DELETE" to confirm.
- **Step 4:** Email sent. Logged out.

#### S-SET-21 Restore Account (during 30-day grace)
- **Trigger:** User signs in within 30 days.
- **Layout:** "Welcome back. Restore your account?" Restore / Permanently delete now buttons.

#### S-SET-22 Help & Support
- FAQ → S-SET-23
- Contact support → opens mail composer pre-filled with user ID + tier + hive ID
- Report a problem → S-HIVE-15-style auto-ticket

#### S-SET-23 to S-SET-25 FAQ
- FAQ home: search + categories
- Category list: articles
- Article detail: rendered markdown content

#### S-SET-26 Legal
- Terms of Service viewer (rendered markdown)
- Privacy Policy viewer

#### S-SET-27 About
- Version, build, credits, "Made with bees in mind."

---

### 6.8 Cross-cutting / System

#### S-SYS-01 to S-SYS-06 State screens
- App update required gate
- Maintenance mode (server-driven, blocks app)
- Network offline banner (top)
- Generic error sheet
- Permission denied (camera roll / push)
- Trial ending banner (top)
- Failed payment banner

#### S-SYS-07 Push Permission Prompt
- **Trigger:** After first stat tile interaction.
- **Layout:** Bottom sheet. Pre-prompt explainer ("We'll only ping you for things you actually want — sticker deadlines, shipping, your hive."). Buttons: "Sure" → triggers iOS prompt · "Not now".

#### S-SYS-08 Permission Re-prompt (deferred)
- If user said no, show explainer card on Honey home: "Turn on notifications so you don't miss your shipment." Tap → opens iOS Settings.

#### S-SYS-09 Paywall Sheet
- **Trigger:** Tap on locked feature.
- **Layout:** 75% sheet. "{Feature} is part of {Tier}". Bullet of what unlocks. CTA "Upgrade" → S-YOU-11. Dismiss.

#### S-SYS-10 Share Sheet
- iOS native share sheet, used for clips, screenshots, achievements, referral code.

#### S-SYS-11 App Store Rating Prompt
- Trigger: First jar delivered + 3 days, OR first achievement earned + 1 week. Use SKStoreReviewController, max 3x/year per Apple rules.

---

## 7. Notification Spec (final)

| Event | Push | Email | In-app | Default |
|---|---|---|---|---|
| Sticker lock-in 14d / 7d / 3d / 1d | ✓ | – | banner | on |
| Sticker locked / fallback applied | ✓ | – | – | on |
| Shipment shipped | ✓ | ✓ | – | on |
| Shipment delivered | ✓ | ✓ | – | on |
| Trial ending 3d | ✓ | ✓ | banner | on |
| Trial converted | – | ✓ | – | on |
| Failed payment | ✓ | ✓ | banner | on |
| Hive anomaly | ✓ | – | annotation pin | off |
| Camera offline > 1h | ✓ | – | state | off |
| Sensors offline > 1h | ✓ | – | state | off |
| Hive emergency | ✓ | ✓ | full takeover | always on |
| Achievement earned | ✓ | – | confetti | off |
| New sticker designs available | ✓ | – | banner | off |
| Weekly hive digest | – | ✓ | – | on |
| Marketing | – | ✓ | – | off (opt-in) |
| Harvest day at your farm | ✓ | – | farm post | on |
| Gift status (gifter side) | ✓ | ✓ | – | on |
| Recipient claimed gift | ✓ | ✓ | – | on |
| Referral redeemed (referrer) | ✓ | ✓ | – | on |

---

## 8. State & Error Handling Library

Every data-driven screen implements these five:

| State | Visual treatment |
|---|---|
| **Loading** | SkeletonLoader matching final layout. Avoid spinners except for short ops. |
| **Success** | Default rendering. |
| **Empty** | Friendly illustration + 1-line headline + CTA. e.g., "No clips yet. Catch a moment from your hive!" |
| **Error** | Calm error card. Always offers retry + "Email support" link. Never blame user. |
| **Offline** | Cached content shown if available + gray banner top. Disabled CTAs labeled "(Offline)". |

### Specific edge cases requiring custom handling
- **Hive emergency (S-HIVE-17)** — overrides Hive home until acknowledged
- **Sister hive activated (S-HIVE-10)** — overrides on next open
- **Trial expiring (banner)** — non-blocking, ever-present in last 3 days
- **Subscription past-due** — banner, soft-block on Honey customizer ("Update payment to customize your next jar")
- **Soft-deleted account login** — restore prompt before any other UI
- **Hard-deleted account login attempt** — friendly "We don't recognize this account. Sign up?" → S-AUTH-04

---

## 9. Engineering Stack Recommendations

### iOS
- **Language:** Swift 5.10+, SwiftUI primary, UIKit for VideoPlayer wrapper if needed.
- **Architecture:** MVVM with Composable Architecture or Observable models. Persist auth + cached state with SwiftData or Core Data.
- **Navigation:** NavigationStack (iOS 16+); fullscreen modals via `fullScreenCover`.
- **Video:** AVPlayer with HLS. Background audio via AVAudioSession.
- **3D jar render:** SceneKit (or RealityKit if you want AR variant later). For v1 MVP, consider 2D realistic mockup if SceneKit timeline tight.
- **Animations:** SwiftUI native; Lottie for confetti / hive reveal if assets come from designer.
- **Charts:** Swift Charts (iOS 16+), perfect fit.
- **Maps:** MapKit.

### Backend & services
- **Auth:** Sign in with Apple + Google + email/password via Auth0 or Firebase Auth or Supabase Auth.
- **Subscriptions:** **RevenueCat** layered over Apple IAP — saves months of receipt-validation, entitlement, and cross-platform headaches.
- **Database / API:** Supabase or Firebase. Real-time subscription for sensor data is a strong fit for Supabase Realtime / Firestore listeners.
- **One-off payments (extra jars, gifts):** Stripe. Keep it separate from IAP.
- **Push:** APNs via Firebase Cloud Messaging or Apple Push Notification service direct.
- **Email:** Postmark or SendGrid for transactional, weekly digest can be templated.
- **HLS streaming:** Wowza / Mux / AWS IVS / nimble streamer. Mux is easy to start with, AWS IVS scales cheapest at volume.
- **Content moderation (sticker text):** OpenAI moderation API or AWS Comprehend + custom blocklist + manual review queue for flagged.
- **Address validation:** USPS API or Smarty.
- **Carrier tracking:** AfterShip or ShipStation — gives unified API across USPS/UPS/FedEx.
- **Analytics:** Amplitude or PostHog. Keep events well-named: `signup_started`, `tier_selected`, `sticker_locked`, etc.
- **Crash reporting:** Sentry.
- **Customer support:** Front or Help Scout for the email-driven support inbox. Auto-tag tickets with hive ID + tier.

### Data & ops
- **Sensor ingestion:** MQTT broker (HiveMQ / AWS IoT Core) from on-farm gateway → time-series DB (Timescale or Influx) → API surface for app.
- **Camera infrastructure:** Cellular failover modem at farm + LTE backhaul. Multi-camera per hive needs ~5 Mbps upstream sustained. Plan accordingly.
- **Sticker printing:** integrate with print-on-demand vendor (Sticker Mule API / Stickeryou) for stickers, or in-house printer if scaling to bulk.
- **Honey fulfillment:** ShipStation or fulfillment partner (ShipBob / Easyship) for jar packing and shipping.

### Recommended early decisions (pre-build)
- **RevenueCat vs raw IAP:** RevenueCat. ~$X/month worth months of dev time.
- **Supabase vs Firebase:** Supabase if you prefer SQL + Postgres realtime. Firebase if you want zero-server config. For Bees, Supabase fits better (sensor data is relational, time-series).
- **3D jar in v1:** start with high-quality 2D mockup with sticker decal applied via image processing; defer 3D to v1.1 unless you have a 3D artist locked in.

---

## 10. Build Sequence

Each phase is gated on hard acceptance criteria.

### Phase 1 — MVP (target: 12–16 weeks)
**Goal:** End-to-end happy path. One hive. One camera (entrance). Pollinator + Forager tiers. No gifts, no clips, no comparison.

Screens in scope:
- All AUTH + OBD
- S-HIVE-01, 02, 03, 04 (4 of 7 stat detail variants), 15, 16
- S-HONEY-01, 02 (Pollinator + Forager paths only), 04, 09, 10, 11
- S-FARM-01, 03
- S-YOU-01, 02, 10, 13 (cancel), 16, 18
- S-SET-01, 02, 03, 04 (audio + quality only), 19 (basic), 20, 22, 23, 26, 27
- S-SYS-01 to S-SYS-08, S-SYS-10, S-SYS-11

Acceptance:
- New user can sign up, pick tier, customize first sticker, pay, view hive, customize next sticker, receive jar, see history.
- Cancel + delete account work end-to-end with App Store review compliance.
- Push notifications wired for sticker lock-in, shipment events, trial events.

### Phase 2 — Engagement (8–10 weeks)
**Add:** Multi-camera, audio toggle, time-lapse, clips, screenshots, achievements, weekly digest, anomaly alerts, comparison toggle, all stat detail variants, Queen Keeper tier (without painted hive).

Screens:
- S-HIVE-02 (camera picker), 05, 05b, 07, 07b, 08, 09, 17, 18, all 7 stat variants
- S-YOU-04, 05, 06, 08
- S-SET-02 (full notifications), 04 (full hive settings), 05 (tutorial)

### Phase 3 — Growth (6–8 weeks)
**Add:** Gift jar, gift subscription, referral, promo codes, buy extra jars, demo hive viewer, widgets, custom sticker font + color (if not in P1).

Screens:
- All S-GIFT-*
- S-AUTH-03, S-AUTH-06
- S-HONEY-12, S-HONEY-15
- S-YOU-15
- Widgets (small, medium, large, lock screen)
- Live Activity for hive activity

### Phase 4 — Polish & expansion
**Add:** Apple Watch, painted hive name flow, sister hive on-demand, custom photo on stickers, hive map (toggle reveal), additional states (OR/WA/NY/NC/FL), 3D jar with honey-pour animation if not earlier.

---

## 11. Acceptance Criteria

### MVP shipping criteria
- [ ] All Phase 1 screens implemented + design QA'd
- [ ] All 5 states implemented per data-driven screen
- [ ] App Store: privacy policy, terms, account deletion, subscription disclosure all in place
- [ ] Apple IAP via RevenueCat: trial, purchase, restore, cancel, switch tier, refund all tested
- [ ] Stripe: extra jars purchase tested incl. failure states
- [ ] HLS playback tested on cellular + Wi-Fi, with audio toggle, AirPlay, and offline state
- [ ] Sensor data: 30s refresh measured, animated counters smooth at 60fps
- [ ] Push notifications wired and tested for all default-on events
- [ ] Crash-free rate ≥ 99.5% in TestFlight beta
- [ ] Address validation rejects out-of-state with waitlist capture
- [ ] Sticker text moderation pipeline blocks profanity + PII patterns
- [ ] Account deletion soft → hard delete pipeline tested with email confirmations
- [ ] Cancel flow includes all 3 retention offers + clear disclosure of what's lost

### Performance budgets
- App cold start to first frame: ≤ 1.5s on iPhone 14 base
- Hive home video first frame: ≤ 3s on cellular
- Stat refresh: ≤ 200ms server response budget
- Sticker customizer 3D preview: 60fps interaction

### Accessibility (you said no for v1, but cheap to keep aligned)
- Dynamic Type tested at 200%
- VoiceOver labels on all interactive elements
- Color contrast ≥ 4.5:1 for body text
- Reduce Motion respected on all animated screens

---

## 12. Open follow-up items (for your call before kickoff)

1. **Branding** — final color palette, logo, illustration style. Hand to designer.
2. **Tier pricing experiment** — A/B test starter tier between $12.99 / $14.99 / $16.99 if you want to optimize? Or lock now?
3. **Painted hive name vendor** — who paints? In-person at the farm by farmer? Lead time?
4. **Promo / referral budget** — 1 free month each is generous. Cap on referrals per user? (Recommend 12/year to prevent abuse.)
5. **Sticker design library** — who creates the 8 designs? Contract illustrator? Brand budget?
6. **Demo hive content** — fully simulated → who builds the simulation? Could be a static loop + procedural counters in v1.
7. **Privacy policy & TOS** — needs lawyer.
8. **App Store assets** — name, subtitle, screenshots, preview video, keyword research.
9. **Customer support staffing** — even with FAQ, expect ~5–10% of users will email per month.

---

**End of plan.**
