import SwiftUI

/// Centralized animation tokens with Emil Kowalski's strong custom
/// timing curves. SwiftUI's bare `.easeOut` / `.easeInOut` are too
/// weak — they lack the punch that makes UI feel intentional.
///
/// **Curves**:
/// - `easeOut`  — `cubic-bezier(0.23, 1, 0.32, 1)`. Strong UI ease-out
///   for entrances, hover, color shifts, dropdowns.
/// - `easeInOut` — `cubic-bezier(0.77, 0, 0.175, 1)`. Strong on-screen
///   movement / morphs.
/// - `drawer` — `cubic-bezier(0.32, 0.72, 0, 1)`. iOS-like drawer/sheet.
///
/// **Durations** (Emil): UI animations stay under 300ms. Press feedback
/// 100–160ms. Tooltips 125–200. Dropdowns 150–250. Modals 200–500.
/// Exits should be ~75% of entrances.
///
/// Never use `.easeIn` for UI — feels sluggish because the user is
/// looking at the moment of action.
enum BeesAnimation {
    // MARK: - Curves

    /// Strong ease-out for entrances, color shifts, presses.
    static func easeOut(_ duration: Double = 0.20) -> Animation {
        .timingCurve(0.23, 1, 0.32, 1, duration: duration)
    }

    /// Strong ease-in-out for morphs and on-screen movement.
    static func easeInOut(_ duration: Double = 0.30) -> Animation {
        .timingCurve(0.77, 0, 0.175, 1, duration: duration)
    }

    /// iOS-style drawer/sheet curve (from Ionic Framework).
    static func drawer(_ duration: Double = 0.45) -> Animation {
        .timingCurve(0.32, 0.72, 0, 1, duration: duration)
    }

    // MARK: - Semantic shortcuts

    /// 140ms — button/card press feedback. Snappy.
    static let pressFeedback: Animation = easeOut(0.14)

    /// 200ms — generic UI state change (hover, color, small reveal).
    static let stateChange: Animation = easeOut(0.20)

    /// 240ms — dropdown / popover entry.
    static let popoverIn: Animation = easeOut(0.24)

    /// 180ms — popover exit (75% of in).
    static let popoverOut: Animation = easeOut(0.18)

    /// Spring for drag/momentum interactions where physics matter.
    /// Mirrors Apple Dynamic Island feel.
    static let drag: Animation = .spring(duration: 0.42, bounce: 0.18)
}

// MARK: - Pressable button style (Emil's foundational pattern)

/// Universal press feedback: scale-down + opacity dip on press, with
/// the strong custom ease-out curve. Use anywhere a Button label
/// shouldn't be `.plain`.
///
/// Emil: "Add `transform: scale(0.97)` on `:active`. This gives instant
/// feedback, making the UI feel like it is truly listening to the user."
struct PressableButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.97
    var pressedOpacity: Double = 0.85

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(BeesAnimation.pressFeedback, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    /// Default press feedback — 0.97 scale, 0.85 opacity, 140ms strong
    /// ease-out. Use for cards, list items, custom buttons.
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}
