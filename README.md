# Bees 2.0

iOS app where users adopt a real beehive on a partner farm — live video, real-time stats, and custom-stickered honey jars shipped to their door.

## Status

**Prototype scaffold.** Builds clean, runs on iOS 17+ simulator. Backend, payments, and real video streams are mocked. UI/UX is the focus.

## Stack

- **Language:** Swift 5
- **UI:** SwiftUI
- **Min OS:** iOS 17.0
- **Devices:** iPhone only (v1)
- **Bundle ID:** `com.bees.app`
- **Version:** 2.0
- **Architecture:** MVVM with service-protocol DI; `@Observable` view models

## Project layout

```
Bees/
├── BeesApp.swift          @main entry
├── ContentView.swift      Tab bar root
├── DesignSystem/          Color, type, spacing tokens
├── Models/                Tier, Hive, HiveSnapshot
├── Services/              Service protocols + mock impls
├── Views/
│   ├── Tabs/              Hive, Honey, Farm, You
│   └── Components/        StatTile, HealthPill
├── Assets.xcassets/       App icon, accent color
└── Preview Content/       SwiftUI preview assets
```

## Running

Open `Bees.xcodeproj` in Xcode 15+, pick an iOS 17+ simulator, and ⌘R.

## What's mocked vs real

| Real | Mocked |
|---|---|
| All UI / animations / navigation | Backend (no API calls) |
| SwiftUI architecture | Authentication (no real auth) |
| Service protocol layer | Live video (placeholder) |
| Stat simulation timer | Sensors / cameras |
| Local data flow | Sticker printing |
| Tier-gating logic | Apple IAP (sandbox later) |

## Spec docs

The full product specification, wireframes, and decision log live alongside this project:

- `BEES_APP_PLAN.md` — master plan, all 175 screens at standard depth
- `BEES_WIREFRAMES_HIVE_AND_STICKER.md` — Hive Home + Sticker Customizer (deep)
- `BEES_WIREFRAMES_REVEAL_CANCEL_GIFT.md` — Reveal + Cancel + Gift flow (deep)
- `BEES_DECISIONS_AND_WIREFRAMES_BATCH_3.md` — Demo + Onboarding + Honey Home + Stat Detail (deep)

## Build phase plan

- **Phase 1 (now):** Scaffold + Hive tab basic + 4-tab nav ✓
- **Phase 2:** Sticker customizer + Honey home + Stat detail
- **Phase 3:** Onboarding flow + Auth + Hive reveal animation
- **Phase 4:** Cancel + Gift flow
- **Phase 5:** Real backend integration, real video, real IAP
